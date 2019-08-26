#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
	echo >&2 "$0 <prefab.xml>"
	exit 1
fi

BIN="$(cd "$(dirname "$0")" && pwd)"
INTERESTING="${BIN}/interesting.txt"

cut -s -d '"' -f 4 "$1" |
	grep -F -x -f "${INTERESTING}" |
	sort |
	uniq -c |
	cut -c 4-

