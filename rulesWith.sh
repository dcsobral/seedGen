#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if [[ $# -eq 0 ]]; then
	echo >&2 "$0 <prefab_name>"
	exit 1
elif [[ $# -gt 1 ]]; then
	PRECMD='echo "$prefab:"'
	PREFIX=$'\t'
else
	PRECMD=':'
	PREFIX=''
fi

: "${F7D2D:=/mnt/c/Users/Daniel/Desktop/RH5.5Server}"

for prefab; do
	eval "$PRECMD"
	xmlstarlet sel -t -m "//prefab_rule[prefab[starts-with(@name,'$prefab')]]" -o "$PREFIX" -v @name -n "${F7D2D}/Data/Config/rwgmixer.xml"
done

