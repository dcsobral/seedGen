#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"
PREFABS="${F7D2D}/Data/Prefabs"

if [[ $# -eq 0 ]]; then
        echo >&2 "$0 <prefab_name>"
        exit 1
fi

for prefab; do
	if [[ $prefab == *trader* ]]; then
		echo magenta
		exit 0
	elif [[ $prefab == *field* ]]; then
		echo olive
		exit 0
	fi

        if [[ "$prefab" =~ rwg_tile* ]]; then
		case "$prefab" in
			rwg_tile_citycenter* | rwg_tile_downtown*)
				zones="downtown"
				;;
			rwg_tile_commercial*)
				zones="commercial"
				;;
			rwg_tile_countryresidential* | rwg_tile_countrytown* | rwg_tile_rural*)
				zones="residentialold"
				;;
			rwg_tile_residential*)
				zones="residentialold,residentialnew"
				;;
			rwg_tile_ghosttown* | rwg_tile_oldwest*)
				zones="oldwest"
				;;
			rwg_tile_industrial*)
				zones="industrial"
				;;
			*)
				zones="any"
				;;
		esac
		if [[ -z $zones ]]; then
			FILE="${PREFABS}/RWGTiles/${prefab}.xml"
		fi
	else
		zones=""
		FILE="${PREFABS}/POIs/${prefab}.xml"
	fi

	if [[ -z "${zones}" ]]; then
		[[ -f "${FILE}" ]] || FILE="$(find "${PREFABS}" -name "${prefab}.xml" -print)"
		zones="$(xmlstarlet sel -t -m /prefab -v "property[@name='Zoning']/@value" \
			"${FILE}" | tr '[:upper:]' '[:lower:]' || :)"
	fi

	if [[ $zones == *any* ]]; then
		echo white
		exit 0
	elif [[ $zones == *nozone* || $zones == *oldwest* ]]; then
		echo saddlebrown
		exit 0
	fi

	[[ "$zones" == *residentialold* ]] && RESIDENTIAL_OLD=1 || RESIDENTIAL_OLD=""
	[[ "$zones" == *residentialnew* ]] && RESIDENTIAL_NEW=1 || RESIDENTIAL_NEW=""
	[[ "$zones" == *industrial* ]] && INDUSTRIAL=1 || INDUSTRIAL=""
	[[ "$zones" == *commercial* ]] && COMMERCIAL=1 || COMMERCIAL=""
	[[ "$zones" == *downtown* ]] && DOWNTOWN=1 || DOWNTOWN=""

	[[ -n $RESIDENTIAL_OLD || -n $RESIDENTIAL_NEW ]] && RESIDENTIAL=1 || RESIDENTIAL=""

	if [[ -n $DOWNTOWN && -n $COMMERCIAL && -n $INDUSTRIAL ]]; then echo orange
	elif [[ -n $DOWNTOWN && -n $RESIDENTIAL ]]; then echo teal
	elif [[ -n $DOWNTOWN && -n $COMMERCIAL ]]; then echo slategray
	elif [[ -n $DOWNTOWN ]]; then echo gray
	elif [[ -n $RESIDENTIAL_OLD ]]; then echo green
	elif [[ -n $RESIDENTIAL_NEW ]]; then echo chartreuse
	elif [[ -n $COMMERCIAL ]]; then echo blue
	elif [[ -n $INDUSTRIAL ]]; then echo yellow
	else echo black
	fi
done

