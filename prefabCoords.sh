#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

if [[ $# -ne 4 ]]; then
	echo >&2 "$0 <prefab_name> <prefab_coords> <rotation> <map-size>"
	exit 1
fi

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFAB="$1"
LOC="$2"
ROT="$3"
SIZE="$4"

DIM="$("${BIN}/prefabSize.sh" "${PREFAB}")"

"${BIN}/coordsFor.sh" "${LOC}" "${DIM}" "${ROT}" "${SIZE}"

