#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"
cd "${F7D2D}/previews"

if [[ $# -lt 1 ]]; then
	# word splitting is intended
	# shellcheck disable=SC2046
	set -- $(compgen -f -X '!*.zip' | sed -nr '/-[0-9]+.zip/ s/.*-([0-9]+).zip/\1/p' | sort -u)
fi

for SIZE; do
	echo "Extracting ${SIZE}"
	mkdir -p "${SIZE}-previews"

	for map in *"${SIZE}.zip"; do
		if [[ ! -f ${SIZE}-previews/${map%.zip}.png && ! -f ${SIZE}-previews/${map%.zip}-m.png ]]; then
			unzip "$map" \
				"${map%.zip}.png" \
				"thumbs/${map%.zip}.png" \
				-d "${SIZE}-previews" ||
			unzip "$map" \
				"${map%.zip}-m.png" \
				"thumbs/${map%.zip}-m.png" \
				-d "${SIZE}-previews"

		fi
	done
done

