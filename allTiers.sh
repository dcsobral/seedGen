#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${SPECIAL_FOLDER:=${BIN}/special}"

getSorts() {

	TIER3=$(wc -l < "${SPECIAL_FOLDER}/tier3.txt")
	TIER4=$(wc -l < "${SPECIAL_FOLDER}/tier4.txt")
	TIER5=$(wc -l < "${SPECIAL_FOLDER}/tier5.txt")

	printf "Pos Uniq Tier 3 (%d)\tPos Uniq Tier 4 (%d)\tPos Uniq Tier 5 (%d)\n" "$TIER3" "$TIER4" "$TIER5"

	# Hacks! I haven't figured out the best way of not hard coding this
	paste \
		<(SPECIAL=tier3.txt sortBySpecialPrefabs.sh | "${BIN}/grepIt.sh" "$@") \
		<(SPECIAL=tier4.txt sortBySpecialPrefabs.sh | "${BIN}/grepIt.sh" "$@") \
		<(SPECIAL=tier5.txt sortBySpecialPrefabs.sh | "${BIN}/grepIt.sh" "$@")

	printf "Pos Uniq Tier 3 (%d)\tPos Uniq Tier 4 (%d)\tPos Uniq Tier 5 (%d)\n" "$TIER3" "$TIER4" "$TIER5"
}

if [[ -t 1 ]]; then
	getSorts "$@" | column -t -s $'\t'
else
	getSorts "$@"
fi

