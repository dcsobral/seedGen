#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:=/mnt/c/Users/Daniel/Desktop/RH5.5Server}"

if [[ $# -ne 2 ]]; then
	echo >&2 "$0 <size> <seed>"
	exit 1
fi

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIZE="${1}"
IMGSIZE="${SIZE}x${SIZE}"
SEED="${2}"
NAME="${SEED}-${SIZE}"
PREFABS="${NAME}.xml"
COUNTY_FILE="${NAME}.txt"

cd  "${F7D2D}"
LINE=$(grep -m 1 "Generating county" log.txt)
COUNTY=$(cut -d "'" -f 2 <<<"$LINE")

cd "UserData/GeneratedWorlds/${COUNTY}"
PREVIEW="$("${BIN}/drawMap.sh" "${SIZE}" "${SEED}")"
if [[ ! -f nodraw ]]; then
	PREFABS_PREVIEW="$("${BIN}/drawPrefabs.sh" prefabs.xml "${PREVIEW}" "${SIZE}")"
	WATER_PREVIEW="$("${BIN}/drawWater.sh" water_info.xml "${PREFABS_PREVIEW}" "${SIZE}")"
	mv "${WATER_PREVIEW}" "${PREVIEW}"
else
	echo >&2 "Skipping prefab and water drawing"
fi

cp prefabs.xml "${PREFABS}"
echo "$COUNTY" > "${COUNTY_FILE}"
zip "${NAME}" "${PREVIEW}" "${PREFABS}" "${COUNTY_FILE}"

mkdir -p "${F7D2D}/previews"
mv "${NAME}.zip" "${F7D2D}/previews/"

