#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
	echo >&2 "$0 <prefab.xml>"
	exit 1
fi

BIN="$(cd "$(dirname "$0")" && pwd)"
INTERESTING="${BIN}/interesting.txt"

grep -h decoration "$1" |
	cut -d '"' -f 4 |
	sort |
	uniq -c |
	grep -F -f "${INTERESTING}" |
	cut -c 4-
	#tr -s ' ' |
	#awk '{ print $2 " " $1}'

#xmlstarlet sel -t -m / --var "i=document('$INTERESTING')"  -m "/prefabs/decoration[@name=\$i/xsl-select/prefab/@name][not(@name=preceding-sibling::*/@name)]" --sort a:t:- @name -v @name -o " " -v "count(/prefabs/decoration[@name=current()/@name])" -n $1

