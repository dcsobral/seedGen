#!/usr/bin/env bash

for file in *.xml; do
	printf "%4d %s\n" \
		"$(grep decoration -- "$file" | cut -s -d '"' -f 4 | sort -u | wc -l)" \
		"${file%-*.xml}"
done | sort -nr | awk '{if ($1 != prev) num=NR; printf "%3d %s\n", num, $0; prev=$1}' | tac

