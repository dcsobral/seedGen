#!/usr/bin/env python3

from collections import defaultdict, namedtuple
from math import acos, atan2, cos, sin, sqrt
from scipy.spatial import KDTree
import argparse
import operator
import os
import sys
import xml.etree.ElementTree as ET

ScoredLocation = namedtuple('ScoredLocation',
                            ['score', 'decorations', 'center'])

DEFAULT_RADIUS = 1000
# TODO: add weight to each special
# TODO: count unique vs total
DEFAULT_SPECIALS = [
    "traders", "tier3", "tier4", "tier5", "stores", "top15", "industrial",
    "downtown"
]


def main(args):
    # bin = os.path.dirname(os.path.realpath(__file__))
    # sys.path.append(bin)
    special_prefabs = load_special_files(args.specials_folder, args.specials)
    prefab_specials = invert_dict_of_lists(special_prefabs)
    prefabs_of_interest = {
        prefab
        for prefabs in special_prefabs.values() for prefab in prefabs
    }
    decorations = load_prefabs_xml(args.prefabs, prefabs_of_interest)
    best_location = compute_rate(special_prefabs, prefab_specials, decorations,
                                 args.radius, args.debug)
    if args.verbose:
        print_verbose(special_prefabs, prefab_specials, best_location)
    print_rating(best_location.center, best_location, args.radius)


def load_special_files(specials_folder, specials):
    special_prefabs = {}
    for special in specials:
        with open("%s/%s.txt" % (specials_folder, special)) as f:
            special_prefabs[special] = [line.rstrip() for line in f]
    return special_prefabs


# TODO: translate position to center-of-prefab
def load_prefabs_xml(prefabs_file, prefabs_of_interest):
    decorations = []
    tree = ET.parse(prefabs_file)
    root = tree.getroot()
    for decoration in root.findall("decoration"):
        # Is the decoration a prefab we care about?
        if name(decoration) in prefabs_of_interest:
            decorations.append(decoration)
    return decorations


def compute_rate(special_prefabs, prefab_specials, decorations, distance,
                 debug):
    special_prefabs_count = 1.0
    for prefabs in special_prefabs.values():
        special_prefabs_count = special_prefabs_count * len(prefabs)
    scored_locations = score_all_decorations(special_prefabs, prefab_specials,
                                             decorations, distance, debug)
    best_location = get_best_location(scored_locations)
    scored_location = scored_locations[best_location]
    adjusted_scored_location = scored_location._replace(
        score=scored_location.score / special_prefabs_count)
    return adjusted_scored_location


def score_all_decorations(special_prefabs, prefab_specials, decorations,
                          distance, debug):
    diameter = distance * 2
    scored_locations = []
    locations = [xz(decoration) for decoration in decorations]
    kdtree = KDTree(locations)
    neighborhoods = kdtree.query_ball_tree(kdtree, diameter)
    candidates = compute_candidates(special_prefabs, prefab_specials,
                                    decorations, kdtree, diameter, debug)
    for i, decoration in enumerate(decorations):
        if i in candidates:
            scored_location = get_decoration_max_score(
                special_prefabs, prefab_specials, decoration, locations[i],
                locations, decorations, neighborhoods[i], distance)
        else:
            scored_location = ScoredLocation(0, [], (0, 0))
        scored_locations.append(scored_location)
    return scored_locations


def compute_candidates(special_prefabs, prefab_specials, decorations, kdtree,
                       diameter, debug):
    count_per_special = count_decorations_per_special(decorations,
                                                      special_prefabs.keys(),
                                                      prefab_specials)
    smallest_special = min(count_per_special.items(),
                           key=operator.itemgetter(1))[0]
    if debug:
        print(
            f'choosing neighbors of {smallest_special}: {count_per_special[smallest_special]} {count_per_special}'
        )
    smallest_prefabs = special_prefabs[smallest_special]
    smallest_decorations = [
        decoration for decoration in decorations
        if name(decoration) in smallest_prefabs
    ]
    smallest_kdtree = KDTree(
        [xz(decoration) for decoration in smallest_decorations])
    smallest_neighbors = smallest_kdtree.query_ball_tree(kdtree, diameter)
    candidates = set()
    for neighbors in smallest_neighbors:
        candidates.update(neighbors)
    if debug:
        print(
            f'{len(candidates)} candidates out of {len(decorations)} decorations'
        )
    return candidates


def get_best_location(scored_locations):
    best_score = -1
    best_index = -1
    for i, scored_location in enumerate(scored_locations):
        if scored_location.score > best_score:
            best_score = scored_location.score
            best_index = i
    return best_index


def get_decoration_max_score(special_prefabs, prefab_specials, decoration,
                             position, locations, decorations, neighbors,
                             radius):
    diameter = radius * 2
    within_range = {
        special: {prefab: 0
                  for prefab in special_prefabs[special]}
        for special in special_prefabs
    }
    special_unique_count = {special: 0 for special in special_prefabs}
    add_decoration(prefab_specials, within_range, special_unique_count,
                   decoration)
    current_decorations = [decoration]
    best_scored_location = ScoredLocation(compute_score(special_unique_count),
                                          current_decorations, xz(decoration))
    sweep = angular_sweep_neighbors(position, locations, neighbors, diameter)
    for angle, is_entry, index in sweep:
        if is_entry:
            add_decoration(prefab_specials, within_range, special_unique_count,
                           decorations[index])
            current_decorations.append(decorations[index])
            score = compute_score(special_unique_count)
            if score > best_scored_location.score:
                centerx = position[0] + radius * cos(angle)
                centery = position[1] + radius * sin(angle)
                center = (int(centerx), int(centery))
                best_scored_location = ScoredLocation(
                    score, list(current_decorations), center)
        else:
            remove_decoration(prefab_specials, within_range,
                              special_unique_count, decorations[index])
            current_decorations.remove(decorations[index])
    return best_scored_location


def compute_score(special_unique_count):
    score = 1.0
    for count in special_unique_count.values():
        score = score * count
    return score


def add_decoration(prefab_specials, within_range, special_unique_count,
                   decoration):
    prefab = name(decoration)
    for special in prefab_specials[prefab]:
        if not within_range[special][prefab]:
            special_unique_count[special] += 1
        within_range[special][prefab] += 1


def remove_decoration(prefab_specials, within_range, special_unique_count,
                      decoration):
    prefab = name(decoration)
    for special in prefab_specials[prefab]:
        within_range[special][prefab] -= 1
        if not within_range[special][prefab]:
            special_unique_count[special] -= 1


def angular_sweep_neighbors(position, locations, neighbors, diameter):
    lx, lz = position
    angles = []
    for i in neighbors:
        nx, nz = locations[i]
        neighbor_distance = sqrt((nx - lx)**2 + (nz - lz)**2)
        angle_neighbor_x_axis = atan2(nz - lz, nx - lx)
        angle_neighbor_boundary_circle_center = acos(neighbor_distance /
                                                     diameter)
        angle_entry = angle_neighbor_x_axis - angle_neighbor_boundary_circle_center
        angle_exit = angle_neighbor_x_axis + angle_neighbor_boundary_circle_center
        angles.append((angle_entry, -1, i))
        angles.append((angle_exit, 0, i))
    angles.sort()
    return angles


def invert_dict_of_lists(d):
    inverted_d = defaultdict(list)
    for key, elements in d.items():
        for e in elements:
            inverted_d[e].append(key)
    return inverted_d


def count_decorations_per_special(decorations, specials, prefab_specials):
    special_count = {special: 0 for special in specials}
    for decoration in decorations:
        prefab = name(decoration)
        for special in prefab_specials[prefab]:
            special_count[special] += 1
    return special_count


def name(decoration):
    return decoration.attrib["name"]


def xz(decoration):
    pos = decoration.attrib["position"].split(",")
    return [int(pos[0]), int(pos[2])]


def print_verbose(special_prefabs, prefab_specials, location):
    within_range = {
        special: {prefab: 0
                  for prefab in special_prefabs[special]}
        for special in special_prefabs
    }
    special_unique_count = {special: 0 for special in special_prefabs}
    for decoration in location.decorations:
        add_decoration(prefab_specials, within_range, special_unique_count,
                       decoration)
    for special in special_prefabs:
        print("%s (%d/%d):\t" % (special, special_unique_count[special],
                                 len(special_prefabs[special])),
              end='')
        for prefab in sorted(within_range[special]):
            if within_range[special][prefab]:
                print("%s " % prefab, end='')
        print()


def print_rating(center, best_location, radius):
    print(
        f'{int(best_location.score * 1000000)} {center[0]},{center[1]} {radius}'
    )


def parse_args(args=None,
               script_path=os.path.dirname(os.path.realpath(__file__))):
    specials_folder = "%s/special" % script_path
    parser = argparse.ArgumentParser(description="Rate best base location")
    parser.add_argument("--specials",
                        nargs='+',
                        default=DEFAULT_SPECIALS,
                        help="special files")
    parser.add_argument("--specials-folder",
                        default=specials_folder,
                        help='folder containing lists of special prefabs')
    parser.add_argument("--distance",
                        type=int,
                        dest='radius',
                        default=DEFAULT_RADIUS,
                        help='maximum distance to prefab (default %d)' %
                        DEFAULT_RADIUS)
    parser.add_argument("--verbose",
                        action='store_true',
                        help='print specials list (default)')
    parser.add_argument("--quiet",
                        action='store_false',
                        dest='verbose',
                        help='suppress specials list')
    parser.set_defaults(verbose=True)
    parser.add_argument("--print-defaults",
                        action='store_true',
                        help='print default option values')
    parser.add_argument("--debug",
                        action='store_true',
                        help='print debugging information')
    parser.add_argument("prefabs")
    args = parser.parse_args(args)
    if args.print_defaults:
        print(f'--radius={DEFAULT_RADIUS}')
        sys.exit(0)
    return args


if __name__ == '__main__':
    main(parse_args(sys.argv[1:]))
