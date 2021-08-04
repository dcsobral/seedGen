#!/usr/bin/env python3

from collections import Counter, defaultdict, namedtuple
from math import acos, atan2, ceil, sqrt
from scipy.spatial import KDTree
from scipy.spatial.distance import cdist, euclidean
import argparse
import numpy as np
import operator
import os
import re
import sys
import xml.etree.ElementTree as ET

ScoredLocation = namedtuple('ScoredLocation', ['score', 'decorations'])

DEFAULT_RADIUS = 1086
# TODO: add weight to each special
# TODO: count unique vs total
DEFAULT_SPECIALS = [
    "traders", "tier3", "tier4", "tier5", "stores", "top15", "industrial", "downtown"
]

def main(args):
    special_prefabs = load_special_files(args.specials_folder, args.specials)
    prefab_specials = invert_dict_of_lists(special_prefabs)
    prefabs_of_interest = { prefab for prefabs in special_prefabs.values() for prefab in prefabs }
    decorations = load_prefabs_xml(args.prefabs, prefabs_of_interest)
    (center, best_location) = compute_rate(special_prefabs, prefab_specials, decorations, args.radius)
    if args.verbose:
        print_verbose(special_prefabs, prefab_specials, best_location)
    print_rating(center, best_location)

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

# all_coords = [xz(prefab) for prefab in prefabs]
# kd = KDTree(all_cords)
# for coord in all_cords:
#     nn = kd.query_ball_point(coord, r)
# traders_coords = [xz(prefab) for prefab in prefabs if prefab.attrib["name"] in special_prefabs["traders"]]
# kdtrader = KDTree(traders_coords)
# trader_pairs = kdtrader.query_pairs(distance)
# prox_traders = kdtrader.query_ball_tree(kdtraders, distance)
# prox_to_traders = kdtrader.query_ball_tree(kd, distance)
# decorations = [special: [prefab for prefab in prefabs if prefab.attrib["name"] in special_prefabs[special]] for special in special_prefabs]
# kdtrees = {special: KDTree([xz(decoration) for decoration in decorations[special]]) for special in decorations.keys()}
# for nn in kdtrees["traders"].query_ball_tree(kdtrees["top15"], 1024):
#     {kdtrees["top15"][i].attrib["name"] for i in nn}
# Heuristic: count decorations for each special then limit the set of decorations to be
#            searched to the ones within 2r range of the ones in the special with the
#            least amount of decorations

def compute_rate(special_prefabs, prefab_specials, decorations, distance):
    scored_locations = score_all_decorations(special_prefabs, prefab_specials, decorations, distance)
    best_location = get_best_location(scored_locations)
    scored_location = scored_locations[best_location]
    center = geometric_median(scored_location)
    return (center, scored_location)

def score_all_decorations(special_prefabs, prefab_specials, decorations, distance):
    diameter = distance * 2
    scored_locations = []
    locations = [xz(decoration) for decoration in decorations]
    kdtree = KDTree(locations)
    neighborhoods = kdtree.query_ball_tree(kdtree, diameter)

    # TODO: extract method
    count_per_special = count_decorations_per_special(decorations, special_prefabs.keys(), prefab_specials)
    smallest_special = min(count_per_special.items(), key = operator.itemgetter(1))[0]
    #print(f'{smallest_special}: {count_per_special[smallest_special]} {count_per_special}')
    smallest_prefabs = special_prefabs[smallest_special]
    smallest_decorations = [decoration for decoration in decorations if name(decoration) in smallest_prefabs]
    smallest_kdtree = KDTree([xz(decoration) for decoration in smallest_decorations])
    smallest_neighbors = smallest_kdtree.query_ball_tree(kdtree, diameter)
    candidates = set()
    for neighbors in smallest_neighbors:
        candidates.update(neighbors)
    #print(f'{len(candidates)} out of {len(decorations)}')

    for i, decoration in enumerate(decorations):
        if i in candidates:
            scored_location = get_decoration_max_score(special_prefabs, prefab_specials, decoration, decorations, neighborhoods[i], diameter)
        else:
            scored_location = ScoredLocation(0, [])
        scored_locations.append(scored_location)
    return scored_locations

def get_best_location(scored_locations):
    best_score = -1
    best_index = -1
    for i, scored_location in enumerate(scored_locations):
        if scored_location.score > best_score:
            best_score = scored_location.score
            best_index = i
    return best_index

def get_decoration_max_score(special_prefabs, prefab_specials, decoration, decorations, neighbors, diameter):
    within_range = { special: Counter({ prefab: 0 for prefab in special_prefabs[special]}) for special in special_prefabs }
    add_decoration(prefab_specials, within_range, decoration)
    current_decorations = [decoration]
    best_scored_location = ScoredLocation(compute_score(special_prefabs, within_range), current_decorations)
    sweep = angle_sweep_neighbors(decoration, decorations, neighbors, diameter)
    for angle, is_entry, index in sweep:
        if is_entry:
            add_decoration(prefab_specials, within_range, decorations[index])
            current_decorations.append(decorations[index])
            score = compute_score(special_prefabs, within_range)
            if score > best_scored_location.score:
                best_scored_location = ScoredLocation(score, list(current_decorations))
        else:
            remove_decoration(prefab_specials, within_range, decorations[index])
            current_decorations.remove(decorations[index])
    return best_scored_location

def copy_within(w):
    return { k: v + Counter() for k, v in w.items() }

def compute_score(special_prefabs, within_range):
    score = 1.0
    for special, prefabs in within_range.items():
        score = score * non_zero(prefabs) / len(special_prefabs[special])
    return score

def non_zero(counter):
    length = 0
    for count in counter.values():
        if count:
            length += 1
    return length

def add_decoration(prefab_specials, within_range, decoration):
    prefab = name(decoration)
    for special in prefab_specials[prefab]:
        within_range[special].update([prefab])

def remove_decoration(prefab_specials, within_range, decoration):
    prefab = name(decoration)
    for special in prefab_specials[prefab]:
        within_range[special].subtract([prefab])


def angle_sweep_neighbors(decoration, decorations, neighbors, diameter):
    lx, lz = xz(decoration)
    angles = []
    for i in neighbors:
        nx, nz = xz(decorations[i])
        neighbor_distance = sqrt((nx - lx) ** 2 + (nz - lz) ** 2)
        angle_neighbor_x_axis = atan2(nz - lz, nx - lx)
        angle_neighbor_boundary_circle_center = acos(neighbor_distance / diameter)
        angle_entry = angle_neighbor_x_axis - angle_neighbor_boundary_circle_center
        angle_exit = angle_neighbor_x_axis + angle_neighbor_boundary_circle_center
        angles.append((angle_entry, -1, i))
        angles.append((angle_exit, 0, i))
    angles.sort()
    return angles

# https://stackoverflow.com/a/30305181/53013
def geometric_median(scored_location, eps=0.1):
    X = np.array([xz(decoration) for decoration in scored_location.decorations])
    y = np.mean(X, 0)

    while True:
        D = cdist(X, [y])
        nonzeros = (D != 0)[:, 0]

        Dinv = 1 / D[nonzeros]
        Dinvs = np.sum(Dinv)
        W = Dinv / Dinvs
        T = np.sum(W * X[nonzeros], 0)

        num_zeros = len(X) - np.sum(nonzeros)
        if num_zeros == 0:
            y1 = T
        elif num_zeros == len(X):
            return y.astype(int)
        else:
            R = (T - y) * Dinvs
            r = np.linalg.norm(R)
            rinv = 0 if r == 0 else num_zeros/r
            y1 = max(0, 1-rinv)*T + min(1, rinv)*y

        if euclidean(y, y1) < eps:
            return y1.astype(int)

        y = y1

# https://stackoverflow.com/a/50322879/53013
#def geometric_median(scored_location):
#    points = [xz(decoration) for decoration in scored_location.decorations]
#    xs = [point[0] for point in points]
#    zs = [point[1] for point in points]
#
#    x0 = np.array([sum(xs) / len(xs), sum(zs) / len(zs)])
#    def dist_func(x0):
#        return sum(((np.full(len(xs), x0[0]) - xs) ** 2 + (np.full(len(xs), x0[1]) - zs) ** 2) ** 0.5)
#    res = minimize(dist_func, x0, method='nelder-mead', options={'xtol': 1e-8, 'disp': True})
#    return res.x.astype(int)

def invert_dict_of_lists(d):
    inverted_d = defaultdict(list)
    for key, elements in d.items():
        for e in elements:
            inverted_d[e].append(key)
    return inverted_d

def count_decorations_per_special(decorations, specials, prefab_specials):
    special_count = { special: 0 for special in specials }
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
    within_range = { special: Counter({ prefab: 0 for prefab in special_prefabs[special]}) for special in special_prefabs }
    for decoration in location.decorations:
        add_decoration(prefab_specials, within_range, decoration)
    for special in special_prefabs:
        print("%s (%d/%d):\t" %
              (special, non_zero(within_range[special]),
               len(special_prefabs[special])),
              end='')
        for prefab in sorted(within_range[special]):
            print("%s " % prefab, end='')
        print()

def print_rating(center, best_location):
    print(f'{int(best_location.score * 1000000)} {center[0]},{center[1]}')

def parse_args(args = None, script_path = os.path.dirname(os.path.realpath(__file__))):
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
                        help='maximum distance to prefab (default %d)' % DEFAULT_RADIUS)
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

