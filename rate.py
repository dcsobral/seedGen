#!/usr/bin/env python

from __future__ import print_function
from collections import Counter
import inspect
import os
import sys
import xml.etree.ElementTree as ET

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

bin = os.path.dirname(os.path.realpath(__file__))

if len(sys.argv) != 3:
    eprint("Syntax: %s <prefabs.xml> <size>" % __file__)
    sys.exit(1)

prefabs_file = sys.argv[1]
size = int(sys.argv[2])
center = size / 2
start = -center / 512
end = center / 512
bucket_range = range(start, end)

special_folder = "%s/special" % bin
specials = [ "traders", "tier3", "tier4", "tier5", "stores", "top15", "industrial" ]
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
    return "%d,%d" % (x / 512, z / 512)

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

radius = 1

horizontal_aggregate = {}
for special in specials:
    horizontal_aggregate[special] = {}
    for y in bucket_range:
        current = Counter()
        for x in range(start - radius, start) + bucket_range:
            #print("ha %s %d,%d: %s" % (special,x,y,current))
            if x + radius in bucket_range:
                next = "%d,%d" % (x + radius, y)
                #print("Adding %s: %s" % (next, bucket_specials[next][special]))
                current.update(bucket_specials[next][special])

            if x - radius - 1 in bucket_range:
                prev = "%d,%d" % (x - radius - 1, y)
                #print("Subtracting %s: %s" % (prev, bucket_specials[prev][special]))
                current.subtract(bucket_specials[prev][special])

            if x in bucket_range:
                bucket = "%d,%d" % (x, y)
                horizontal_aggregate[special][bucket] = current + Counter()
                #print("Setting %d,%d: %s" % (x * 512, y * 512, horizontal_aggregate[special][bucket]))
#print(horizontal_aggregate)

vertical_aggregate = {}
for special in specials:
    vertical_aggregate[special] = {}
    for x in bucket_range:
        current = Counter()
        for y in range(start - radius, start) + bucket_range:
            #print("va %s %d,%d: %s" % (special,x,y,current))
            if y + radius in bucket_range:
                next = "%d,%d" % (x, y + radius)
                #print("Adding %s: %s" % (next, horizontal_aggregate[special][next]))
                current.update(horizontal_aggregate[special][next])

            if y - radius - 1 in bucket_range:
                prev = "%d,%d" % (x, y - radius - 1)
                #print("Subtracting %s: %s" % (prev, horizontal_aggregate[special][prev]))
                current.subtract(horizontal_aggregate[special][prev])

            if y in bucket_range:
                bucket = "%d,%d" % (x, y)
                vertical_aggregate[special][bucket] = current + Counter()
                #print("Setting %d,%d: %s" % (x * 512, y * 512, vertical_aggregate[special][bucket]))
#print(vertical_aggregate)

score = {}
max_score = 0.0
max_bucket = ""
max_position = "none"
for x in bucket_range:
    for y in bucket_range:
        bucket = "%d,%d" % (x, y)
        score[bucket] = 1.0
        for special in specials:
            score[bucket] = score[bucket] * len(vertical_aggregate[special][bucket]) / len(special_prefabs[special])
        if score[bucket] > max_score:
            max_score = score[bucket]
            max_bucket = bucket
            max_position = "%d,%d" % (x * 512 + 256, y * 512 + 256)

#for x in bucket_range:
#    for y in bucket_range:
#        bucket = "%d,%d" % (x, y)
#        print("%s %f: " % (bucket, score[bucket]), end = '')
#        for special in specials:
#            print("%s %d/%d/%d/%d " % (special, len(bucket_specials[bucket][special]), len(horizontal_aggregate[special][bucket]), len(vertical_aggregate[special][bucket]), len(special_prefabs[special])), end = '')
#        print()

if max_position != "none":
    for special in specials:
        print("%s (%d/%d): " % (special, len(vertical_aggregate[special][max_bucket]), len(special_prefabs[special])), end = '')
        for prefab in vertical_aggregate[special][max_bucket]:
            print("%s " % prefab, end = '')
        print()

print("%d %s" % (max_score * 1000000, max_position))

