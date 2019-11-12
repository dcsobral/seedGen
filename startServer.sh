#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"
: "${LOG:=${F7D2D}/log.txt}"

if [[ $# -ne 2 ]]; then
	echo >&2 "$0 <size> <seed>"
	exit 1
fi

SIZE="${1}"
SEED="${2}"

cd "${F7D2D}"

rm -f "${LOG}" || { sleep 30; rm -f "${LOG}"; }
rm -fr UserData/

./7DaysToDieServer.exe -quit -batchmode -nographics -logfile "$(wslpath -w "${LOG}")" -configfile=serverconfig.xml -UserDataFolder=UserData -GameWorld=RWG -WorldGenSize="${SIZE}" -WorldGenSeed="${SEED}" -GameName=test -verbose -dedicated &

