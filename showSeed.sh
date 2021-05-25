#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

if [[ $# -lt 1 ]]; then
	echo >&2 "$0 <seed>-<size>"
        exit 1
fi

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"
PREVIEWS="${F7D2D}/previews"
cd "${PREVIEWS}"

for name; do
	if [[ $name == *.xml ]]; then
		name="${name%.xml}"
	fi

	SIZE="${name##*-}"
	IMAGE="${SIZE}-previews/${name}.png"

	if [[ ! -f "$IMAGE" ]]; then
		mkdir -p "${SIZE}-previews"
		unzip "${name}.zip" "${name}.png" -d "${SIZE}-previews"
	fi

	cmd.exe /C start "" "$(wslpath -w "$IMAGE")"
done


