#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -eq 0 ]]; then
	echo >&2 "$0 cmd args"
	exit 1
fi

OUTPUT="$("$@")"

mapfile -d ' ' -t top < <(tail -1 <<<"$OUTPUT" | tr $'\n\t' ' ' | tr -s ' ')

# shellcheck disable=2154
for i in "${!top[@]}"; do
	if [[ ${top[$i]} =~ ^[0-9]*$ ]]; then
		unset top[$i]
	fi
done

"${BIN}/highlight.sh" "${top[@]}" <<<"$OUTPUT"

