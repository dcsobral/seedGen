#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
	echo >&2 "$0 <group>"
	exit 1
fi

: "${F7D2D:=/mnt/c/Users/Daniel/Desktop/RH5.5Server}"

prefabCount() {
	xmlstarlet sel -t -m / --var "p=document('$file')" -m "//prefab_rule[@name='$1']" -v "count(\$p//decoration[@name=current()/prefab/@name])" "${F7D2D}/Data/Config/rwgmixer.xml"
}

groupCount() {
	xmlstarlet sel -t -m / --var "p=document('$file')" -m "//prefab_rule[@name='$1']" -v "count(prefab[@name=\$p//decoration/@name])" "${F7D2D}/Data/Config/rwgmixer.xml"
}

for file in *.xml; do
	printf "%3d %3d %s\n" "$(prefabCount "$1")" "$(groupCount "$1")" "${file%.xml}"
done | sort -n

