#!/usr/bin/env bash

BIN="$(cd "$(dirname "$0")" && pwd)"

list() {
	for file in *.xml; do
		echo -n "$file "
		grep -h decoration "$file" | cut -d '"' -f 4 | sort -u | wc -l
	done
}

list | sort -k 2 -n

