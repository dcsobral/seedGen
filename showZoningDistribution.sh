#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

if [[ $# -lt 1 ]]; then
	echo >&2 "$0 <seed>-<size>"
        exit 1
fi

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

simplifyZone() {
	in="$1"
	case "$in" in
		"commercial downtown industrial")
			echo "Commercial/Industrial"
			;;
		"downtown residentialnew")
			echo "Residential"
			;;
		"downtown residentialnew residentialold")
			echo "Residential"
			;;
		"residentialnew residentialold")
			echo "Residential"
			;;
		"downtown resdentialold residentialnew")
			echo "Residential"
			;;
		"commercial downtown")
			echo "Commercial"
			;;
		"residentialnew")
			echo "Residential"
			;;
		"industrial residentialnew residentialold")
			echo "Industrial/Residential"
			;;
		"industrial residential")
			echo "Industrial/Residential"
			;;
		"nozone")
			echo "Wilderness"
			;;
		"residentialold")
			echo "Residential"
			;;
		"industrial residentialold")
			echo "Industrial/Residential"
			;;
		"commercial residentialnew")
			echo "Commercial/Residential"
			;;
		"")
			echo "Wilderness"
			;;
		*)
			echo "${in^}"
			;;
	esac
}

getZone() {
	"${BIN}/zoning.sh" "$1" | \
		cut -d $'\t' -f 1 | \
		tr -d ' ' | \
		tr '[:upper:]' '[:lower:]' | \
		tr ',' $'\n' | \
		sort | \
		xargs
}

printStats() {
	declare -A ZONE
	declare -A COUNT
	declare TOTAL XML prefab zone sortedZones
	XML="$1"
	TOTAL=0
	mapfile -t < <(xmlstarlet sel -t -m "/prefabs/decoration" -v "@name" -n - <<< "$XML")
	for prefab in "${MAPFILE[@]}"; do
		if [[ -n ${ZONE["$prefab"]+abc} ]]; then
			zone="${ZONE["$prefab"]}"
		else
			zone="$(getZone "$prefab")"
			zone="$(simplifyZone "$zone")"
			ZONE["$prefab"]="$zone"
		fi
		TOTAL=$((TOTAL + 1))
		COUNT["$zone"]=$((${COUNT["$zone"]:-0} + 1))
	done

	mapfile -t sortedZones < <(printf "%s\n" "${!COUNT[@]}" | sort)
	for zone in "${sortedZones[@]}"; do
		printf "%s\t%2d%%\n" "$zone" $((${COUNT["$zone"]} * 100 / TOTAL))
	done
}

for name; do
	FILE="${name%.xml}.xml"
	if [[ -f "$FILE" ]]; then
		XML="$(< "$FILE" )"
	elif [[ -n "${F7D2D:+yes}" && -f "${F7D2D}/previews/$name.zip" ]]; then
		XML="$(unzip -qq -c "${F7D2D}/previews/$name.zip" "${FILE}")"
	else
		echo >&2 "$FILE not found"
		continue

	fi

	if [[ -t 1 ]]; then
		printStats "$XML" | column -t -s $'\t'
	else
		printStats "$XML"
	fi
done

