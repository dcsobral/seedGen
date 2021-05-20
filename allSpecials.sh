#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${SPECIAL_FOLDER:=${BIN}/special}"

getSorts() {

	TIER3=$(wc -l < "${SPECIAL_FOLDER}/tier3.txt")
	TIER4=$(wc -l < "${SPECIAL_FOLDER}/tier4.txt")
	TIER5=$(wc -l < "${SPECIAL_FOLDER}/tier5.txt")
	STORES=$(wc -l < "${SPECIAL_FOLDER}/stores.txt")
	TOP7=$(wc -l < "${SPECIAL_FOLDER}/top7.txt")
	TOP15=$(wc -l < "${SPECIAL_FOLDER}/top15.txt")
	INDUSTRIAL=$(wc -l < "${SPECIAL_FOLDER}/industrial.txt")

	printf "Pos Uniq Tier 3 (%d)\tPos Uniq Tier 4 (%d)\tPos Uniq Tier 5 (%d)\tPos Uniq Stores (%d)\tPos Uniq Top %d\tPos Uniq Top %d\tPos Uniq Industrial (%d)\n" "$TIER3" "$TIER4" "$TIER5" "$STORES" "$TOP7" "$TOP15" "$INDUSTRIAL"

	# Hacks! I haven't figured out the best way of not hard coding this
	paste \
		<(SPECIAL=tier3.txt sortBySpecialPrefabs.sh | "${BIN}/grepIt.sh" "$@") \
		<(SPECIAL=tier4.txt sortBySpecialPrefabs.sh | "${BIN}/grepIt.sh" "$@") \
		<(SPECIAL=tier5.txt sortBySpecialPrefabs.sh | "${BIN}/grepIt.sh" "$@") \
		<(SPECIAL=stores.txt sortBySpecialPrefabs.sh | "${BIN}/grepIt.sh" "$@") \
		<(SPECIAL=top7.txt sortBySpecialPrefabs.sh | "${BIN}/grepIt.sh" "$@") \
		<(SPECIAL=top15.txt sortBySpecialPrefabs.sh | "${BIN}/grepIt.sh" "$@") \
		<(SPECIAL=industrial.txt sortBySpecialPrefabs.sh | "${BIN}/grepIt.sh" "$@")

	printf "Pos Uniq Tier 3 (%d)\tPos Uniq Tier 4 (%d)\tPos Uniq Tier 5 (%d)\tPos Uniq Stores (%d)\tPos Uniq Top %d\tPos Uniq Top %d\tPos Uniq Industrial (%d)\n" "$TIER3" "$TIER4" "$TIER5" "$STORES" "$TOP7" "$TOP15" "$INDUSTRIAL"
}

if [[ -t 1 ]]; then
	getSorts "$@" | column -t -s $'\t'
else
	getSorts "$@"
fi

