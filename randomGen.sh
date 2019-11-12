#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:=/mnt/c/Users/Daniel/Desktop/RH5.5Server}"

if [[ $# -ne 2 ]]; then
	echo >&2 "$0 <size> <seed>"
	exit 1
fi

SIZE="$1"
SEED="$2"
BIN="$(cd "$(dirname "$0")" && pwd)"
LOG="${F7D2D}/log.txt"

echo "Generating seed '$SEED' at $SIZE"
sleep 1 # Last chance to abort
SECONDS=0
"${BIN}/startServer.sh" "$SIZE" "${SEED}" > log.startServer.txt
until [ -f "${LOG}" ]
do
     sleep 1
done
grep -E -m 1 "StartGame done|aborting generation|Crash!!!" <(tail  ---disable-inotify --max-unchanged-stats=5 --sleep-interval=5 -F "${LOG}")
duration=$SECONDS
"${BIN}/shutdown.expect" > log.shutdown.txt
if grep -q "StartGame done" "$LOG"; then
	echo "World generated in $((duration / 60)) minutes and $((duration % 60)) seconds"
	"${BIN}/savePreview.sh" "${SIZE}" "${SEED}" > log.savePreview.txt
	echo "World preview saved"
else
	echo "Generation aborted after $((duration / 60)) minutes and $((duration % 60)) seconds"
	exec "$0" "$@"
fi

TASK_LIST="$(tasklist.exe)"
if grep -q ^7DaysToDieServer.exe <<<"$TASK_LIST"; then
	taskkill.exe /IM "7DaysToDieServer.exe" /F /T
fi

