#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

if [[ $# -ne 1 ]]; then
	echo >&2 "$0 <prefab.tts>"
	exit 1
fi

readValue() {
	file="$1"
	offset="$2"
	echo $((16#$(xxd -p -l1 -s $offset "$file")))
}

readUint16() {
	file="$1"
	offset="$2"
	LSB=$(readValue "$file" "$offset")
	MSB=$(readValue "$file" $((offset + 1)))
	echo $((LSB + 256 * MSB))
}

X=$(readUint16 "$1" 8)
Y=$(readUint16 "$1" 10)
Z=$(readUint16 "$1" 12)

echo "$X,$Y,$Z"

