#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -eq 0 ]]; then
	echo >&2 "$0 cmd args"
	exit 1
fi

OUTPUT="$("$@")"

mapfile -t top < <(grep -Eo '  1 +[0-9]+ +\S+' <<<"$OUTPUT" | grep -Eo '[[:alpha:]]\S+')

"${BIN}/highlight.sh" "${top[@]}" <<<"$OUTPUT"

