#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

usage() {
	cat >&2 <<-USAGE
		$0 [options] <size> <seed>

		Options:
		  --name <world name>
		  --world <path to world folder>
		  --output <filename>
		  --options [anything] --endoptions
	USAGE
	exit 1
}

declare -a OPTS
OPTS=( )
while [[ $# -gt 0 && $1 == -* ]]; do
	case "$1" in
	--name)
		shift
		COUNTY="$1"
		;;
	--world)
		shift
		WORLD="$1"
		;;
	--output)
		shift
		OUTPUT="$1"
		;;
	--options)
		shift
		# fixme: exponential complexity
		while [[ $# -gt 1 && $1 != --endoptions ]]; do
			OPTS=( "${OPTS[@]}" "$1" )
			shift
		done
		;;
	*)
		usage
		;;
	esac
	shift
done

if [[ $# -ne 2 ]]; then
	usage
fi

# Default values
: "${COUNTY:=}"
: "${OUTPUT:=}"
: "${WORLD:=}"

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIZE="${1}"
SEED="${2}"
NAME="${SEED}-${SIZE}"
ZIP="${OUTPUT:-${NAME}.zip}"
PREFABS="${NAME}.xml"
BIOME="${NAME}-biomes.png"
SPLAT3="${NAME}-splat3.png"
SPLAT4="${NAME}-splat4.png"
DTM_FILE="${NAME}-dtm.png"
COUNTY_FILE="${NAME}.txt"
GENERATION_INFO_FILE="${NAME}-GenerationInfo.txt"
MAP_INFO_FILE="${NAME}-map_info.xml"
SPAWN_FILE="${NAME}-spawnpoints.xml"
OPTS_FILE="${NAME}-options.txt"
HERE="${PWD}"

if [[ -z $COUNTY ]]; then
	if LINE=$( \
		grep -E 'WorldGenerator:Generating.*(Territory|County|Valley|Mountains)' \
			"${F7D2D}/log.txt" \
			| tail -1 \
			| tr -d $'\n\r' \
		); then
		COUNTY=$(cut -d ' ' -f 5- <<<"$LINE")
	else
		echo >&2 "Cannot figure out county name"
		COUNTY="Unknown"
	fi
fi

if [[ -z $WORLD ]]; then
	WORLD="$F7D2D/UserData/GeneratedWorlds/${COUNTY}"
fi

SECONDS=0
SINCE=0
timeIt() {
	declare duration
	duration=$((SECONDS - SINCE))
	echo >&2 "$1 in $duration seconds"
	SINCE=$SECONDS
}

echo >&2 "Saving preview for '${COUNTY}'"

cd "${WORLD}"
cp prefabs.xml "${PREFABS}"
cp spawnpoints.xml "${SPAWN_FILE}"

PREVIEW="$("${BIN}/drawMap.sh" "${SIZE}" "${SEED}" 43)"
timeIt "Map drawn"

if [[ ! -f "${HERE}/nodraw" ]]; then
	PREFABS_PREVIEW="$("${BIN}/drawPrefabs.sh" "${PREFABS}" "${PREVIEW}" "${SIZE}" "${SPAWN_FILE}")"
	timeIt "Prefabs drawn"
	# WATER_PREVIEW="$("${BIN}/drawWater.sh" water_info.xml "${PREFABS_PREVIEW}" "${SIZE}")"
	# timeIt "Water drawn"
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

declare -a BIOME_DIST_FILES
if [[ ! -f "${HERE}/nobiome" ]]; then
	convert biomes.png "${BIOME}"
	BIOME_COUNT=$("${BIN}/getBiomeDistribution.sh" "${PREFABS}" "${BIOME}" "${SIZE}" "${SEED}")
	BIOME_DIST_FILES=( "${BIOME}" "${BIOME_COUNT}" )
	timeIt "Biome distribution computed"
else
	BIOME_DIST_FILES=( )
	echo >&2 "Skipping biome and prefab biome distribution"
fi

declare -a SPLATS
if [[ ! -f "${HERE}/nosplat" ]]; then
	convert splat3.png "${SPLAT3}"
	convert splat4.png "${SPLAT4}"
	SPLATS=( "${SPLAT3}" "${SPLAT4}" )
	timeIt "Splat generated"
else
	SPLATS=( )
	echo >&2 "Skipping splat"
fi


if [[ ! -f "${HERE}/nocontour" ]]; then
	CONTOUR_FILE="$("${BIN}/drawContour.sh" "${SIZE}" "${SEED}")"
	timeIt "Contour generated"
else
	CONTOUR_FILE=""
fi

if [[ -f "${HERE}/savedtm" ]]; then
	cp dtm.png "${DTM_FILE}"
else
	DTM_FILE=""
fi

if [[ ${#OPTS[@]} -gt 0 ]]; then
	printf "%s\n" "${OPTS[@]}" > "${OPTS_FILE}"
else
	: > "${OPTS_FILE}"
fi

zip "${ZIP}" "${PREVIEW}" "${PREFABS}" "${SPAWN_FILE}" "${COUNTY_FILE}" \
	${THUMBNAIL:+"${THUMBNAIL}"} \
	"${GENERATION_INFO_FILE}" "${MAP_INFO_FILE}" "${OPTS_FILE}" \
	"${BIOME_DIST_FILES[@]}" \
	"${SPLATS[@]}" \
	${CONTOUR_FILE:+"${CONTOUR_FILE}"} \
	${DTM_FILE:+"${DTM_FILE}"}

if [[ -z ${OUTPUT} ]]; then
	mkdir -p "${F7D2D}/previews"
	mv "${ZIP}" "${F7D2D}/previews/"
fi

