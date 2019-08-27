#!/usr/bin/env bash

: "${F7D2D:=/mnt/c/Users/Daniel/Desktop/RH5.5Server}"
PREFABS="${F7D2D}/Data/Prefabs"

if [[ $# -eq 0 ]]; then
	echo >&2 "$0 <prefab_name>"
	exit 1
fi

for prefab; do
	xmlstarlet sel -t -m /prefab -v "property[@name='Zoning']/@value" \
		-o $'\t' -v "property[@name='AllowedBiomes']/@value" -n \
		"$PREFABS/$prefab.xml"
done

