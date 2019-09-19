#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

if [[ $# -ne 4 ]]; then
        echo >&2 "$0 <coords> <dimension> <rotation> <size>"
        exit 1
fi

coordsFor() {
        declare -g tl br dim
        declare COORDS DIM ROT
        COORDS="$1"
        DIM="$2"
        ROT="$3"
	SIZE=$(($4 / 2))

        WIDTH="${DIM%%,*}"
        HEIGHT="${DIM##*,}"

        if [[ $ROT =~ [13] ]]; then
                tmp="$WIDTH"
                WIDTH="$HEIGHT"
                HEIGHT="$tmp"
        fi

        X1=$((${COORDS%%,*} + SIZE))
        Z2=$((-(${COORDS##,*}) + SIZE))
        X2=$((X1 + WIDTH))
        Z1=$((Z2 - HEIGHT))

        tl="${X1},${Z1}"
        br="${X2},${Z2}"
        dim="${WIDTH},${HEIGHT}"

	echo "$tl $br $dim"
}

coordsFor "$@"

