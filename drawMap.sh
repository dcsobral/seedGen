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
PREVIEW="${NAME}.png"

convert \( biomes.png \
		-fill '#949442' -opaque '#ffa800' \
		-fill '#393931' -opaque '#ba00ff' \
	\) \
	\( splat3.png \
		-alpha off -transparent black \
		-fill '#9c8c7b' -opaque '#00ff00' \
		-fill '#ceb584' -opaque '#fe0000' \
	\) \
	-composite \
	\( -size "${IMGSIZE}" -depth 16 gray:dtm.raw -flip -auto-level \) \
	-compose blend -set option:compose:args 50 -composite \
	\( radiation.png \
		-channel rgba -fill "rgba(255,0,0,0.5)" -opaque "rgb(255,0,0)" +channel  \
		-transparent black \
		-resize "${IMGSIZE}" \
	\) \
	-compose Over -composite \
	"${PREVIEW}"

echo "${PREVIEW}"

