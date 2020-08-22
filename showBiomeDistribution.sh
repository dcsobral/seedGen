#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

if [[ $# -lt 1 ]]; then
	echo >&2 "$0 <seed>-<size>"
        exit 1
fi

printHistogram() {
	declare TOTAL_AREA=0
	declare TOTAL_COUNT=0
	declare line biome count area perc_count perc_area
	mapfile -t -s 1

	for line in "${MAPFILE[@]}"; do
		IFS=',' read -r _ count area <<<"$line"
		TOTAL_AREA=$((TOTAL_AREA + area))
		TOTAL_COUNT=$((TOTAL_COUNT + count))
	done

	echo $'Biome\tCount\t  %\tArea\t  %'
	for line in "${MAPFILE[@]}"; do
		IFS=',' read -r biome count area <<<"$line"
		perc_area=$((area * 1000 / TOTAL_AREA))
		perc_count=$((count * 1000 / TOTAL_COUNT))
		# round up & down
		perc_area=$(((perc_area + 5) / 10))
		perc_count=$(((perc_count + 5) / 10))
		printf "%s\t%5d\t%3d\t%8d\t%3d\n" "$biome" "$count" "$perc_count" "$area" "${perc_area}"
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
		printHistogram <<< "$HIST" | column -t -s $'\t'
	else
		printHistogram <<< "$HIST"
	fi
done

