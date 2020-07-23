#!/usr/bin/env bash

pushd "${F7D2D}/previews"

if [[ $# -lt 1 ]]; then
	set -- $(compgen -f -X '!*.zip' | sed -nr '/-'"$2"'[0-9]+.zip/ s/.*-([0-9]+).zip/\1/p' | sort -u)
fi

for SIZE; do
	echo "Extracting ${SIZE}"
	mkdir -p "${SIZE}"

	for map in *"${SIZE}.zip"; do
		[[ -f ${SIZE}-previews/${map%.zip}.png ]] || unzip "$map" "${map%.zip}.png" -d "${SIZE}-previews"
	done

	pushd "${SIZE}-previews"
	montage -label '%c' -title "Size ${SIZE} Seeds" "*-${SIZE}.png" "${SIZE}.png"
	popd
done

popd

