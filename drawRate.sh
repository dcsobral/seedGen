#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

if [[ $# -lt 2 || $# -gt 3 ]]; then
        echo >&2 "$0 <image> <size> [prefabs.xml]"
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
PREFABS="${3:-${IMG%.png}.xml}"
CENTER=$((SIZE / 2))
OUTPUT="rate-${IMG}"

if [[ -v RATE_OPTS && -n "${RATE_OPTS}" ]]; then
	IFS=' ' RATE_OPTS=( ${RATE_OPTS} )
else
	RATE_OPTS=( )
fi

IFS=' ' read -r score COORD RADIUS < <(${BIN}/rate.py "${RATE_OPTS[@]}" --quiet "${PREFABS}")
X="${COORD%%,*}"
Z="${COORD##*,}"
CX=$((CENTER + X))
CZ=$((CENTER - Z))

convert "${IMG}" \
	-fill 'rgba(255,255,255,0.2)' -stroke 'rgba(0,0,0,0.2)' -strokewidth 2 \
	-draw "$(printf 'circle %d,%d %d,%d' $((CX)) $((CZ)) $((CX + RADIUS)) $((CZ)))" \
	-fill Lime -stroke black -strokewidth 2 \
	-draw "$(printf "circle %d,%d %d,%d" $((CX)) $((CZ)) $((CX + 8)) $((CZ)))" \
	"${OUTPUT}"

echo "${OUTPUT}"

