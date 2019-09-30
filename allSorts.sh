#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

getSorts() {
	echo $'      # of Prefabs\t     Uniq. Int.\t     # of Int.\t     Unique'
	paste \
		<(sortByPrefabs.sh)  \
		<(sortByInterestingPrefabs.sh) \
		<(sortByTotalInterestingPrefabs.sh) \
		<(sortByUniquePrefabs.sh)
}

if [[ -t 1 ]]; then
	getSorts | column -t -s $'\t' | "$BIN"/highlight.sh "$@"
else
	getSorts
fi

