#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

if [[ $# -ne 2 ]]; then
	echo >&2 "$0 <prefabs.xml> <size>"
	exit 1
fi

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

XML="$1"
SIZE="$2"
DRAW="draw-${XML%.xml}.txt"
declare -g -A DIM

mapfile < <(xmlstarlet sel -t -m "/prefabs/decoration" -v "@name" -o ";" -v "@position" -o ";" -v "@rotation" -n "$XML")

rm -f "${DRAW}"
for decoration in "${MAPFILE[@]}"; do
	IFS=';' read  prefab coords rotation <<<"$decoration"

	if [[ -n ${DIM["$prefab"]+abc} ]]; then
		dim="${DIM["$prefab"]}"
	else
		dim="$("${BIN}/prefabSize.sh" "${prefab}")"
		DIM["$prefab"]="$dim"
	fi
	IFS=';' read tl br dim < <("${BIN}/coordsFor.sh" "${coords}" "${dim}" "${rotation}" "${SIZE}")
	echo "rectangle ${tl} ${br}" >> "${DRAW}"
done

convert -size "${SIZE}x${SIZE}" xc:black -transparent black -strokewidth 0 -fill white -draw "@${DRAW}" "mask-${XML%.xml}.tga"

