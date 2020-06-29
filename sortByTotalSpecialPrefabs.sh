#!/usr/bin/env bash

BIN="$(cd "$(dirname "$0")" && pwd)"
: "${SPECIAL_FOLDER:=${BIN}/special}"
: "${SPECIAL:=special.txt}"

list() {
	for file in *.xml; do
		printf "%4d %s\n" \
			"$(cut -s -d '"' -f 4 "$file" | \
			grep -c -F -x -f "${SPECIAL_FOLDER}/${SPECIAL}")" \
			"${file%.xml}"
	done
}

list | sort -n

