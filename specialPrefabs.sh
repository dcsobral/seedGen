#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
	echo >&2 "$0 <prefab.xml>"
	exit 1
fi

BIN="$(cd "$(dirname "$0")" && pwd)"
: "${SPECIAL_FOLDER:=${BIN}/special}"
: "${SPECIAL:=special.txt}"

showIt() {
	cut -s -d '"' -f 4 "$1" |
		grep -F -x -f "${SPECIAL_FOLDER}/${SPECIAL}" |
		sort |
		uniq -c |
		cut -c 4-
}

if [[ -t 1 ]]; then
	showIt "$1" | column
else
	showIt "$1"
fi

