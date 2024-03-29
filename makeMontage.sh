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

for SIZE; do (
	echo "Generating thumbnail montage for ${SIZE}"
	cd "${SIZE}-previews"

	DIM=$((SIZE / 16))
	if [[ ! -d thumbs ]]; then
		mkdir thumbs
		mogrify -format png \
			-depth 8 \
			-path thumbs \
			-resize "${DIM}x${DIM}" \
			"*-${SIZE}.png" "*-${SIZE}-m.png"
	fi

	#shellcheck disable=SC2012
	COUNT="$(ls thumbs | wc -l || echo 0)"
	if [[ $COUNT -gt 20 ]]; then
		echo "Generating multiple montages"
		TILING=( "-tile" "5x4" )
	else
		TILING=( )
	fi

	montage -title "Size ${SIZE} Seeds" \
		-geometry "+4+3" \
		-pointsize 16 -label '%c' \
		"thumbs/*.png" \
		"${TILING[@]}" \
		"${SIZE}.png"
	)
done

