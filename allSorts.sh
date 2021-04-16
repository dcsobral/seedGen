#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

getSorts() {
	echo $'          # of Prefabs\t         # of Traders\t         Unique Specials\t         Unique'
	paste \
		<(sortByPrefabs.sh)  \
		<(special.sh -traders.txt sortByTotalSpecialPrefabs.sh) \
		<(sortBySpecialPrefabs.sh) \
		<(sortByUniquePrefabs.sh)
	echo $'          # of Prefabs\t         # of Traders\t         Unique Specials\t         Unique'
}

if [[ -t 1 ]]; then
	getSorts | column -t -s $'\t' | "$BIN"/highlight.sh "$@"
else
	getSorts
fi

