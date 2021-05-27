#!/usr/bin/env python

from __future__ import print_function
from collections import Counter
import argparse
import inspect
import os
import re
import sys
import xml.etree.ElementTree as ET

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

bin = os.path.dirname(os.path.realpath(__file__))

default_specials = [ "traders", "tier3", "tier4", "tier5", "stores", "top15", "industrial" ]
parser = argparse.ArgumentParser(description = "Rate best base location")
parser.add_argument("--specials", dest = "specials", nargs = '+', default = default_specials, help = "special files")
parser.add_argument("--diameter", dest = "diameter", type = int, default = 8, help = 'diameter in number of regions')
parser.add_argument("--precision", dest = "precision", type = int, default = 256, help = 'region size')
parser.add_argument("--size", type = int, default = 0, help = 'map size')
parser.add_argument("prefabs")
args = parser.parse_args()


#if len(sys.argv) != 3:
#    eprint("Syntax: %s <prefabs.xml> <size>" % __file__)
#    sys.exit(1)

precision = args.precision
diameter = args.diameter
ahead = diameter / 2
backwards = diameter - ahead
prefabs_file = args.prefabs
if args.size > 0:
    size = args.size
else:
    m = re.search('-(\d+)\.xml', prefabs_file)
    size = int(m.group(1))
center = size / 2
start = -center / precision
end = center / precision
bucket_range = range(start, end)

special_folder = "%s/special" % bin
specials = args.specials
special_prefabs = {}
for special in specials:
    with open("%s/%s.txt" % (special_folder, special)) as f:
        special_prefabs[special] = [line.rstrip() for line in f]
#print(special_prefabs)

prefab_specials = {}
for group in special_prefabs:
    for prefab in special_prefabs[group]:
        if prefab in prefab_specials:
            prefab_specials[prefab].append(group)
        else:
            prefab_specials[prefab] = [ group ]
#print(prefab_specials)

def get_bucket(position):
    xyz = position.split(",")
    x = int(xyz[0])
    z = int(xyz[2])
    return "%d,%d" % (x / precision, z / precision)

bucket_specials = {}
for x in bucket_range:
    for y in bucket_range:
        bucket = "%d,%d" % (x, y)
        bucket_specials[bucket] = { special: set() for special in specials }

tree = ET.parse(prefabs_file)
root = tree.getroot()
prefabs = root.findall("decoration")
for prefab in prefabs:
    name = prefab.attrib["name"]
    position = prefab.attrib["position"]
    bucket = get_bucket(position)
    if name in prefab_specials:
        #print("%s (%s  %s): %s" % (name, position, bucket, prefab_specials[name]))
        for special in prefab_specials[name]:
            bucket_specials[bucket][special].add(name)
#print(bucket_specials)

horizontal_aggregate = {}
for special in specials:
    horizontal_aggregate[special] = {}
    for y in bucket_range:
        current = Counter()
        for x in range(start - ahead, start) + bucket_range:
            #print("ha %s %d,%d: %s" % (special,x,y,current))
            if x + ahead in bucket_range:
                next = "%d,%d" % (x + ahead, y)
                #print("Adding %s: %s" % (next, bucket_specials[next][special]))
                current.update(bucket_specials[next][special])

            if x - backwards in bucket_range:
                prev = "%d,%d" % (x - backwards, y)
                #print("Subtracting %s: %s" % (prev, bucket_specials[prev][special]))
                current.subtract(bucket_specials[prev][special])

            if x in bucket_range:
                bucket = "%d,%d" % (x, y)
                horizontal_aggregate[special][bucket] = current + Counter()
                #print("Setting %d,%d: %s" % (x * precision, y * precision, horizontal_aggregate[special][bucket]))
#print(horizontal_aggregate)

vertical_aggregate = {}
for special in specials:
    vertical_aggregate[special] = {}
    for x in bucket_range:
        current = Counter()
        for y in range(start - ahead, start) + bucket_range:
            #print("va %s %d,%d: %s" % (special,x,y,current))
            if y + ahead in bucket_range:
                next = "%d,%d" % (x, y + ahead)
                #print("Adding %s: %s" % (next, horizontal_aggregate[special][next]))
                current.update(horizontal_aggregate[special][next])

            if y - backwards in bucket_range:
                prev = "%d,%d" % (x, y - backwards)
                #print("Subtracting %s: %s" % (prev, horizontal_aggregate[special][prev]))
                current.subtract(horizontal_aggregate[special][prev])

            if y in bucket_range:
                bucket = "%d,%d" % (x, y)
                vertical_aggregate[special][bucket] = current + Counter()
                #print("Setting %d,%d: %s" % (x * precision, y * precision, vertical_aggregate[special][bucket]))
#print(vertical_aggregate)

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
            score[bucket] = score[bucket] * len(vertical_aggregate[special][bucket]) / len(special_prefabs[special])
        if score[bucket] > max_score:
            max_score = score[bucket]
            max_bucket = bucket
            max_position = "%d,%d" % (x * precision + offset, y * precision + offset)

#for x in bucket_range:
#    for y in bucket_range:
#        bucket = "%d,%d" % (x, y)
#        print("%s %f: " % (bucket, score[bucket]), end = '')
#        for special in specials:
#            print("%s %d/%d/%d/%d " % (special, len(bucket_specials[bucket][special]), len(horizontal_aggregate[special][bucket]), len(vertical_aggregate[special][bucket]), len(special_prefabs[special])), end = '')
#        print()

if max_position != "none":
    for special in specials:
        print("%s (%d/%d):\t" % (special, len(vertical_aggregate[special][max_bucket]), len(special_prefabs[special])), end = '')
        for prefab in vertical_aggregate[special][max_bucket]:
            print("%s " % prefab, end = '')
        print()

print("%d %s" % (max_score * 1000000, max_position))

