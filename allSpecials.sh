#!/usr/bin/env bash

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${SPECIAL_FOLDER:=${BIN}/special}"

mapfile -t SPECIALS < <(ls ${SPECIAL_FOLDER})

getSorts() {
#	declare -a SPECIAL_FILES
#	for special in "${SPECIALS[@]}"; do
#		if [[ -f "${SPECIAL_FOLDER}/$special" ]]; then
#			echo -n "${special%.txt}"$'\t'
#			SPECIAL_FILES+=( "${SPECIAL_FOLDER}/$special" )
#		fi
#	done
#	echo

	echo $'top7\ttop15\ttiers 4, 5 & traders\tstores\tskyscrapers'

	# Hacks! I haven't figured out the best way of not hard coding this
	paste \
		<(SPECIAL=top7.txt sortByInterestingPrefabs.sh) \
		<(SPECIAL=top15.txt sortByInterestingPrefabs.sh) \
		<(SPECIAL=special.txt sortByInterestingPrefabs.sh) \
		<(SPECIAL=stores.txt sortByInterestingPrefabs.sh) \
		<(SPECIAL=skyscrapers.txt sortByInterestingPrefabs.sh)
}

#getSorts() {
#	echo $'      # of Prefabs\t     Uniq. Int.\t     # of Int.\t     Unique'
#	paste \
#		<(sortByPrefabs.sh)  \
#		<(sortByInterestingPrefabs.sh) \
#		<(sortByTotalInterestingPrefabs.sh) \
#		<(sortByUniquePrefabs.sh)
#}

if [[ -t 1 ]]; then
	getSorts | column -t -s $'\t' | "$BIN"/highlight.sh "$@"
else
	getSorts
fi

