#!/usr/bin/env bash

if [[ $# -lt 1 || $# -gt 2 ]]; then
	echo >&2 "$0 <prefab.xml> [<special.txt>]"
	exit 1
fi

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${SPECIAL_FOLDER:=${BIN}/special}"
: "${SPECIAL:=${2-special.txt}}"

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

