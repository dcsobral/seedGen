#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
	echo >&2 "$0 <rule>"
	exit 1
fi

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

prefabCount() {
	xmlstarlet sel -t -m / --var "p=document('$file')" -m "//prefab_rule[@name='$1']" -v "count(\$p//decoration[@name=current()/prefab/@name])" "${F7D2D}/Data/Config/rwgmixer.xml"
}

ruleCount() {
	xmlstarlet sel -t -m / --var "p=document('$file')" -m "//prefab_rule[@name='$1']" -v "count(prefab[@name=\$p//decoration/@name])" "${F7D2D}/Data/Config/rwgmixer.xml"
}

for file in *.xml; do
	printf "%3d %3d %s\n" "$(prefabCount "$1")" "$(ruleCount "$1")" "${file%.xml}"
done | sort -n

