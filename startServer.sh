#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:=/mnt/c/Users/Daniel/Desktop/RH5.5Server}"

if [[ $# -ne 2 ]]; then
	echo >&2 "$0 <size> <seed>"
	exit 1
fi

SIZE="${1}"
SEED="${2}"

cd "${F7D2D}"

rm -f log.txt || { sleep 30; rm -f log.txt; }
rm -fr UserData/

./7DaysToDieServer.exe -quit -batchmode -nographics -logfile log.txt -configfile=serverconfig.xml -UserDataFolder=UserData -GameWorld=RWG -WorldGenSize="${SIZE}" -WorldGenSeed="${SEED}" -GameName=test -verbose -dedicated &

