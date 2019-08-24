#!/usr/bin/env bash

BIN="$(cd "$(dirname "$0")" && pwd)"
INTERESTING="${BIN}/interesting.xml"

list() {
	for file in *.xml; do
		echo -n "$file "
		xmlstarlet sel -t -m / --var "i=document('$INTERESTING')"  -v "count(/prefabs/decoration[@name=\$i/xsl-select/prefab/@name][not(@name=preceding-sibling::*/@name)])" -n $file
	done
}

list | sort -k 2 -n

