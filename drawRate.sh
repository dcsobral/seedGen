#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

if [[ $# -ne 4 ]]; then
        echo >&2 "$0 <image> <size> <distance> <coord>"
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
RADIUS="$3"
COORD="$4"
CENTER=$((SIZE / 2))
X="${COORD%%,*}"
Z="${COORD##*,}"
CX=$((CENTER + X))
CZ=$((CENTER - Z))

convert "${IMG}" \
	-fill 'rgba(255,255,255,0.2)' -stroke 'rgba(0,0,0,0.2)' -strokewidth 2 \
	-draw "$(printf 'circle %d,%d %d,%d' $((CX)) $((CZ)) $((CX + RADIUS)) $((CZ)))" \
	-fill Lime -stroke black -strokewidth 2 \
	-draw "$(printf "circle %d,%d %d,%d" $((CX)) $((CZ)) $((CX + 8)) $((CZ)))" \
	"rate-${IMG}"

