#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

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
LINE=$(grep -E 'WorldGenerator:Generating.*(Territory|County|Valley|Mountains)' log.txt | tail -1 | tr -d $'\n\r')
COUNTY=$(cut -d ' ' -f 5- <<<"$LINE")
echo "Saving preview for '${COUNTY}'"

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

