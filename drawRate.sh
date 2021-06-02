#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

if [[ $# -ne 5 ]]; then
        echo >&2 "$0 <image> <size> <precision> <diameter> <coord>"
        exit 1
fi

coordsFor() {
        WIDTH="${DIM%%,*}"
        HEIGHT="${DIM##*,}"
}

PREFABS="${F7D2D}/Data/Prefabs"
BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

IMG="$1"
SIZE="$2"
PRECISION="$3"
DIAMETER="$4"
COORD="$5"
CENTER=$((SIZE / 2))
RADIUS=$((PRECISION * DIAMETER / 2))
X="${COORD%%,*}"
Z="${COORD##*,}"
CX=$((CENTER + X))
CZ=$((CENTER - Z))

convert "${IMG}" \
	-fill none -stroke 'rgba(178,34,34,0.5)' -strokewidth 8 \
	-draw "$(printf 'circle %d,%d %d,%d' $((CX)) $((CZ)) $((CX + RADIUS)) $((CZ)))" \
	-fill Lime \
	-draw "$(printf "circle %d,%d %d,%d" $((CX)) $((CZ)) $((CX + 8)) $((CZ)))" \
	"circle-${IMG}"

convert "${IMG}" \
	-fill none -stroke 'rgba(178,34,34,0.5)' -strokewidth 8 \
	-draw "$(printf 'rectangle %d,%d %d,%d' $((CX - RADIUS)) $((CZ - RADIUS)) $((CX + RADIUS)) $((CZ + RADIUS)))" \
	-fill Lime \
	-draw "$(printf "circle %d,%d %d,%d" $((CX)) $((CZ)) $((CX + 8)) $((CZ)))" \
	"square-${IMG}"

convert "${IMG}" \
	-fill 'rgba(178,34,34,0.5)' \
	-draw "$(printf 'rectangle %d,%d %d,%d' $((CX - RADIUS)) $((CZ - RADIUS)) $((CX + RADIUS)) $((CZ + RADIUS)))" \
	-fill Lime \
	-draw "$(printf "circle %d,%d %d,%d" $((CX)) $((CZ)) $((CX + 8)) $((CZ)))" \
	"square-filled-${IMG}"


