#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${SPECIAL_FOLDER:=${BIN}/special}"

join_by() { local IFS="$1"; shift; echo "$*"; }

mapfile -t < <(xmlstarlet sel -t \
	-m "/rwgmixer/district/property[@name='poi_required_tags_all']/@value" \
	-v . -n "${F7D2D}/Data/Config/rwgmixer.xml"  \
	| tr ',' '\n' \
	| sort -u)

REGEX="(\\Q$(join_by $'\t' "${MAPFILE[@]}" | sed 's/\t/\\E|\\Q/g')\\E)"

mapfile -t xmls < <(find "${F7D2D}/Data/Prefabs" -name Test -prune \
	-or -name 'aaa_*' -prune \
	-or -type f -name '*.xml' \( \
		-exec grep -Piq 'property name="Tags" value="[^"]*\b'"$REGEX"'\b[^"]*"' {} \; \
	\) \
	-print)

# By name
declare -a stores

# By tag
declare -a downtown
declare -a industrial
declare -a traders

# By name and tag
declare -a skyscrapers

# By quest tier
declare -a tier3
declare -a tier4
declare -a tier5

for xml in "${xmls[@]}"; do
	name="$(basename -s .xml "$xml")"
	tier="$(xmlstarlet sel -t -m "/prefab/property[@name='DifficultyTier']" -v @value "$xml")"
	tags="$(xmlstarlet sel -t -m "/prefab/property[@name='Tags']" -v @value "$xml")"

	if [[ $name == store_* ]]; then
		stores+=("${name}")
	fi

	if grep -Piq '\bdowntown\b' <<<"${tags}"; then
		downtown+=("${name}")
	fi

	if grep -Piq '\bindustrial\b' <<<"${tags}"; then
		industrial+=("${name}")
	fi

	if grep -Piq '\btrader\b' <<<"${tags}"; then
		traders+=("${name}")
	fi

	case "${tier}" in
		3)
			tier3+=("${name}")
			;;
		4)
			tier4+=("${name}")
			;;
		5)
			tier5+=("${name}")
			if [[ $name == skyscraper_* ]]; then
				skyscrapers+=("${name}")
			fi
			;;
	esac
done

echo "${stores[@]}" | tr ' ' $'\n' | sort -u > "${SPECIAL_FOLDER}/stores.txt"
echo "${downtown[@]}" | tr ' ' $'\n' | sort -u > "${SPECIAL_FOLDER}/downtown.txt"
echo "${industrial[@]}" | tr ' ' $'\n' | sort -u > "${SPECIAL_FOLDER}/industrial.txt"
echo "${traders[@]}" | tr ' ' $'\n' | sort -u > "${SPECIAL_FOLDER}/traders.txt"
echo "${skyscrapers[@]}" | tr ' ' $'\n' | sort -u > "${SPECIAL_FOLDER}/skyscrapers.txt"
echo "${tier3[@]}" | tr ' ' $'\n' | sort -u > "${SPECIAL_FOLDER}/tier3.txt"
echo "${tier4[@]}" | tr ' ' $'\n' | sort -u > "${SPECIAL_FOLDER}/tier4.txt"
echo "${tier5[@]}" | tr ' ' $'\n' | sort -u > "${SPECIAL_FOLDER}/tier5.txt"

sort -u \
	"${SPECIAL_FOLDER}/tier4.txt" \
	"${SPECIAL_FOLDER}/tier5.txt" \
	"${SPECIAL_FOLDER}/traders.txt" \
	> "${SPECIAL_FOLDER}/special.txt"

for top in "${SPECIAL_FOLDER}"/top*.txt; do
	while read -r prefab; do
		grep -Piq "\\b${prefab}\\b" <<<"${xmls[@]}" || \
			echo "${prefab} in ${top} is not valid"
	done <"${top}"
done

