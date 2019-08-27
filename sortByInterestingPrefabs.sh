#!/usr/bin/env bash

BIN="$(cd "$(dirname "$0")" && pwd)"
INTERESTING="${BIN}/interesting.txt"

list() {
	for file in *.xml; do
                printf "%4d %s\n" \
                        "$(grep decoration "$file" | cut -s -d '"' -f 4 | grep -F -x -f "${INTERESTING}" | sort -u | wc -l)" \
                        "${file%.xml}"
	done
}

list | sort -n

