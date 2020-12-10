#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

if [[ -L "$F7D2D" ]]; then
	F7D2D="$(readlink "$F7D2D")"
fi

: "${LOG:=${F7D2D}/log.txt}"
: "${AHK:=/mnt/c/Program Files/AutoHotkey/AutoHotkey.exe}"

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

while [[ $# -gt 0 && $1 == -* ]]; do
	case "$1" in
	--towns)
		shift
		RWGTowns="$1"
		;;
	--rivers)
		shift
		RWGRivers="$1"
		;;
	--craters)
		shift
		RWGCraters="$1"
		;;
	--cracks)
		shift
		RWGCracks="$1"
		;;
	--lakes)
		shift
		RWGLakes="$1"
		;;
	--plains)
		shift
		RWGPlains="$1"
		;;
	--hills)
		shift
		RWGHills="$1"
		;;
	--mountains)
		shift
		RWGMountains="$1"
		;;
	--random)
		shift
		RWGRandom="$1"
		;;
	*)
		usage
		;;
	esac
	shift
done

if [[ $# -ne 2 ]]; then
	usage
fi

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIZE="${1}"
SEED="${2}"

cd "${F7D2D}"

rm -f "${LOG}" || { sleep 30; rm -f "${LOG}"; }
rm -fr UserData/
touch "${LOG}"

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
"${AHK}" "$(wslpath -w "${BIN}/previewSeed.ahk")" "${SIZE}" "${SEED}" \
	"${RWGTowns:-Default}" \
	"${RWGRivers:-Default}" \
	"${RWGCraters:-Default}" \
	"${RWGCracks:-Default}" \
	"${RWGLakes:-Default}" \
	"${RWGPlains:-Default}" \
	"${RWGHills:-Default}" \
	"${RWGMountains:-Default}" \
	"${RWGRandom:-Default}"

# Wait for generation to finish
grep -E -m 1 "BloodMoon SetDay|Opening OnScreen keyboard failed|aborting generation|Crash!!!" <(tail  ---disable-inotify --max-unchanged-stats=5 --sleep-interval=5 -F "${LOG}")
sleep 5

# Exit game
"${AHK}" "$(wslpath -w "${BIN}/exitGame.ahk")" || echo >& 2 "Unable to stop 7 Days to Die"
sleep 1

