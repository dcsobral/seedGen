#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SIZE="$(xmlstarlet sel -t -m "/MapInfo/property[@name='HeightMapSize']/@value" -v . map_info.xml | cut -d , -f 1)"
SEED="$(xmlstarlet sel -t -m "/MapInfo/property[@name='Generation.Seed']/@value" -v . map_info.xml)"

IMG="$("${BIN}/drawMap.sh" ${SIZE} "${SEED}")"

PREVIEW="$("${BIN}/drawPrefabs.sh" prefabs.xml "${IMG}"  ${SIZE} spawnpoints.xml)"

echo "${PREVIEW}"

