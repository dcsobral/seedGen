#!/usr/bin/env bash

for file in *.xml; do
	printf "%5d %s\n" \
		"$(grep -c decoration "$file")" \
		"${file%-*.xml}"
done | sort -nr | awk '{if ($1 != prev) num=NR; printf "%3d %s\n", num, $0; prev=$1}' | tac
