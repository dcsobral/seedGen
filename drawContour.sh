#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

if [[ $# -ne 2 ]]; then
	echo >&2 "$0 <size> <seed>"
	exit 1
fi

SIZE="${1}"
IMGSIZE="${SIZE}x${SIZE}"
SEED="${2}"
NAME="${SEED}-${SIZE}"
CONTOUR="${NAME}-contour.png"

[[ ! -f dtm.png ]] && convert -size "${IMGSIZE}" -depth 16 gray:dtm.raw -flip dtm.png

# Contour lines
#convert biomes.png \
#	-fill '#949442' -opaque '#ffa800' \
#	-fill '#393931' -opaque '#ba00ff' \
#        -threshold 50% bw.png
convert dtm.png -depth 8 \
	\( -size 1x500 gradient: -rotate 90 -duplicate 49 +append +repage \) \
	-clut -morphology edgein diamond:1 -threshold 40% contour.png
#convert contour.png bw.png -compose Plus -composite \
#	\( bw.png -negate \) -compose Multiply -composite \
#	-transparent black plus.png
#convert contour.png bw.png -compose Subtract -composite -negate \
#	bw.png -compose Multiply -composite \
#	-negate -transparent white sub.png
#convert plus.png sub.png -composite "${CONTOUR}"
convert contour.png -transparent black "${CONTOUR}"

echo "${CONTOUR}"

