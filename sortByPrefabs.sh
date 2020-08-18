#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for file in *.xml; do
	printf "%5d %s\n" \
		"$(grep -c decoration "$file")" \
		"${file%-*.xml}"
done | "${BIN}/ordinalSort.sh"
