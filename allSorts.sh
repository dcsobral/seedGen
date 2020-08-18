#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

getSorts() {
	echo $'      # of Prefabs\t     Uniq. Spc.\t     # of Spc.\t     Unique'
	paste \
		<(sortByPrefabs.sh)  \
		<(sortBySpecialPrefabs.sh) \
		<(sortByTotalSpecialPrefabs.sh) \
		<(sortByUniquePrefabs.sh)
	echo $'      # of Prefabs\t     Uniq. Spc.\t     # of Spc.\t     Unique'
}

if [[ -t 1 ]]; then
	getSorts | column -t -s $'\t' | "$BIN"/highlight.sh "$@"
else
	getSorts
fi

