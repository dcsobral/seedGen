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
GENERATION_INFO_FILE="${NAME}-GenerationInfo.txt"
MAP_INFO_FILE="${NAME}-map_info.xml"
SPAWN="${NAME}-spawnpoints.xml"

cd  "${F7D2D}"
LINE=$(grep -E 'WorldGenerator:Generating.*(Territory|County|Valley|Mountains)' log.txt | tail -1 | tr -d $'\n\r')
COUNTY=$(cut -d ' ' -f 5- <<<"$LINE")
echo "Saving preview for '${COUNTY}'"

cd "UserData/GeneratedWorlds/${COUNTY}"
cp prefabs.xml "${PREFABS}"
cp spawnpoints.xml "${SPAWN}"
PREVIEW="$("${BIN}/drawMap.sh" "${SIZE}" "${SEED}" 43)"
if [[ ! -f nodraw ]]; then
	PREFABS_PREVIEW="$("${BIN}/drawPrefabs.sh" "${PREFABS}" "${PREVIEW}" "${SIZE}" "${SPAWN}")"
	# WATER_PREVIEW="$("${BIN}/drawWater.sh" water_info.xml "${PREFABS_PREVIEW}" "${SIZE}")"
	mv "${PREFABS_PREVIEW}" "${PREVIEW}"
	THUMBNAIL="thumbs/${PREVIEW}"
else
	THUMBNAIL=""
	echo >&2 "Skipping prefab and water drawing"
fi

echo "$COUNTY" > "${COUNTY_FILE}"
touch "${GENERATION_INFO_FILE}" "${MAP_INFO_FILE}"
if [[ -f GenerationInfo.txt ]]; then
	cp GenerationInfo.txt "${GENERATION_INFO_FILE}"
fi
if [[ -f map_info.xml ]]; then
	cp map_info.xml "${MAP_INFO_FILE}"
fi

zip "${NAME}" "${PREVIEW}" "${PREFABS}" "${SPAWN}" "${COUNTY_FILE}" \
	${THUMBNAIL:+"${THUMBNAIL}"} \
	"${GENERATION_INFO_FILE}" "${MAP_INFO_FILE}"

mkdir -p "${F7D2D}/previews"
mv "${NAME}.zip" "${F7D2D}/previews/"

