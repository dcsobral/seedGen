#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"
: "${LOG:=${F7D2D}/log.txt}"
: "${AHK:=/mnt/c/Program Files/AutoHotkey/AutoHotkey.exe}"

if [[ $# -ne 2 ]]; then
	echo >&2 "$0 <size> <seed>"
	exit 1
fi

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIZE="${1}"
SEED="${2}"

cd "${F7D2D}"

rm -f "${LOG}" || { sleep 30; rm -f "${LOG}"; }
rm -fr UserData/

# Start game
./7DaysToDie.exe -logfile "$(wslpath -w "${LOG}")" \
	-configfile=serverconfig.xml \
	-UserDataFolder=UserData \
	-popupwindow \
	-verbose &

# Wait for log file to be available
until [ -f "${LOG}" ]
do
     sleep 1
done

# Wait for game ready
grep -E -m 1 "WorldStaticData.Init" <(tail  ---disable-inotify --max-unchanged-stats=5 --sleep-interval=5 -F "${LOG}") | tee /dev/stderr

# Generate seed
"${AHK}" "$(wslpath -w "${BIN}/previewSeed.ahk")" "${SIZE}" "${SEED}"

# Wait for generation to finish
grep -E -m 1 "BloodMoon SetDay|aborting generation|Crash!!!" <(tail  ---disable-inotify --max-unchanged-stats=5 --sleep-interval=5 -F "${LOG}")
sleep 2

# Exit game
"${AHK}" "$(wslpath -w "${BIN}/exitGame.ahk")"
sleep 1

