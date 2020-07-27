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

	cd "${SIZE}-previews"
	DIM=$((SIZE / 16))
	rm -fr thumbs
	mkdir thumbs
	mogrify -format png -depth 8 -path thumbs -resize "${DIM}x${DIM}" "*-${SIZE}.png"
	montage -title "Size ${SIZE} Seeds" -geometry "+4+3" -pointsize 16 -label '%c' "thumbs/*.png" "${SIZE}.png"
	cd ..
done

popd

