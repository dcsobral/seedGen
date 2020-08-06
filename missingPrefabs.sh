#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

if [[ $# -lt 1 || $# -gt 2 ]]; then
	echo >&2 "$0 <prefab.xml> [<special.txt>]"
	exit 1
fi

BIN="$(cd "$(dirname "$0")" && pwd)"
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
	xmlstarlet sel -t -m / --var "p=document('$1')" -m "//prefab_rule[prefab[@name]]" --if "prefab[@name][not(@name=\$p//decoration/@name)]" -v @name -n -b -m "prefab[@name][not(@name=\$p//decoration/@name)]" --sort a:t:u @name -o "  " -v '@name' --var "x=document(concat('${F7D2D}/Data/Prefabs/',@name,'.xml'))" -o " (" -v "\$x/prefab/property[@name='Zoning']/@value" -o ")" -n "${F7D2D}/Data/Config/rwgmixer.xml"
}

showIt() {
	if [[ -n $SPECIAL ]]; then
		findIt "$1" | grep -F -f "${SPECIAL_FOLDER}/${SPECIAL}"
	else
		findIt "$1"
	fi
}

if [[ -t 1 ]]; then
	showIt "$1" | column
else
	showIt "$1"
fi

