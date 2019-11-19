#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
	echo >&2 "$0 <prefab.xml>"
	exit 1
fi

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

# shellcheck disable=SC2016
xmlstarlet sel -t -m / --var "p=document('$1')" -m "//prefab_rule[prefab[@name]]" -v @name -o " " --var "s=count(prefab[@name=\$p//decoration/@name])" --var "t=count(prefab[@name])" -v '$s' -o ' / ' -v '$t' -o ' (' -v 'round($s * 100 div $t)' -o '%)' -n "${F7D2D}/Data/Config/rwgmixer.xml"
