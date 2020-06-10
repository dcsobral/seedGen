#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

if [[ $# -lt 2 || $# -gt 3 ]]; then
	echo >&2 "$0 <size> <seed> [<water_level>]"
	exit 1
fi

SIZE="${1}"
IMGSIZE="${SIZE}x${SIZE}"
SEED="${2}"
LEVEL="${3:-0}"
NAME="${SEED}-${SIZE}"
PREVIEW="${NAME}.png"
THRESHOLD=$((LEVEL * 256 + 128))

declare -a OPTIONAL

optional() {
	OPTIONAL=( "$@" )
}

if [[ $# -eq 3 ]]; then
	optional \
		\( -size "${IMGSIZE}" -depth 16 gray:dtm.raw -flip \
			-threshold $THRESHOLD \
			-transparent white \
			-fill '#738cce' -opaque black \
		\) \
		-compose Over -composite
else
	optional
fi

convert \( biomes.png \
		-fill '#949442' -opaque '#ffa800' \
		-fill '#393931' -opaque '#ba00ff' \
	\) \
	\( splat3.png \
		-alpha off -transparent black \
		-fill '#9c8c7b' -opaque '#00ff00' \
		-fill '#ceb584' -opaque '#ff0000' \
	\) \
	-composite \
	\( -size "${IMGSIZE}" -depth 16 gray:dtm.raw -flip -black-threshold $THRESHOLD -auto-level \) \
	+swap -compose multiply -composite \
	"${OPTIONAL[@]}" \
	\( radiation.png \
		-channel rgba -fill "rgba(255,0,0,0.9)" -opaque "rgb(255,0,0)" +channel  \
		-transparent black \
		-resize "${IMGSIZE}" \
	\) \
	-compose Over -composite \
	-depth 8 \
	"${PREVIEW}"

echo "${PREVIEW}"

# convert prefabs-EthosMount-8192.png -sigmoidal-contrast 5x1% EthosMount.png

