#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

usage() {
	cat >&2 <<-USAGE
		$0 [options] <size> <seed>

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

if [[ $# -ne 2 ]]; then
	usage
fi

SIZE="$1"
SEED="$2"
BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="${F7D2D}/log.txt"

echo "Generating seed '$SEED' at $SIZE"
sleep 1 # Last chance to abort

SECONDS=0
#"${BIN}/startServer.sh" "$SIZE" "${SEED}" > log.startServer.txt
"${BIN}/startClient.sh" "${ARGS[@]}" "$SIZE" "${SEED}" > log.startClient.txt
duration=$SECONDS

if grep "Generation Complete" "$LOG"; then
	echo "World generated in $((duration / 60)) minutes and $((duration % 60)) seconds"

	# Get county name
	# shellcheck disable=SC2012
	if ! COUNTY=$( \
		ls -1rt "${F7D2D}/UserData/GeneratedWorlds/" \
			| tail -1 \
		) && [[ -n $COUNTY ]]; then
		echo >&2 "Cannot figure out generated world"
		exit 1
	fi

	WORLD="${F7D2D}/UserData/GeneratedWorlds/$COUNTY"

	echo "Rating (${RATE_OPTS:-defaults}):"
	"${BIN}/rate.py" ${RATE_OPTS-} --size "${SIZE}" "${WORLD}/prefabs.xml"

	mkdir -p "${F7D2D}/previews"

	"${BIN}/savePreview.sh" \
		--world "${WORLD}" \
		--name "${COUNTY}" \
		--output "${F7D2D}/previews/${SEED}-${SIZE}.zip" \
		--options "${ARGS[@]}" --endoptions \
		"${SIZE}" "${SEED}" 2>&1 | tee log.savePreview.txt
	echo "World preview saved"
else
	echo "Generation aborted after $((duration / 60)) minutes and $((duration % 60)) seconds"
	exec "$0" "$@"
fi

TASK_LIST="$(tasklist.exe)"
if grep -q ^7DaysToDieServer.exe <<<"$TASK_LIST"; then
	taskkill.exe /IM "7DaysToDieServer.exe" /F /T
fi

if grep -q ^7DaysToDie.exe <<<"$TASK_LIST"; then
	taskkill.exe /IM "7DaysToDie.exe" /F /T
fi

