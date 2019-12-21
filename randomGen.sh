#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

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
#"${BIN}/startServer.sh" "$SIZE" "${SEED}" > log.startServer.txt
"${BIN}/startClient.sh" "$SIZE" "${SEED}" > log.startClient.txt
duration=$SECONDS

if grep -q "BloodMoon SetDay" "$LOG"; then
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

