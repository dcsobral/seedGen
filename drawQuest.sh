#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

if [[ $# -ne 3 ]]; then
        echo >&2 "$0 <prefabs.xml> <image> <size>"
        exit 1
fi

coordsFor() {
        declare -g tl br bl dim max_size
        declare COORDS DIM ROT
        COORDS="$1"
        DIM="$2"
        ROT="$3"

        WIDTH="${DIM%%,*}"
        HEIGHT="${DIM##*,}"

        if [[ $ROT =~ [13] ]]; then
                tmp="$WIDTH"
                WIDTH="$HEIGHT"
                HEIGHT="$tmp"
        fi

        X1=$((${COORDS%%,*} + CENTER))
        Z2=$((-(${COORDS##,*}) + CENTER))
        X2=$((X1 + WIDTH))
        Z1=$((Z2 - HEIGHT))

        tl="${X1},${Z1}"
        br="${X2},${Z2}"
	bl="${X1},${Z2}"
        dim="${WIDTH},${HEIGHT}"
	if [[ $WIDTH -ge $HEIGHT ]]; then
		max_size="${WIDTH}"
	else
		max_size="${HEIGHT}"
	fi
}

PREFABS="${F7D2D}/Data/Prefabs"
BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

XML="$1"
IMG="$2"
SIZE="$3"
CENTER="$((SIZE / 2))"
NAME="${XML%.xml}"
DRAW="draw-${NAME}.txt"
TRADERS="traders-${NAME}.txt"
GRID="grid-${NAME}.txt"
COORDS="coords-${NAME}.txt"
PREVIEW="quest-${IMG}"

declare -g -A DIM
declare -a MAPFILE

mapfile < <(xmlstarlet sel -t -m "/prefabs/decoration" -v "@name" -o ";" -v "@position" -o ";" -v "@rotation" -n "$XML")

echo "stroke black font Helvetica-Bold" > "${DRAW}"
echo "stroke-width 3 fill none stroke pink" > "${TRADERS}"
for decoration in "${MAPFILE[@]}"; do
        IFS=';' read  prefab coords rotation <<<"$decoration"

        if [[ -n ${DIM["$prefab"]+abc} ]]; then
                dim="${DIM["$prefab"]}"
        else
                dim="$("${BIN}/prefabSize.sh" "${prefab}")"
                DIM["$prefab"]="$dim"
        fi
        coordsFor "${coords}" "${dim}" "${rotation}"
        if [[ -f "${PREFABS}/${prefab}.xml" ]]; then
		tier="$(xmlstarlet sel -t -m "/prefab/property[@name='DifficultyTier']" -v @value "${PREFABS}/${prefab}.xml" || : )"
		mapfile -d , -t tags < <(xmlstarlet sel -t -m "/prefab/property[@name='QuestTags']" -v @value "${PREFABS}/${prefab}.xml" || : )
		key=""
		for tag in "${tags[@]}"; do
			key="${key}${tag[0]:0:1}"
		done
		desc="${key^^}${tier}"
		[[ -n $desc ]] && font_size=$((max_size / ${#desc} - 1))
		[[ -n $key && -n $tier ]] && echo "font-size ${font_size} text ${bl} '$desc'" >> "${DRAW}"
        fi
	if [[ $prefab == *trader* ]]; then
		echo "rectangle ${tl} ${br}" >> "${TRADERS}"
	fi
done

echo "stroke-width 2 stroke black fill white stroke-opacity 0.6 fill-opacity 0.6 stroke-dasharray 5 5" > "${GRID}"
echo "stroke-width 4 fill white stroke black stroke-opacity 0.6 fill-opacity 0.6" > "${COORDS}"
echo "font Helvetica-Bold font-size 48" >> "${COORDS}"
KMs=$((CENTER / 1000))
for km in $(seq "-$KMs" "$KMs"); do
	P=$((km * 1000 + CENTER))
	echo "path 'M 0,$P L $SIZE,$P'" >> "${GRID}"
	echo "path 'M $P,0 L $P,$SIZE'" >> "${GRID}"
	printf "text 4,$((P - 8)) '%2d'" $((-km)) >> "${COORDS}"
	echo "text $((P + 8)),$((SIZE - 8)) '$km'" >> "${COORDS}"
done

convert "${IMG}" \
	-draw "@${DRAW}" \
	-draw "@${TRADERS}" \
	-draw "@${GRID}" \
	-draw "@${COORDS}" \
	"${PREVIEW}"

echo "${PREVIEW}"

