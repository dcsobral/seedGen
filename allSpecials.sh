#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${SPECIAL_FOLDER:=${BIN}/special}"

getSorts() {

	STORES=$(wc -l < "${SPECIAL_FOLDER}/stores.txt")
	TOP7=$(wc -l < "${SPECIAL_FOLDER}/top7.txt")
	TOP15=$(wc -l < "${SPECIAL_FOLDER}/top15.txt")
	INDUSTRIAL=$(wc -l < "${SPECIAL_FOLDER}/industrial.txt")
	DOWNTOWN=$(wc -l < "${SPECIAL_FOLDER}/downtown.txt")

	printf "Pos Uniq Stores (%d)\tPos Uniq Top %d\tPos Uniq Top %d\tPos Uniq Industrial (%d)\tPos Uniq Downtown (%d)\n" "$STORES" "$TOP7" "$TOP15" "$INDUSTRIAL" "$DOWNTOWN"

	# Hacks! I haven't figured out the best way of not hard coding this
	paste \
		<(SPECIAL=stores.txt sortBySpecialPrefabs.sh | "${BIN}/grepIt.sh" "$@") \
		<(SPECIAL=top7.txt sortBySpecialPrefabs.sh | "${BIN}/grepIt.sh" "$@") \
		<(SPECIAL=top15.txt sortBySpecialPrefabs.sh | "${BIN}/grepIt.sh" "$@") \
		<(SPECIAL=industrial.txt sortBySpecialPrefabs.sh | "${BIN}/grepIt.sh" "$@") \
		<(SPECIAL=downtown.txt sortBySpecialPrefabs.sh | "${BIN}/grepIt.sh" "$@")

	printf "Pos Uniq Stores (%d)\tPos Uniq Top %d\tPos Uniq Top %d\tPos Uniq Industrial (%d)\tPos Uniq Downtown (%d)\n" "$STORES" "$TOP7" "$TOP15" "$INDUSTRIAL" "$DOWNTOWN"
}

if [[ -t 1 ]]; then
	getSorts "$@" | column -t -s $'\t'
else
	getSorts "$@"
fi

