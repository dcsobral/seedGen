#!/usr/bin/env bash

join_by() { local IFS="$1"; shift; echo "$*"; }

grepIt() {
        if [[ $# -gt 0 ]]; then
                REGEX="\\Q$(join_by $'\t' "$@" | sed 's/\t/\\E|\\Q/g;s/-[0-9]*\.xml//g')\\E"
                #echo >&2 "REGEX: $REGEX"
                grep -P "$REGEX"
        else
                cat
        fi
}

grepIt "$@"

