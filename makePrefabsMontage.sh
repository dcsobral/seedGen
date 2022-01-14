#!/usr/bin/env bash

mapfile -t < <(listAllPrefabs.sh)

POI_FOLDER="${F7D2D}/Data/Prefabs/POIs"

cd "${POI_FOLDER}"

for p in "${MAPFILE[@]}"; do
	[[ -f "${p}.jpg" ]] && ps+=("$p")
done

montage -geometry '280x210<+4+3' $(
	for p in "${ps[@]}"; do
		echo "-label $p $p.jpg"
	done) -title "Prefabs" -depth 8 prefabs.png


echo "${POI_FOLDER}/prefabs.png"

