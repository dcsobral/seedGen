#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

paste <(sortByPrefabs.sh)  <(sortByInterestingPrefabs.sh) <(sortByTotalInterestingPrefabs.sh) <(sortByUniquePrefabs.sh) \
	| column -t \
	| "$BIN"/highlight.sh "$@"

