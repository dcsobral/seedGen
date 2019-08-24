#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

if [[ $# -lt 3 ]]; then
	echo >&2 "$0 <prefab_name> <prefab_coords> <rotation> <map-size>"
	exit 1
fi

PREFABS="../../Data/Prefabs"
BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFAB="$1"
LOC="$2"
ROT="$3"
SIZE="${4:-4096}"

DIM="$("${BIN}/prefabSize.sh" "${PREFABS}/${PREFAB}.tts")"

"${BIN}/coordsFor.sh" "${LOC}" "${DIM}" "${ROT}" "${SIZE}"

