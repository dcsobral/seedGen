#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

if [[ $# -lt 3 || $# -gt 4 ]]; then
        echo >&2 "$0 <prefabs.xml> <biomes.png> <size> [<seed>]"
        exit 1
fi

coordsFor() {
        declare -g bl human
        declare COORDS DIM ROT
        COORDS="$1"
        DIM="$2"
        ROT="$3"

        WIDTH="${DIM%%,*}"
        HEIGHT="${DIM##*,}"

	if [[ $((ROT % 2)) -eq 1 ]]; then
                tmp="$WIDTH"
                WIDTH="$HEIGHT"
                HEIGHT="$tmp"
        fi

	X=$((${COORDS%%,*}))
	Z=$((${COORDS##,*}))
        X1=$((X + CENTER))
        Z2=$((-Z + CENTER))

	bl="$((X1)),$((Z2))"
	if [[ $Z -lt 0 ]]; then
		human="$((-Z)) S"
	else
		human="$Z N"
	fi

	if [[ $X -lt 0 ]]; then
		human="$human $((-X)) W"
	else
		human="$human $X E"
	fi
}

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

XML="$1"
IMG="$2"
SIZE="$3"
SEED="${4:-}"
NAME="$SEED-$SIZE"
CENTER="$((SIZE / 2))"
OUTPUT="$NAME-traders.txt"

declare -g -A DIM
declare -a MAPFILE
declare -A BIOMES

# Replace colors with biome names
BIOMES[Forest]='0,64,0'
BIOMES[Burnt Forest]='186,0,255'
BIOMES[Wasteland]='255,168,0'
BIOMES[Desert]='255,228,119'
BIOMES[Snow]='255,255,255'
SUBST=""
for biome in "${!BIOMES[@]}"; do
        SUBST="${SUBST:+${SUBST};}s/${BIOMES[$biome]}/$biome/"
done

getTraderData() {
	mapfile < <(xmlstarlet sel -t -m "/prefabs/decoration" -v "@name" -o ";" -v "@position" -o ";" -v "@rotation" -n - < "$XML")

	for decoration in "${MAPFILE[@]}"; do
		if [[ ! $decoration =~ trader* ]]; then
			continue
		fi

		IFS=';' read -r prefab coords rotation <<<"$decoration"

		if [[ -n ${DIM["$prefab"]+abc} ]]; then
			dim="${DIM["$prefab"]}"
		else
			dim="$("${BIN}/prefabSize.sh" "${prefab}")"
			DIM["$prefab"]="$dim"
		fi
		coordsFor "${coords}" "${dim}" "${rotation}"

		echo -n  "$prefab $human "
		convert "$IMG[1x1+${bl/,/+}]" \
			-format "%[fx:floor(255*u.r)],%[fx:floor(255*u.g)],%[fx:floor(255*u.b)]\n" \
			info:- \
			| sed -Ee "$SUBST"
	done
}

if [[ $# -eq 4 ]]; then
	getTraderData > "${OUTPUT}"
else
	getTraderData
fi

