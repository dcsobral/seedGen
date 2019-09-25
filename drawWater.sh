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
LAKEIMG="lakes-${IMG}"
TMPIMG="tmp=${IMG}"

mapfile -t < <(xmlstarlet sel -t -m "//Water" --sort a:n:- "str:tokenize(@pos, ',')[2]" -v @pos -n "$XML" )

cp "${IMG}" "${LAKEIMG}"
INDEX=0
while [[ $INDEX -lt ${#MAPFILE[@]} ]]; do
	IFS=", " read x y z <<<"${MAPFILE["$INDEX"]}"
	pixelLevel=$((y * 256 + 128))
	convert -size "${DIM}" -depth 16 gray:dtm.raw -flip -threshold $pixelLevel watermask.png
	rm -f water.txt
	while [[ $INDEX -lt ${#MAPFILE[@]} && ${MAPFILE["$INDEX"]} == *,$y,* ]]; do
		IFS=", " read x _ignored z <<<"${MAPFILE["$INDEX"]}"
		xabs=$((x+CENTER))
		zabs=$((CENTER-z))
		level=$(convert -size "$DIM" -depth 16 "gray:dtm.raw" -flip \
				-format "%[fx:round(65536*s.p{$xabs,$zabs})]\n" info:)
		if [[ $level -le $pixelLevel ]]; then
			echo "color $xabs,$zabs floodfill" >> water.txt
		else
			printf >&2 "Requested level %04x greater or equal than %04x at %d,%d" \
				"$level" "$pixelLevel" "$x" "$z"
		fi
		INDEX=$((INDEX + 1))
	done
	convert watermask.png \
		-alpha on \
		-fill blue \
		-draw "@water.txt" \
		-fill black \
		-opaque white \
		-transparent black lakes.png
	convert "${LAKEIMG}" lakes.png -composite "${TMPIMG}"
	mv "${TMPIMG}" "${LAKEIMG}"
done

