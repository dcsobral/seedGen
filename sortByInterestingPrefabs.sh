#!/usr/bin/env bash

BIN="$(cd "$(dirname "$0")" && pwd)"
: "${SPECIAL_FOLDER:=${BIN}/special}"
: "${SPECIAL:=special.txt}"

list() {
	for file in *.xml; do
                printf "%4d %s\n" \
                        "$(grep decoration "$file" | \
				cut -s -d '"' -f 4 | \
				grep -F -x -f "${SPECIAL_FOLDER}/${SPECIAL}" | \
				sort -u | wc -l)" \
                        "${file%.xml}"
	done
}

list | sort -n

