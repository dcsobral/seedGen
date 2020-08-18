#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

doIt() {
	"${BIN}/topSeeds.sh" | sort | uniq -c | sort -n
}

if [[ -t 1 ]]; then
	doIt | "$BIN"/highlight.sh "$@"
else
	doIt
fi

