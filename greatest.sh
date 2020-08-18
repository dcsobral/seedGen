#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -eq 0 ]]; then
	echo >&2 "$0 cmd args"
	exit 1
fi

OUTPUT="$("$@")"

mapfile -t top < <("${BIN}/bestSeeds.sh" <<<"$OUTPUT" | grep -Ev "^      1 " | cut -c 9-)

"${BIN}/highlight.sh" "${top[@]}" <<<"$OUTPUT"

