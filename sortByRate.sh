#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -ne 1 ]]; then
        echo >&2 "$0 <size>"
        exit 1
fi

SIZE="$1"

for file in *.xml; do
	printf "%6d %s\n" \
		"$("${BIN}/rate.py" "$file" "$SIZE" | tail -1 | cut -d ' ' -f 1)" \
		"${file%-*.xml}"
done | "${BIN}/ordinalSort.sh"
