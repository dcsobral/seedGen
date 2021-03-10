#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"
PREFABS="${F7D2D}/Data/Prefabs"

if [[ $# -eq 0 ]]; then
	echo >&2 "$0 <prefab>"
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
	if [[ "$prefab" =~ rwg_tile* ]]; then
		FILE="${PREFABS}/RWGTiles/${prefab}.tts"
	else
		FILE="${PREFABS}/${prefab}.tts"
	fi
	[[ -f "$FILE" ]] || FILE="$(find "${PREFABS}" -name "${prefab}.tts" -print)"
	mapfile -t COORDS < <(readUint16 "${FILE}" 8 3)
	X=${COORDS[0]}
	Y=${COORDS[1]}
	Z=${COORDS[2]}

	echo "$X,$Y,$Z"
done

