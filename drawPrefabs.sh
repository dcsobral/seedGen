#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:=/mnt/c/Users/Daniel/Desktop/RH5.5Server}"

if [[ $# -ne 3 ]]; then
        echo >&2 "$0 <prefabs.xml> <image> <size>"
        exit 1
fi

coordsFor() {
        declare -g tl br dim
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

        X1=$((${COORDS%%,*} + ${SIZE}))
        Z2=$((-(${COORDS##,*}) + ${SIZE}))
        X2=$((X1 + WIDTH))
        Z1=$((Z2 - HEIGHT))

        tl="${X1},${Z1}"
        br="${X2},${Z2}"
        dim="${WIDTH},${HEIGHT}"
}

PREFABS="${F7D2D}/Data/Prefabs"
BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

XML="$1"
IMG="$2"
SIZE="$(($3 / 2))"
DRAW="draw-${XML%.xml}.txt"
declare -g -A DIM
declare -a MAPFILE

mapfile < <(xmlstarlet sel -t -m "/prefabs/decoration" -v "@name" -o ";" -v "@position" -o ";" -v "@rotation" -n "$XML")

rm -f "${DRAW}"
for decoration in "${MAPFILE[@]}"; do
        IFS=';' read  prefab coords rotation <<<"$decoration"

        #IFS=';' read tl br dim < <("${BIN}/prefabCoords.sh" "${prefab}" "${coords}" "${rotation}")
        if [[ -n ${DIM["$prefab"]+abc} ]]; then
                dim="${DIM["$prefab"]}"
        else
                dim="$("${BIN}/prefabSize.sh" "${prefab}")"
                DIM["$prefab"]="$dim"
        fi
        coordsFor "${coords}" "${dim}" "${rotation}"
        if [[ -f "${PREFABS}/${prefab}.jpg" ]]; then
                echo "image multiply ${tl} ${dim} '${PREFABS}/${prefab}.jpg'" >> "${DRAW}"
        else
                echo "rectangle ${tl} ${br}" >> "${DRAW}"
        fi
done

convert "${IMG}" -strokewidth 0 -fill "rgba( 0, 0, 0 , 0.5 )" -draw "@${DRAW}" "output-${IMG}"

