#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if [[ $# -eq 0 ]]; then
	echo >&2 "$0 <prefab_name>"
	exit 1
fi

: "${F7D2D:=/mnt/c/Users/Daniel/Desktop/RH5.5Server}"

for prefab; do
	xmlstarlet sel -t -m "//prefab_rule[prefab[starts-with(@name,'$prefab')]]" -v @name -n "${F7D2D}/Data/Config/rwgmixer.xml"
done

