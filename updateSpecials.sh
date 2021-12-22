#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${SPECIAL_FOLDER:=${BIN}/special}"

SKYSCRAPERS="${SPECIAL_FOLDER}/skyscrapers.txt"
STORES="${SPECIAL_FOLDER}/stores.txt"
DOWNTOWN="${SPECIAL_FOLDER}/downtown.txt"
INDUSTRIAL="${SPECIAL_FOLDER}/industrial.txt"
TRADERS="${SPECIAL_FOLDER}/traders.txt"
TIER3="${SPECIAL_FOLDER}/tier3.txt"
TIER4="${SPECIAL_FOLDER}/tier4.txt"
TIER5="${SPECIAL_FOLDER}/tier5.txt"
SPECIAL="${SPECIAL_FOLDER}/special.txt"

: > "$SKYSCRAPERS"
: > "$STORES"
: > "$DOWNTOWN"
: > "$INDUSTRIAL"
: > "$TRADERS"
: > "$TIER3"
: > "$TIER4"
: > "$TIER5"
: > "$SPECIAL"

join_by() { local IFS="$1"; shift; echo "$*"; }

mapfile -t < <(xmlstarlet sel -t \
	-m "/rwgmixer/district/property[@name='poi_required_tags_all']/@value" \
	-v . -n "${F7D2D}/Data/Config/rwgmixer.xml"  \
	| tr ',' '\n' \
	| sort -u)

REGEX="(\\Q$(join_by $'\t' "${MAPFILE[@]}" | sed 's/\t/\\E|\\Q/g')\\E)"

# downtown.txt  industrial.txt  skyscrapers.txt  special.txt  stores.txt  tier3.txt  tier4.txt  tier5.txt  top15.txt  top7.txt  traders.txt

declare -a PREFABS

mapfile -t PREFABS < <(find "${F7D2D}/Data/Prefabs" -name Test -prune \
	-or -name 'aaa_*' -prune \
	-or -type f -name '*.xml' \( \
		-exec grep -Piq 'property name="Tags" value="[^"]*\b'"$REGEX"'\b[^"]*"' {} \; \
		-or -name 'rwg_tile_*' \
		-or -name 'part_*' \
	\) \
	-print | sort)

for PREFAB in "${PREFABS[@]}"; do
	NAME="$(basename -s .xml "${PREFAB}")"

	if [[ "$NAME" == skyscraper_* && "${NAME}" != skyscraper_04 ]]; then
		echo "$NAME" >> "$SKYSCRAPERS"
	fi


	if [[ "$NAME" == store_* ]]; then
		echo "$NAME" >> "$STORES"
	fi

	if grep -Piq 'property name="Tags" value="[^"]*\bdowntown\b[^"]*"' "$PREFAB"; then
		echo "$NAME" >> "$DOWNTOWN"
	fi

	if grep -Piq 'property name="Tags" value="[^"]*\bindustrial\b[^"]*"' "$PREFAB"; then
		echo "$NAME" >> "$INDUSTRIAL"
	fi

	if grep -Piq 'property name="Tags" value="[^"]*\btrader\b[^"]*"' "$PREFAB"; then
		echo "$NAME" >> "$TRADERS"
	fi

	if grep -iq "DifficultyTier.*3" "$PREFAB"; then
		echo "$NAME" >> "$TIER3"
	fi

	if grep -iq "DifficultyTier.*4" "$PREFAB"; then
		echo "$NAME" >> "$TIER4"
	fi

	if grep -iq "DifficultyTier.*5" "$PREFAB"; then
		echo "$NAME" >> "$TIER5"
	fi
done

cat "$TIER4" "$TIER5" "$TRADERS" | sort -u > "$SPECIAL"

