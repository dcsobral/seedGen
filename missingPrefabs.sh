#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

if [[ $# -lt 1 || $# -gt 2 ]]; then
	echo >&2 "$0 <prefab.xml> [<special.txt>]"
	exit 1
fi

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${SPECIAL_FOLDER:=${BIN}/special}"

# "SPECIAL" used differently here than the exported version used by other scripts
if [[ $# -gt 1 && -n $2 ]]; then
	SPECIAL="$2"
else
	SPECIAL=''
fi

# 7d2d prefabs xml files come with "bom", which prevents the file from being read with "document"
# use the following to remove bom from files, if needed
# sed -i 's/\xef\xbb\xbf//' $filename

findIt() {
	declare -A prefabs
	mapfile -t < <(xmlstarlet sel -t -m "/prefabs/decoration/@name" -v . -n  "$1" | sort -u)
	for decoration in "${MAPFILE[@]}"; do
		prefabs["${decoration}"]=1
	done


	mapfile -t < <( \
		cd "${F7D2D}/Data/Prefabs/POIs" \
		&& grep -L -E -i "zoning.*none" -- *.xml \
		|| : \
		)
	for file in "${MAPFILE[@]}"; do
		prefab="${file%.xml}"
		if [[ -z ${prefabs["$prefab"]+abc} ]]; then
			echo "$prefab"
		fi
	done
}

showIt() {
	if [[ -n $SPECIAL ]]; then
		findIt "$1" | grep -F -x -f "${SPECIAL_FOLDER}/${SPECIAL}"
	else
		findIt "$1"
	fi
}

if [[ -t 1 ]]; then
	showIt "$1" | column
else
	showIt "$1"
fi

