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
LINE=$(grep -m 1 "GamePref.GameWorld" log.txt | tr -d $'\n\r')
COUNTY=$(cut -d "=" -f 2 <<<"$LINE" | cut -c 2-)

cd "UserData/GeneratedWorlds/${COUNTY}"
PREVIEW="$("${BIN}/drawMap.sh" "${SIZE}" "${SEED}" 43)"
if [[ ! -f nodraw ]]; then
	PREFABS_PREVIEW="$("${BIN}/drawPrefabs.sh" prefabs.xml "${PREVIEW}" "${SIZE}")"
	# WATER_PREVIEW="$("${BIN}/drawWater.sh" water_info.xml "${PREFABS_PREVIEW}" "${SIZE}")"
	mv "${PREFABS_PREVIEW}" "${PREVIEW}"
else
	echo >&2 "Skipping prefab and water drawing"
fi

cp prefabs.xml "${PREFABS}"
echo "$COUNTY" > "${COUNTY_FILE}"
zip "${NAME}" "${PREVIEW}" "${PREFABS}" "${COUNTY_FILE}"

mkdir -p "${F7D2D}/previews"
mv "${NAME}.zip" "${F7D2D}/previews/"

