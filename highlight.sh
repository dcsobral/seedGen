#!/usr/bin/env bash

join_by() { local IFS="$1"; shift; echo "$*"; }

if [[ $# -gt 0 ]]; then
	REGEX="\\Q$(join_by $'\t' "$@" | sed 's/\t/\\E|\\Q/g')\\E|$"
	#echo >&2 "REGEX: $REGEX"
	grep --color=always -P "$REGEX"
else
	cat
fi

