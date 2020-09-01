#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

if [[ $# -lt 2 || $# -gt 3 ]]; then
	echo >&2 "$0 <size> <seed> [<water_level>]"
	exit 1
fi

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIZE="${1}"
IMGSIZE="${SIZE}x${SIZE}"
SEED="${2}"
LEVEL="${3:-0}"
NAME="${SEED}-${SIZE}"
PREVIEW="${NAME}-m.png"
THRESHOLD=$((LEVEL * 256 + 128))

declare -a OPTIONAL

optional() {
	OPTIONAL=( "$@" )
}

[[ ! -f dtm.png ]] && convert -size "${IMGSIZE}" -depth 16 gray:dtm.raw -flip dtm.png

[[ ! -f biomemap.png ]] && convert biomes.png \
	-fill '#949442' -opaque '#ffa800' \
	-fill '#393931' -opaque '#ba00ff' \
	-fill '#c3c4d9' -opaque '#ffffff' \
	biomemap.png

[[ ! -f splatmap.png ]] && convert splat3.png \
	-alpha off -transparent black \
	-fill '#9c8c7b' -opaque '#00ff00' \
	-fill '#ceb584' -opaque '#ff0000' \
	splatmap.png

[[ ! -f watermap.png && $# -eq 3 ]] && convert dtm.png \
	-threshold $THRESHOLD \
	-transparent white \
	-fill '#738cce' -opaque black \
	watermap.png

[[ ! -f radiationmap.png ]] && convert radiation.png \
	-channel rgba -fill "rgba(255,0,0,0.7)" -opaque "rgb(255,0,0)" +channel  \
	-transparent black \
	-scale "${IMGSIZE}" \
	radiationmap.png

IFS=$' \t\n' MOUNTAINS=( $( "${BIN}/drawMountains.sh" "$SIZE" ) )

if [[ $# -eq 3 ]]; then
	optional \
		watermap.png \
		-compose Over -composite
else
	optional
fi

convert biomemap.png \
	splatmap.png -composite \
	"${MOUNTAINS[0]}" -compose screen -composite \
	\( "${MOUNTAINS[1]}" -negate \) -compose multiply -composite \
	"${OPTIONAL[@]}" \
	radiationmap.png -compose Over -composite \
	-depth 8 \
	-set comment "${SEED}" \
	"${PREVIEW}"

echo "${PREVIEW}"

