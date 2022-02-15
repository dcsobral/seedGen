#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

if [[ $# -ne 3 ]]; then
        echo >&2 "$0 <prefabs.xml> <biomes.png> <size>"
        exit 1
fi

coordsFor() {
        declare -g bl
        declare COORDS DIM ROT
        COORDS="$1"
        DIM="$2"
        ROT="$3"

        WIDTH="${DIM%%,*}"
        HEIGHT="${DIM##*,}"

	if [[ $((ROT % 2)) -eq 1 ]]; then
                tmp="$WIDTH"
                WIDTH="$HEIGHT"
                HEIGHT="$tmp"
        fi

        X1=$((${COORDS%%,*} + CENTER))
        Z2=$((-(${COORDS##,*}) + CENTER))

	bl="$((X1)),$((Z2))"
}

SECONDS=0
SINCE=0
timeIt() {
        declare duration
        duration=$((SECONDS - SINCE))
        echo >&2 "$1 in $duration seconds"
        SINCE=$SECONDS
}

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

XML="$1"
IMG="$2"
SIZE="$3"
IMGSIZE="${SIZE}x${SIZE}"
CENTER="$((SIZE / 2))"
NAME="${XML%.xml}"
MASK="mask-prefab-biome-${NAME}.txt"
BIOMES="prefab-biome-${NAME}.txt"

declare -A DIM
declare -A REVERSE
declare -a MAPFILE
declare -a COLORS

mapfile < <(
	xmlstarlet sel -t \
		-m "/prefabs/decoration" \
		-v "@name" -o ";" \
		-v "@position" -o ";" \
		-v "@rotation" -n \
		"$XML")

rm -f "${MASK}"
for decoration in "${MAPFILE[@]}"; do
        IFS=';' read -r prefab coords rotation <<<"$decoration"

        if [[ -n ${DIM["$prefab"]+abc} ]]; then
                dim="${DIM["$prefab"]}"
        else
                dim="$("${BIN}/prefabSize.sh" "${prefab}")"
                DIM["$prefab"]="$dim"
        fi
        coordsFor "${coords}" "${dim}" "${rotation}"

	if [[ -n ${REVERSE["${bl}"]+abc} ]]; then
		REVERSE["${bl}"]="${REVERSE["${bl}"]}${coords}"$'\n'
	else
		REVERSE["${bl}"]="${coords}"$'\n'
	fi

	echo "point ${bl}" >> "${MASK}"

done

timeIt "Biome per prefab: generated mask"

convert "$IMG" \
	\( -size "${IMGSIZE}" xc:black -fill white -draw "@${MASK}" -transparent white \) \
	-composite \
	-transparent black \
	sparse-color:"${BIOMES}"

mapfile -d ' ' -t COLORS <"${BIOMES}"

timeIt "Biome per prefab: extracted colors"

for coords_and_color in "${COLORS[@]}"; do
        IFS=',' read -r x z color <<<"$coords_and_color"

	case "${color}" in
		"srgba(0,64,0,1)")
			biome='forest'
			;;
		"srgba(186,0,255,1)")
			biome='burnt forest'
			;;
		"srgba(255,168,0,1)")
			biome='wasteland'
			;;
		"srgba(255,228,119,1)")
			biome='desert'
			;;
		white)
			biome='snow'
			;;
		*)
			echo >&2 "Biome color ${color} unknown for coords ${REVERSE["$x,$z"]}"
			biome=''
			;;
	esac

	if [[ -n $biome ]]; then
		mapfile -t coords <<<"${REVERSE["$x,$z"]}"
		for coord in "${coords[@]}"; do
			xmlstarlet ed -P -L \
				--append "/prefabs/decoration[@position='$coord']" \
				--type attr -n biome -v "${biome}" \
				"${XML}"
		done
	fi
done

timeIt "Biome per prefab: updated xml"

