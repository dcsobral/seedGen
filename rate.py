#!/usr/bin/env python

from __future__ import print_function
from collections import Counter
import argparse
import os
import re
import sys
import xml.etree.ElementTree as ET


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


bin = os.path.dirname(os.path.realpath(__file__))

default_specials = [
    "traders", "tier3", "tier4", "tier5", "stores", "top15", "industrial"
]
precision_default = 256
diameter_default = 8
parser = argparse.ArgumentParser(description="Rate best base location")
parser.add_argument("--specials",
                    nargs='+',
                    default=default_specials,
                    help="special files")
parser.add_argument("--diameter",
                    type=int,
                    default=diameter_default,
                    help='diameter in number of regions (default %d)' % diameter_default)
parser.add_argument("--precision", type=int, default=precision_default,
                    help='region size (default %d)' % precision_default)
parser.add_argument("--size", type=int, default=0, help='map size')
parser.add_argument("--verbose",
                    action='store_true',
                    help='print specials list (default)')
parser.add_argument("--quiet",
                    action='store_false',
                    dest='verbose',
                    help='suppress specials list')
parser.set_defaults(verbose=True)
parser.add_argument("--debug",
                    action='store_true',
                    help='print debugging information')
parser.add_argument("prefabs")
args = parser.parse_args()
precision = args.precision
diameter = args.diameter
specials = args.specials
prefabs_file = args.prefabs
verbose = args.verbose
debug = args.debug
if args.size > 0:
    size = args.size
else:
    m = re.search(r'-(\d+)\.xml', prefabs_file)
    size = int(m.group(1))

ahead = diameter / 2
backwards = diameter - ahead
center = size / 2
start = -center / precision
end = center / precision
bucket_range = range(start, end)

special_folder = "%s/special" % bin
special_prefabs = {}
for special in specials:
    with open("%s/%s.txt" % (special_folder, special)) as f:
        special_prefabs[special] = [line.rstrip() for line in f]

prefab_specials = {}
for group in special_prefabs:
    for prefab in special_prefabs[group]:
        if prefab in prefab_specials:
            prefab_specials[prefab].append(group)
        else:
            prefab_specials[prefab] = [group]


def get_bucket(position):
    xyz = position.split(",")
    x = int(xyz[0])
    z = int(xyz[2])
    return "%d,%d" % (x / precision, z / precision)


bucket_specials = {}
for x in bucket_range:
    for y in bucket_range:
        bucket = "%d,%d" % (x, y)
        bucket_specials[bucket] = {special: set() for special in specials}

tree = ET.parse(prefabs_file)
root = tree.getroot()
prefabs = root.findall("decoration")
for prefab in prefabs:
    name = prefab.attrib["name"]
    position = prefab.attrib["position"]
    bucket = get_bucket(position)
    if name in prefab_specials:
        for special in prefab_specials[name]:
            bucket_specials[bucket][special].add(name)

horizontal_aggregate = {}
for special in specials:
    horizontal_aggregate[special] = {}
    for y in bucket_range:
        current = Counter()
        for x in range(start - ahead, start) + bucket_range:
            if x + ahead in bucket_range:
                next = "%d,%d" % (x + ahead, y)
                current.update(bucket_specials[next][special])

            if x - backwards in bucket_range:
                prev = "%d,%d" % (x - backwards, y)
                current.subtract(bucket_specials[prev][special])

            if x in bucket_range:
                bucket = "%d,%d" % (x, y)
                horizontal_aggregate[special][bucket] = current + Counter()

vertical_aggregate = {}
for special in specials:
    vertical_aggregate[special] = {}
    for x in bucket_range:
        current = Counter()
        for y in range(start - ahead, start) + bucket_range:
            if y + ahead in bucket_range:
                next = "%d,%d" % (x, y + ahead)
                current.update(horizontal_aggregate[special][next])

            if y - backwards in bucket_range:
                prev = "%d,%d" % (x, y - backwards)
                current.subtract(horizontal_aggregate[special][prev])

            if y in bucket_range:
                bucket = "%d,%d" % (x, y)
                vertical_aggregate[special][bucket] = current + Counter()

score = {}
max_score = 0.0
max_bucket = ""
max_position = "none"
offset = precision if diameter % 2 == 0 else precision / 2
for x in bucket_range:
    for y in bucket_range:
        bucket = "%d,%d" % (x, y)
        score[bucket] = 1.0
        for special in specials:
            score[bucket] = score[bucket] * \
                len(vertical_aggregate[special][bucket]
                    ) / len(special_prefabs[special])
        if score[bucket] > max_score:
            max_score = score[bucket]
            max_bucket = bucket
            max_position = "%d,%d" % (x * precision + offset,
                                      y * precision + offset)

if debug:
    for x in bucket_range:
        for y in bucket_range:
            bucket = "%d,%d" % (x, y)
            if [
                    vertical_aggregate[special][bucket] for special in specials
                    if vertical_aggregate[special][bucket]
            ]:
                print("%s %f: " % (bucket, score[bucket]), end='')
                for special in specials:
                    print("%s %d/%d/%d/%d " %
                          (special, len(bucket_specials[bucket][special]),
                           len(horizontal_aggregate[special][bucket]),
                           len(vertical_aggregate[special][bucket]),
                           len(special_prefabs[special])),
                          end='')
                print()

if verbose and max_position != "none":
    for special in specials:
        print("%s (%d/%d):\t" %
              (special, len(vertical_aggregate[special][max_bucket]),
               len(special_prefabs[special])),
              end='')
        for prefab in vertical_aggregate[special][max_bucket]:
            print("%s " % prefab, end='')
        print()

print("%d %s" % (max_score * 1000000, max_position))
