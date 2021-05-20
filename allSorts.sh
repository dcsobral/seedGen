#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIZE="$(basename "$PWD")"

getSorts() {
	echo $'          # of Prefabs\t         # of Traders\t         Unique Specials\t         Unique\t         Score'
	paste \
		<(sortByPrefabs.sh | "${BIN}/grepIt.sh" "$@")  \
		<(special.sh -traders.txt sortByTotalSpecialPrefabs.sh | "${BIN}/grepIt.sh" "$@") \
		<(sortBySpecialPrefabs.sh | "${BIN}/grepIt.sh" "$@") \
		<(sortByUniquePrefabs.sh | "${BIN}/grepIt.sh" "$@") \
		<(sortByScore.sh "${SIZE}" | "${BIN}/grepIt.sh" "$@")
	echo $'          # of Prefabs\t         # of Traders\t         Unique Specials\t         Unique\t         Score'
}

if [[ -t 1 ]]; then
	getSorts "$@" | column -t -s $'\t'
else
	getSorts "$@"
fi

