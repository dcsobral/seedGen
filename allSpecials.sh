#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${SPECIAL_FOLDER:=${BIN}/special}"

#mapfile -t SPECIALS < <(ls ${SPECIAL_FOLDER})

getSorts() {

	TIER3=$(wc -l < "${SPECIAL_FOLDER}/tier3.txt")
	TIER4=$(wc -l < "${SPECIAL_FOLDER}/tier4.txt")
	TIER5=$(wc -l < "${SPECIAL_FOLDER}/tier5.txt")
	STORES=$(wc -l < "${SPECIAL_FOLDER}/stores.txt")
	TOP7=$(wc -l < "${SPECIAL_FOLDER}/top7.txt")
	TOP15=$(wc -l < "${SPECIAL_FOLDER}/top15.txt")
	INDUSTRIAL=$(wc -l < "${SPECIAL_FOLDER}/industrial.txt")

	printf "         tier 3 (%d)\t         tier 4 (%d)\t         tier 5 (%d)\t         stores (%d)\t         top %d\t         top %d\t         industrial (%d)\n" $TIER3 $TIER4 $TIER5 $STORES $TOP7 $TOP15 $INDUSTRIAL

	# Hacks! I haven't figured out the best way of not hard coding this
	paste \
		<(SPECIAL=tier3.txt sortBySpecialPrefabs.sh) \
		<(SPECIAL=tier4.txt sortBySpecialPrefabs.sh) \
		<(SPECIAL=tier5.txt sortBySpecialPrefabs.sh) \
		<(SPECIAL=stores.txt sortBySpecialPrefabs.sh) \
		<(SPECIAL=top7.txt sortBySpecialPrefabs.sh) \
		<(SPECIAL=top15.txt sortBySpecialPrefabs.sh) \
		<(SPECIAL=industrial.txt sortBySpecialPrefabs.sh)

	printf "         tier 3 (%d)\t         tier 4 (%d)\t         tier 5 (%d)\t         stores (%d)\t         top %d\t         top %d\t         industrial (%d)\n" $TIER3 $TIER4 $TIER5 $STORES $TOP7 $TOP15 $INDUSTRIAL
}

if [[ -t 1 ]]; then
	getSorts | column -t -s $'\t' | "$BIN"/highlight.sh "$@"
else
	getSorts
fi

