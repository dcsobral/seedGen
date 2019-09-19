#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'


: "${F7D2D:=/mnt/c/Users/Daniel/Desktop/RH5.5Server}"

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

# sel -t -m "//Water" --sort a:n:- "str:tokenize(@pos, ',')[2]" -v @pos -n
mapfile -t < <(xmlstarlet sel -t -m "//Water" --sort a:n:- "str:tokenize(@pos, ',')[2]" -v @pos -n "$XML" )

cp "${IMG}" "${LAKEIMG}"
INDEX=0
while [[ $INDEX -lt ${#MAPFILE[@]} ]]; do
	IFS=", " read x y z <<<"${MAPFILE["$INDEX"]}"
	pixelLevel=$(((y + 1) * 256))
	convert -size "${DIM}" -depth 16 gray:dtm.raw -flip -threshold $pixelLevel watermask.png
	rm -f water.txt
	while [[ $INDEX -lt ${#MAPFILE[@]} && ${MAPFILE["$INDEX"]} == *,$y,* ]]; do
		IFS=", " read x _ignored z <<<"${MAPFILE["$INDEX"]}"
		x=$((x+CENTER))
		z=$((CENTER-z))
		level=$(convert -size "$DIM" -depth 16 "gray:dtm.raw" -flip \
				-format "%[fx:floor(256*s.p{$x,$z})]\n" info:)
		if [[ $level -le $pixelLevel ]]; then
			echo "color $x,$z floodfill" >> water.txt
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

#for coord in "${MAPFILE[@]}"; do
#	IFS=", " read x y z <<<"${coord}"
#	x=$((x+CENTER))
#	z=$((z+CENTER))
#	echo "$coord"; convert -size "$DIM" -depth 16 "gray:dtm.raw" -format "%[fx:256*s.p{$x,$z}]\n" info:
#done
#
#rm -f water.txt; for coord in "${MAPFILE[@]}"; do
#	IFS=", " read x y z <<<"${coord}"
#	x=$((x+CENTER))
#	z=$((CENTER-z))
#	echo "color $x,$z floodfill" >> water.txt
#done
#
#convert -size "${DIM}" -depth 16 gray:dtm.raw -flip -threshold $((0x2600)) watermask.png
#convert watermask.png -alpha on -fill blue -draw "@water.txt" -fill black -opaque white -transparent black lakes.png
#convert "${IMG}" lakes.png -composite "lakes-${IMG}"

