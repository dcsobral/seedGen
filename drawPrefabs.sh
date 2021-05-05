#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

if [[ $# -lt 3 || $# -gt 4 ]]; then
        echo >&2 "$0 <prefabs.xml> <image> <size> [<spawnspoints.xml>]"
        exit 1
fi

[[ ! -f splatmap.png ]] && convert splat3.png \
        -alpha off -transparent black \
        -fill '#9c8c7b' -opaque '#00ff00' \
        -fill '#ceb584' -opaque '#ff0000' \
        splatmap.png

coordsFor() {
        declare -g tl br dim
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

        X1=$((${COORDS%%,*} + CENTER))
        Z2=$((-(${COORDS##,*}) + CENTER))
        X2=$((X1 + WIDTH))
        Z1=$((Z2 - HEIGHT))

	tl="$((X1)),$((Z1))"
	br="$((X2)),$((Z2))"
	tlb="$((X1 + 1)),$((Z1 + 1))"
	brb="$((X2 - 2)),$((Z2 - 2))"
        dim="${WIDTH},${HEIGHT}"
}

PREFABS="${F7D2D}/Data/Prefabs"
BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

XML="$1"
IMG="$2"
SIZE="$3"
SPAWN_XML="${4:-spawnspoints.xml}"
CENTER="$((SIZE / 2))"
NAME="${XML%.xml}"
DRAW="draw-${NAME}.txt"
ZONING="zoning-${NAME}.txt"
THUMB="thumb-${NAME}.txt"
SPAWN="spawn-${NAME}.txt"
GRID="grid-${NAME}.txt"
COORDS="coords-${NAME}.txt"
PREVIEW="prefabs-${IMG}"

declare -g -A DIM
declare -g -A ZONE
declare -a MAPFILE

mapfile < <(xmlstarlet sel -t -m "/prefabs/decoration" -v "@name" -o ";" -v "@position" -o ";" -v "@rotation" -n - < "$XML")

echo "stroke-width 1 fill 'rgba(0,0,0,0.5)'" > "${DRAW}"
echo "stroke-width 3 fill none" > "${ZONING}"
echo "stroke-width 1 stroke black" > "${THUMB}"
for decoration in "${MAPFILE[@]}"; do
        IFS=';' read -r prefab coords rotation <<<"$decoration"

        #IFS=';' read tl br dim < <("${BIN}/prefabCoords.sh" "${prefab}" "${coords}" "${rotation}")
        if [[ -n ${DIM["$prefab"]+abc} ]]; then
                dim="${DIM["$prefab"]}"
        else
                dim="$("${BIN}/prefabSize.sh" "${prefab}")"
                DIM["$prefab"]="$dim"
        fi
        coordsFor "${coords}" "${dim}" "${rotation}"
	if [[ "${prefab}" =~ rwg_tile* ]]; then
		PREFAB_PREVIEW="${PREFABS}/RWGTiles/${prefab}.jpg"
		x_offset=$((-WIDTH / 2))
		z_offset=$((-HEIGHT / 2))
		tl="$((X1 - x_offset)),$((Z1 - z_offset))"
		echo "push graphic-context" >> "${DRAW}"
		echo "translate ${tl}" >> "${DRAW}"
		echo "rotate $(((4 - rotation) % 4 * 90))" >> "${DRAW}"
		echo "image over ${x_offset},${z_offset} ${dim} '${PREFAB_PREVIEW}'" >> "${DRAW}"
		echo "pop graphic-context" >> "${DRAW}"
	else
		PREFAB_PREVIEW="${PREFABS}/${prefab}.jpg"
		if [[ ! -f "${PREFAB_PREVIEW}" ]]; then
			PREFAB_PREVIEW="$(find "${PREFABS}" -name "${prefab}.jpg" -print)"
		fi

		if [[ -n "${PREFAB_PREVIEW}" && -f "${PREFAB_PREVIEW}" ]]; then
			echo "image over ${tl} ${dim} '${PREFAB_PREVIEW}'" >> "${DRAW}"
		else
			echo "rotation 0 rectangle ${tl} ${br}" >> "${DRAW}"
		fi
	fi

        if [[ -n ${ZONE["$prefab"]+abc} ]]; then
                zone="${ZONE["$prefab"]}"
        else
                zone="$("${BIN}/prefabZoningColor.sh" "${prefab}")"
                ZONE["$prefab"]="$zone"
        fi
	echo "stroke $zone rectangle ${tlb} ${brb}" >> "${ZONING}"
	echo "fill $zone rectangle ${tl} ${br}" >> "${THUMB}"
done

echo "stroke-width 2 stroke black fill white stroke-opacity 0.6 fill-opacity 0.6 stroke-dasharray 16 16" > "${GRID}"
echo "stroke-width 4 fill white stroke black stroke-opacity 0.6 fill-opacity 0.6" > "${COORDS}"
echo "font Helvetica-Bold font-size 96" >> "${COORDS}"
Ms=$((CENTER / 512 - 1))
for m in $(seq $((-Ms)) $((Ms))); do
	P=$((m * 512 + CENTER))
	echo "path 'M 0,$P L $SIZE,$P'" >> "${GRID}"
	echo "path 'M $P,0 L $P,$SIZE'" >> "${GRID}"
	printf "text %d,%d '%4d'" 4 $((P - 8)) $((-m * 512)) >> "${COORDS}"
	printf "text %d,%d '%4d'" $((SIZE - 264)) $((P - 8)) $((-m * 512)) >> "${COORDS}"
	printf "text %d,%d '%4d'" $((P + 8)) $((SIZE - 8)) $((m * 512)) >> "${COORDS}"
	printf "text %d,%d '%4d'" $((P + 8)) 72 $((m * 512)) >> "${COORDS}"
done

echo "stroke-width 1 fill red" > "${SPAWN}"
if [[ -f "$SPAWN_XML" ]]; then
	mapfile < <(xmlstarlet sel -t -m "/spawnpoints/spawnpoint" -v "@position" -n - < "$SPAWN_XML")
	for spawnpoint in "${MAPFILE[@]}"; do
		IFS=',' read -r x _ y <<<"$spawnpoint"
		x=$((x+CENTER))
		y=$((-y+CENTER))
		echo "circle $x,$y $((x+8)),$((y+8))" >> "${SPAWN}"
	done
fi

convert "${IMG}" \
	-draw "@${DRAW}" \
	-draw "@${ZONING}" \
	-draw "@${GRID}" \
	-draw "@${COORDS}" \
	splatmap.png -composite \
	-draw "@${SPAWN}" \
	"${PREVIEW}"

mkdir -p thumbs
NAILSIZE="$((SIZE/16))"
convert "${IMG}" \
	-draw "@${THUMB}" \
	-draw "@${SPAWN}" \
	-depth 8 \
	-resize "${NAILSIZE}x${NAILSIZE}" \
	"thumbs/${IMG}"

echo "${PREVIEW}"

