#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

usage() {
	cat >&2 <<-USAGE
		$0 [options] <count> [{<size>}]

		Options:
		  --towns Yes | No
		  --rivers None | Few | Default | Many
		  --craters None | Few | Default | Many
		  --cracks None | Few | Default | Many
		  --lakes None | Few | Default | Many
		  --plains 0 .. 10
		  --hills 0 .. 10
		  --mountains 0 .. 10
		  --random 0 .. 10
	USAGE
	exit 1
}

declare -a ARGS
ARGS=( )
while [[ $# -gt 0 && $1 == -* ]]; do
        case "$1" in
        --towns | --rivers | --craters | --cracks | --lakes | --plains | --hills | --mountains | --random)
		ARGS=( "${ARGS[@]}" "$1" "$2" )
		shift 2
                ;;
        *)
		usage
		;;
        esac
done

if [[ $# -lt 1 ]]; then
	usage
fi

ellapsed() {
        echo -n "$(date -u -d @${SECONDS} +"%T")"
}

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECONDS=0
TOTAL="$1"
shift
SIZES=("$@")

if [[ ${#SIZES[@]} -eq 0 ]]; then
        SIZES=( 6144 8192 10240 )
fi

for size in "${SIZES[@]}"; do
	[[ -f stop ]] && break
        COUNT=0
        while [[ $COUNT -lt $TOTAL ]]; do
                [[ -f stop ]] && break
                SEED="$("${BIN}"/seed.sh)"
                "${BIN}"/genSeed.sh "${ARGS[@]}" "$size" "${SEED}"
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
