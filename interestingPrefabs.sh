#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
	echo >&2 "$0 <prefab.xml>"
	exit 1
fi

BIN="$(cd "$(dirname "$0")" && pwd)"
: "${INTERESTING_FOLDER:=${BIN}/interesting}"
: "${INTERESTING:=interesting.txt}"

showIt() {
	cut -s -d '"' -f 4 "$1" |
		grep -F -x -f "${INTERESTING_FOLDER}/${INTERESTING}" |
		sort |
		uniq -c |
		cut -c 4-
}

if [[ -t 1 ]]; then
	showIt "$1" | column
else
	showIt "$1"
fi

