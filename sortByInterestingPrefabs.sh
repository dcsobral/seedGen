#!/usr/bin/env bash

BIN="$(cd "$(dirname "$0")" && pwd)"
: "${INTERESTING_FOLDER:=${BIN}/interesting}"
: "${INTERESTING:=interesting.txt}"

list() {
	for file in *.xml; do
                printf "%4d %s\n" \
                        "$(grep decoration "$file" | \
				cut -s -d '"' -f 4 | \
				grep -F -x -f "${INTERESTING_FOLDER}/${INTERESTING}" | \
				sort -u | wc -l)" \
                        "${file%.xml}"
	done
}

list | sort -n

