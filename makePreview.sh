#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ -f map_info.xml ]] || echo >&2 "No map_info.xml file found at $PWD!"

SIZE="$(xmlstarlet sel -t -m "/MapInfo/property[@name='HeightMapSize']/@value" -v . map_info.xml | cut -d , -f 1)"
SEED="$(xmlstarlet sel -t -m "/MapInfo/property[@name='Generation.Seed']/@value" -v . map_info.xml)"
[[ -n $SEED ]] || SEED="$(basename "$PWD")"

IMG="$("${BIN}/drawMap.sh" ${SIZE} "${SEED}")"

PREVIEW="$("${BIN}/drawPrefabs.sh" prefabs.xml "${IMG}"  ${SIZE} spawnpoints.xml)"

echo "${PREVIEW}"

