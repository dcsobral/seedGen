#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

if [[ $# -lt 1 ]]; then
        echo >&2 "$0 <count> [{size}]"
        exit 1
fi

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
        COUNT=0
        while [[ $COUNT -lt $TOTAL ]]; do
                SEED="$("${BIN}"/seed.sh)"
                "${BIN}"/randomGen.sh $size "${SEED}"
                COUNT=$((COUNT + 1))
                echo "World #${COUNT} for size ${size} done (time elapsed: $(ellapsed))"
                [[ -f stop ]] && break 2
        done
done

[[ -f stop ]] && rm stop

echo "Finished generating ${TOTAL} worlds for sizes ${SIZES[*]} in $(ellapsed)."
