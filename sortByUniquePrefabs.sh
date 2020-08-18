#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for file in *.xml; do
	printf "%4d %s\n" \
		"$(grep decoration -- "$file" | cut -s -d '"' -f 4 | sort -u | wc -l)" \
		"${file%-*.xml}"
done | "${BIN}/ordinalSort.sh"

