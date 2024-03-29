#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

getSorts() {
	echo $'          # of Prefabs\t         # of Traders\t         Unique Prefabs\t           Rate'
	paste \
		<(sortByPrefabs.sh | "${BIN}/grepIt.sh" "$@")  \
		<(withSpecial.sh -traders.txt sortByTotalSpecialPrefabs.sh | "${BIN}/grepIt.sh" "$@") \
		<(sortByUniquePrefabs.sh | "${BIN}/grepIt.sh" "$@") \
		<(sortByRate.sh | "${BIN}/grepIt.sh" "$@")
	echo $'          # of Prefabs\t         # of Traders\t         Unique Prefabs\t           Rate'
}

if [[ -t 1 ]]; then
	getSorts "$@" | column -t -s $'\t'
else
	getSorts "$@"
fi

