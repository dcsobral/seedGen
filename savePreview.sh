#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:=/mnt/c/Users/Daniel/Desktop/RH5.5Server}"

if [[ $# -ne 2 ]]; then
	echo >&2 "$0 <size> <seed>"
	exit 1
fi

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIZE="${1}"
IMGSIZE="${1}x${1}"
SEED="${2}"
NAME="${SEED}-${SIZE}"
PREVIEW="${NAME}.png"
PREFABS="${NAME}.xml"
COUNTY_FILE="${NAME}.txt"

cd  "${F7D2D}"
LINE=$(grep -m 1 "Generating county" log.txt)
COUNTY=$(cut -d "'" -f 2 <<<"$LINE")

cd "UserData/GeneratedWorlds/${COUNTY}"
convert biomes.png \
	\( splat3.png -alpha off -transparent black -fill '#0000ff' -opaque '#00ff00' \) \
	-composite \
	\( -size "${IMGSIZE}" -depth 16 gray:dtm.raw -flip -auto-level \) \
	-compose blend -set option:compose:args 50 -composite \
	\( radiation.png \
		-channel rgba -fill "rgba(255,0,0,0.5)" -opaque "rgb(255,0,0)" +channel  \
		-transparent black \
		-resize "${IMGSIZE}" \
	\) \
	-compose Over -composite \
	"${PREVIEW}"

cp prefabs.xml "${PREFABS}"
echo "$COUNTY" > "${COUNTY_FILE}"

# Prefab preview
if [[ ! -f nodraw ]]; then
	"${BIN}/drawPrefabs.sh" prefabs.xml "${PREVIEW}" "${SIZE}"
	zip "${NAME}" "${PREVIEW}" "output-${PREVIEW}" "${PREFABS}" "${COUNTY_FILE}"
else
	echo "Skipping prefab drawing"
	zip "${NAME}" "${PREVIEW}" "${PREFABS}" "${COUNTY_FILE}"
fi

mkdir -p "${F7D2D}/previews"
mv "${NAME}.zip" "${F7D2D}/previews/"

