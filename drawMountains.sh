#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

if [[ $# -ne 1 ]]; then
	echo >&2 "$0 <size>"
	exit 1
fi

SIZE="${1}"
IMGSIZE="${SIZE}x${SIZE}"
MOUNTAIN="mountains.png"

[[ ! -f dtm.png ]] && convert -size "${IMGSIZE}" -depth 16 gray:dtm.raw -flip dtm.png

# Produces a pattern of brightness going up and shadow going down from NE to SW

MOUNTAINS=( $( convert dtm.png \
	-alpha off -virtual-pixel Edge \
	\( -clone 0 -morphology Convolve '3x3+1+1: nan,0.71,1 -0.71,0,0.71 -1,-0.71,nan' \) \
	\( -clone 0 -morphology Convolve '3x3+1+1: nan,-0.71,-1 0.71,0,-0.71 1,0.71,nan' \) \
	-delete 0 \
	-depth 8 \
	-modulate 2000 \
	-format "%o\n" -verbose -identify \
	"${MOUNTAIN}" 2>&1 > /dev/null | sed -nEe 's/.*=>(.*)\[.*/\1/p'
) )

echo "${MOUNTAINS[@]}"

