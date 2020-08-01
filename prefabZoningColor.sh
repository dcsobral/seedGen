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

	zones="$(xmlstarlet sel -t -m /prefab -v "property[@name='Zoning']/@value" \
		"$PREFABS/$prefab.xml" || : | tr '[A-Z]' '[a-z]')"

	if [[ $zones == *any* ]]; then
		echo white
		exit 0
	elif [[ $zones == *nozone* ]]; then
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

