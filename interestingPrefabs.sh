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

