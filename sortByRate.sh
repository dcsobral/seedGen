#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -v RATE_OPTS && -n "${RATE_OPTS}" ]]; then
	IFS=' ' RATE_OPTS=( ${RATE_OPTS} )
else
	RATE_OPTS=( )
fi

for file in *.xml; do
	printf "%6d %s\n" \
		"$("${BIN}/rate.py" "${RATE_OPTS[@]}" "$file" | tail -1 | cut -d ' ' -f 1)" \
		"${file%-*.xml}"
done | "${BIN}/ordinalSort.sh"
