#!/usr/bin/env bash

BIN="$(cd "$(dirname "$0")" && pwd)"
INTERESTING="${BIN}/interesting.txt"

list() {
	for file in *.xml; do
                printf "%4d %s\n" \
                        "$(cut -s -d '"' -f 4 "$file" | grep -F -x -f "${INTERESTING}" | sort -u | wc -l)" \
                        "$file"
	done
}

list | sort -k 2 -n

