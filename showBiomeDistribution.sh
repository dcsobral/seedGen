#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

if [[ $# -lt 1 ]]; then
	echo >&2 "$0 <seed>-<size>"
        exit 1
fi

printHistogram() {
	declare FORMAT="$1"
	declare TOTAL_AREA=0
	declare TOTAL_COUNT=0
	declare TOTAL_BIOME_AREA=0
	declare line biome count area biome_area perc_count perc_area
	mapfile -t -s 1

	for line in "${MAPFILE[@]}"; do
		IFS=',' read -r _ count area biome_area <<<"$line"
		TOTAL_AREA=$((TOTAL_AREA + area))
		TOTAL_COUNT=$((TOTAL_COUNT + count))
		TOTAL_BIOME_AREA=$((TOTAL_BIOME_AREA + biome_area))
	done

	[[ $TOTAL_AREA -eq 0 ]] && TOTAL_AREA=1
	[[ $TOTAL_COUNT -eq 0 ]] && TOTAL_COUNT=1
	[[ $TOTAL_BIOME_AREA -eq 0 ]] && TOTAL_BIOME_AREA=1

	echo $'Biome\tPrefabs\t  %\tPrefab Area\t  %\tArea\t  %'
	for line in "${MAPFILE[@]}"; do
		IFS=',' read -r biome count area biome_area <<<"$line"
		perc_area=$((area * 1000 / TOTAL_AREA))
		perc_count=$((count * 1000 / TOTAL_COUNT))
		perc_biome_area=$((biome_area * 1000 / TOTAL_BIOME_AREA))

		# round up & down
		perc_area=$(((perc_area + 5) / 10))
		perc_count=$(((perc_count + 5) / 10))
		perc_biome_area=$(((perc_biome_area + 5) / 10))

		#shellcheck disable=SC2059
		printf "$FORMAT" \
			"$biome" \
			"$count" "$perc_count" \
			"$area" "$perc_area" \
			"$biome_area" "$perc_biome_area"
	done
}

for name; do
	FILE="${name}-biome-count.txt" 
	if [[ -f "$FILE" ]]; then
		HIST="$(< "$FILE" )"
	elif [[ -n "${F7D2D:+yes}" && -f "${F7D2D}/previews/$name.zip" ]]; then
		HIST="$(unzip -qq -c "${F7D2D}/previews/$name.zip" "${FILE}")"
	else
		echo >&2 "$FILE not found"
		continue

	fi

	if [[ -t 1 ]]; then
		printHistogram "%s\t%'6d\t%3d\t%'10d\t%3d\t%'11d\t%3d\n" <<< "$HIST" \
			| column -t -s $'\t'
	else
		printHistogram "%s\t%d\t%d\t%d\t%d\t%d\t%d\n" <<< "$HIST"
	fi
done

