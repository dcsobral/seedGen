#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

cd "${F7D2D}/previews"

if [[ $# -lt 1 ]]; then
	# word splitting is intended
	# shellcheck disable=SC2046
	set -- $(compgen -f -X '!*.zip' | sed -nr '/-'"$2"'[0-9]+.zip/ s/.*-([0-9]+).zip/\1/p' | sort -u)
fi

for SIZE; do
	echo "Extracting ${SIZE}"
	mkdir -p "${SIZE}"

	for map in *"${SIZE}.zip"; do
		[[ -f ${SIZE}/${map%.zip}.xml ]] || unzip "$map" "${map%.zip}.xml" -d "${SIZE}"
	done
done

