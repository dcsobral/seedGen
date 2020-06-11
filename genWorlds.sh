#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

if [[ $# -lt 1 ]]; then
        echo >&2 "$0 <count> [{size}]"
        exit 1
fi

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

ellapsed() {
        echo -n "$(date -u -d @${SECONDS} +"%T")"
}

BIN="$(cd "$(dirname "$0")" && pwd)"
SECONDS=0
TOTAL="$1"
shift
SIZES=("$@")

if [[ ${#SIZES[@]} -eq 0 ]]; then
        SIZES=( 4096 6144 8192 )
fi

for size in "${SIZES[@]}"; do
	[[ -f stop ]] && break
        COUNT=0
        while [[ $COUNT -lt $TOTAL ]]; do
                [[ -f stop ]] && break
                SEED="$("${BIN}"/seed.sh)"
                "${BIN}"/genSeed.sh "$size" "${SEED}"
                COUNT=$((COUNT + 1))
                echo "World #${COUNT} for size ${size} done (time elapsed: $(ellapsed))"
        done
done

if [[ -f stop ]]; then
	echo >&2 "'stop' file found. Aborting."
	rm stop
	exit 1
fi

echo "Finished generating ${TOTAL} worlds for sizes ${SIZES[*]} in $(ellapsed)."
