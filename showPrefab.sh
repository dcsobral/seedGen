#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"
PREFABS="${F7D2D}/Data/Prefabs"

if [[ $# -eq 0 ]]; then
	echo >&2 "$0 <prefab>"
	exit 1
fi



for prefab; do
	cmd.exe /C start "" "$(wslpath -w "$PREFABS/$prefab.jpg")"
done

