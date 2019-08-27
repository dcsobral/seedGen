#!/usr/bin/env bash

for file in *.xml; do
	printf "%5d %s\n" \
		"$(grep -c decoration "$file")" \
		"${file%.xml}"
done | sort -n
