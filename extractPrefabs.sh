#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
	echo >&2 "$0 <size>"
	exit 1
fi

SIZE="$1"

mkdir -p "${SIZE}"

for map in *"${SIZE}.zip"; do
	[[ -f ${SIZE}/${map%.zip}.xml ]] || unzip $map ${map%.zip}.xml -d ${SIZE}
done

