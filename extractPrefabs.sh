#!/usr/bin/env bash

if [[ $# -lt 1 ]]; then
	echo >&2 "$0 <size>"
	exit 1
fi

for SIZE; do
	echo "Extracting ${SIZE}"
	mkdir -p "${SIZE}"

	for map in *"${SIZE}.zip"; do
		[[ -f ${SIZE}/${map%.zip}.xml ]] || unzip "$map" "${map%.zip}.xml" -d "${SIZE}"
	done
done

