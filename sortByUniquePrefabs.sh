#!/usr/bin/env bash

for file in *.xml; do
	printf "%4d %s\n" \
		"$(grep decoration -- "$file" | cut -s -d '"' -f 4 | sort -u | wc -l)" \
		"${file%.xml}"
done | sort -n

