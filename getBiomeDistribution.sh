#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

if [[ $# -ne 4 ]]; then
        echo >&2 "$0 <prefabs.xml> <biomes.png> <size> <seed>"
        exit 1
fi

coordsFor() {
        declare -g tr bl
        declare COORDS DIM ROT
        COORDS="$1"
        DIM="$2"
        ROT="$3"

        WIDTH="${DIM%%,*}"
        HEIGHT="${DIM##*,}"

        if [[ $ROT =~ [13] ]]; then
                tmp="$WIDTH"
                WIDTH="$HEIGHT"
                HEIGHT="$tmp"
        fi

        X1=$((${COORDS%%,*} + CENTER))
        Z2=$((-(${COORDS##,*}) + CENTER))
        X2=$((X1 + WIDTH))
        Z1=$((Z2 - HEIGHT))

        tr="$((X2)),$((Z1))"
	bl="$((X1)),$((Z2))"
}

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

XML="$1"
IMG="$2"
SIZE="$3"
SEED="$4"
IMGSIZE="${SIZE}x${SIZE}"
NAME="$SEED-$SIZE"
CENTER="$((SIZE / 2))"
COUNT_MASK="mask-count-$NAME.txt"
AREA_MASK="mask-area-$NAME.txt"
COUNT="$NAME-biome-count.txt"

declare -g -A DIM
declare -a MAPFILE

mapfile < <(xmlstarlet sel -t -m "/prefabs/decoration" -v "@name" -o ";" -v "@position" -o ";" -v "@rotation" -n - < "$XML")

rm -f "$COUNT_MASK" "$AREA_MASK"
for decoration in "${MAPFILE[@]}"; do
        IFS=';' read -r prefab coords rotation <<<"$decoration"

        if [[ -n ${DIM["$prefab"]+abc} ]]; then
                dim="${DIM["$prefab"]}"
        else
                dim="$("${BIN}/prefabSize.sh" "${prefab}")"
                DIM["$prefab"]="$dim"
        fi
        coordsFor "${coords}" "${dim}" "${rotation}"

	echo "point ${bl}" >> "${COUNT_MASK}"
	echo "rectangle ${tr} ${bl}" >> "${AREA_MASK}"
done

declare -A BIOMES

BIOMES[Forest]='#004000FF'
BIOMES[Burnt Forest]='#BA00FFFF'
BIOMES[Wasteland]='#FFA800FF'
BIOMES[Desert]='#FFE477FF'
BIOMES[Snow]='#FFFFFFFF'

# Change from histogram data to "<color> <count>"
SUBST='s/^ *([0-9]*):.* (#[0-9A-Fa-f]*) .*$/\2,\1/'
# Replace colors with biome names
for biome in "${!BIOMES[@]}"; do
	SUBST="$SUBST;s/${BIOMES[$biome]}/$biome/"
done
# Delete empty region
SUBST="$SUBST;/#000000FF/d"

echo 'Biome,Prefab Count,Prefab Area,Area' > "${COUNT}"
listBiomes() {
	printf "%s\n" "${!BIOMES[@]}" | sort
}

showPrefabs() {
	join -t , \
		<(convert "$IMG" \
			\( -size "${IMGSIZE}" xc:black -fill white -draw "@${COUNT_MASK}" -transparent white \) \
			-composite \
			-format %c histogram:info:- | sed -Ee "$SUBST" | sort) \
		<(convert "$IMG" \
			\( -size "${IMGSIZE}" xc:black -fill white -draw "@${AREA_MASK}" -transparent white \) \
			-composite \
			-format %c histogram:info:- | sed -Ee "$SUBST" | sort)
}

showBiomes() {
	convert "$IMG" -format %c histogram:info:- | sed -Ee "$SUBST" | sort
}

join -a 1 -e 0 -o 1.1,2.2,2.3,2.4 -t , <(listBiomes) \
	<(join -a 2 -e 0 -o 2.1,1.2,1.3,2.2 -t , <(showPrefabs) <(showBiomes)) >> "${COUNT}"

echo "$COUNT"

