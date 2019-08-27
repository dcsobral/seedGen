#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

(
echo $'      # of Prefabs\t     Uniq. Int.\t     # of Int.\t     Unique'
paste \
	<(sortByPrefabs.sh)  \
	<(sortByInterestingPrefabs.sh) \
	<(sortByTotalInterestingPrefabs.sh) \
	<(sortByUniquePrefabs.sh)
) | column -t -s $'\t' | "$BIN"/highlight.sh "$@"

