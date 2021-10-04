#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

join_by() { local IFS="$1"; shift; echo "$*"; }

mapfile -t < <(xmlstarlet sel -t \
	-m "/rwgmixer/district/property[@name='poi_required_tags_all']/@value" \
	-v . -n "${F7D2D}/Data/Config/rwgmixer.xml"  \
	| tr ',' '\n' \
	| sort -u)

REGEX="(\\Q$(join_by $'\t' "${MAPFILE[@]}" | sed 's/\t/\\E|\\Q/g')\\E)"

find "${F7D2D}/Data/Prefabs" -name Test -prune \
	-or -name 'aaa_*' -prune \
	-or -type f -name '*.xml' \( \
		-exec grep -Piq 'property name="Tags" value="[^"]*\b'"$REGEX"'\b[^"]*"' {} \; \
		-or -name 'rwg_tile_*' \
		-or -name 'part_*' \
	\) \
	-printf '%f\0' \
	| xargs -0 basename -s .xml
