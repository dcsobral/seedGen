#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
	echo >&2 "$0 <prefab.xml>"
	exit 1
fi

xmlstarlet sel -t -m / --var "p=document('$1')" -m "//prefab_rule[prefab[@name]]" --if "prefab[not(@name=\$p//decoration/@name)]" -v @name -n -b -m "prefab[not(@name=\$p//decoration/@name)]" --sort a:t:u @name -o "  " -v '@name' --var "x=document(concat('../../Data/Prefabs/',@name,'.xml'))" -o " (" -v "\$x/prefab/property[@name='Zoning']/@value" -o ")" -n ../../Data/Config/rwgmixer.xml

