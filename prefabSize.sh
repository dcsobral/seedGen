#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:=/mnt/c/Users/Daniel/Desktop/RH5.5Server}"
PREFABS="${F7D2D}/Data/Prefabs"

if [[ $# -eq 0 ]]; then
	echo >&2 "$0 <prefab.tts>"
	exit 1
fi

readValues() {
	file="$1"
	offset="$2"
	length="$3"
	xxd -c1 -p "-l${3:-1}" -s "$offset" "$file"
}

toUint16() {
	while [[ $# -gt 1 ]]; do
		LSB=$((16#$1))
		MSB=$((16#$2))
		echo $((LSB + 256 * MSB))
		shift 2
	done
}

readUint16() {
	file="$1"
	offset="$2"
	length=$((${3:-1} * 2))
	mapfile -t < <(readValues "$file" "$offset" "$length")
	toUint16 "${MAPFILE[@]}"
}

for prefab; do
	mapfile -t COORDS < <(readUint16 "$PREFABS/$prefab.tts" 8 3)
	X=${COORDS[0]}
	Y=${COORDS[1]}
	Z=${COORDS[2]}

	echo "$X,$Y,$Z"
done

