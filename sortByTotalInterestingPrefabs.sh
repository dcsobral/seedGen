#!/usr/bin/env bash

BIN="$(cd "$(dirname "$0")" && pwd)"
INTERESTING="${BIN}/interesting.txt"

list() {
	for file in *.xml; do
		printf "%4d %s\n" \
			"$(cut -s -d '"' -f 4 "$file" | grep -c -F -x -f "${INTERESTING}")" \
			"${file%.xml}"
	done
}

list | sort -n

