#!/usr/bin/env bash


: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

if [[ $# -ne 1 ]]; then
	echo >&2 "$0 <prefab.xml>"
	exit 1
fi

# 7d2d prefabs xml files come with "bom", which prevents the file from being read with "document"
# use the following to remove bom from files, if needed
# sed -i 's/\xef\xbb\xbf//' $filename

xmlstarlet sel -t -m / --var "p=document('$1')" -m "//prefab_rule[prefab[@name]]" --if "prefab[not(@name=\$p//decoration/@name)]" -v @name -n -b -m "prefab[not(@name=\$p//decoration/@name)]" --sort a:t:u @name -o "  " -v '@name' --var "x=document(concat('${F7D2D}/Data/Prefabs/',@name,'.xml'))" -o " (" -v "\$x/prefab/property[@name='Zoning']/@value" -o ")" -n "${F7D2D}/Data/Config/rwgmixer.xml"

