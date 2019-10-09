#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'


if [[ $# -ne 3 ]]; then
        echo >&2 "$0 <water_info.xml> <image> <size>"
        exit 1
fi

XML="$1"
IMG="$2"
SIZE="$3"
DIM="${SIZE}x${SIZE}"
CENTER="$((SIZE / 2))"
WATER_IMG="water-${IMG}"
TMPIMG="tmp-${IMG}"

mapfile -t < <(xmlstarlet sel -t -m "//Water" --sort a:n:- "str:tokenize(@pos, ',')[2]" -v @pos -n "$XML" )

cp "${IMG}" "${WATER_IMG}"
INDEX=0
while [[ $INDEX -lt ${#MAPFILE[@]} ]]; do
	IFS=", " read x y z <<<"${MAPFILE["$INDEX"]}"
	pixelLevel=$((y * 256 + 128))
	convert -size "${DIM}" -depth 16 gray:dtm.raw -flip \
		-threshold $pixelLevel \
		\( ${WATER_IMG} +transparent '#738cce' -fill white -opaque '#738cce' \) \
		-composite watermask.png
	rm -f water.txt
	touch water.txt
	PATTERN='.*, *'"$y"' *,.*'
	COUNT=0
	while [[ $INDEX -lt ${#MAPFILE[@]} && $COUNT -lt 10  && ${MAPFILE["$INDEX"]} =~ $PATTERN ]]; do
		IFS=", " read x _ignored z <<<"${MAPFILE["$INDEX"]}"
		xabs=$((x+CENTER))
		zabs=$((CENTER-z))
#		color=$(convert "${WATER_IMG}" -format "%[pixel:p{${xabs},${zabs}}]" info:-)
#		if [[ $color != 'srgba(115,140,206,1)' ]]; then
			level=$(convert watermask.png -format "%[pixel:p{${xabs},${zabs}}]" info:-)
			if [[ $level == 'gray(0)' ]]; then
				echo "color $xabs,$zabs floodfill" >> water.txt
				COUNT=$((COUNT + 1))
#			else
#				printf >&2 "Requested level %04x >= %04x at %d,%d\n" \
#					"$level" "$pixelLevel" "$x" "$z"
			fi
#		fi
		INDEX=$((INDEX + 1))
		if [[ $((INDEX % 100)) -eq 0 ]]; then
			echo >&2 "$INDEX/${#MAPFILE[@]} completed"
		fi
	done
	convert watermask.png \
		-alpha on \
		-fill '#738cce' \
		-draw "@water.txt" \
		-fill black \
		-opaque white \
		-transparent black lakes.png
	convert "${WATER_IMG}" lakes.png -composite "${TMPIMG}"
	mv "${TMPIMG}" "${WATER_IMG}"
	echo >&2 "$INDEX/${#MAPFILE[@]} completed"
done

echo "${WATER_IMG}"
