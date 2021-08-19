#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"
PREFABS="${F7D2D}/Data/Prefabs"

if [[ $# -eq 0 ]]; then
        echo >&2 "$0 <prefab_name>"
        exit 1
fi

declare -a zones

# TODO: make zones an associative array instead?
hasZone() {
	local IFS='|'
	PATTERN="($*)"
	IFS=$','
	if [[ ",${zones[*]}," =~ ,${PATTERN}, ]]; then
		return 0
	else
		return 1
	fi
}

for prefab; do
	zones=()

	if [[ $prefab == *field* ]]; then
		zones+=(crop)
	fi

        if [[ "$prefab" =~ rwg_tile* ]]; then
		prefabZone="${prefab#rwg_tile_}"
		if [[ $prefabZone == wasteland* ]]; then
			zones+=(wasteland)
			prefabZone="${prefabZone#wasteland}"
		fi
		case "${prefabZone}" in
			citycenter*)
				zones+=(citycenter)
				;;
			downtown*)
				zones+=(downtown)
				;;
			commercial*)
				zones+=(commercial)
				;;
			countryresidential*)
				zones+=(countryresidential)
				;;
			countrytown*)
				zones+=(countrytown)
				;;
			rural*)
				zones+=(rural)
				;;
			residential*)
				zones+=(residential)
				;;
			ghosttown* | oldwest*)
				zones+=(oldwest)
				;;
			industrial*)
				zones+=(industrial)
				;;
			*)
				zones+=(any)
				;;
		esac
		FILE="${PREFABS}/RWGTiles/${prefab}.xml"
	else
		FILE="${PREFABS}/POIs/${prefab}.xml"
	fi

	[[ -f "${FILE}" ]] || FILE="$(find "${PREFABS}" -name "${prefab}.xml" -print)"
	mapfile -d ' ' -O ${#zones[@]} -t zones < <(xmlstarlet sel -t -m /prefab -v "property[@name='Tags']/@value" \
		"${FILE}" | tr '[:upper:],' '[:lower:] ' || :)

	# Existing tags:
	# citycenter x
	# commercial x
	# countryresidential x
	# countrytown x -- smaller than city and town
	# downtown x
	# industrial x
	# oldwest x
	# residential x
	# rural x -- outskirt of cities and towns (but not countrytown)
	# test
	# trader x
	# wastelandcommercial x
	# wastelandcountryresidential x
	# wastelandcountrytown x
	# wastelanddowntown x
	# wastelandindustrial x
	# wastelandresidential x
	# wilderness x

	# Preempt any other zones
	if hasZone trader; then
		echo magenta
		continue
	elif hasZone crop; then
		echo olive
		continue
	elif hasZone any; then
		echo white
		continue
	elif hasZone oldwest; then
		echo saddlebrown
		continue
	fi

	# Zones used in combos for special colors
	hasZone residential && RESIDENTIAL_NEW=1 || RESIDENTIAL_NEW=""
	hasZone countryresidential && RESIDENTIAL_OLD=1 || RESIDENTIAL_OLD=""
	hasZone residential countryresidential && RESIDENTIAL=1 || RESIDENTIAL=""
	hasZone industrial && INDUSTRIAL=1 || INDUSTRIAL=""
	hasZone commercial && COMMERCIAL=1 || COMMERCIAL=""
	hasZone downtown citycenter && DOWNTOWN=1 || DOWNTOWN=""

	# First match wins
	if [[ -n $DOWNTOWN && -n $COMMERCIAL && -n $INDUSTRIAL ]]; then echo orange
	elif [[ -n $DOWNTOWN && -n $RESIDENTIAL ]]; then echo teal
	elif [[ -n $DOWNTOWN && -n $COMMERCIAL ]]; then echo slategray
	elif [[ -n $DOWNTOWN ]]; then echo gray
	elif [[ -n $RESIDENTIAL_NEW ]]; then echo chartreuse
	elif [[ -n $RESIDENTIAL_OLD ]]; then echo green
	elif [[ -n $COMMERCIAL ]]; then echo blue
	elif [[ -n $INDUSTRIAL ]]; then echo yellow
	elif hasZone rural; then echo olivedrab
	elif hasZone countrytown; then echo sandybrown
	elif hasZone wilderness; then echo saddlebrown
	else echo black
	fi
done

