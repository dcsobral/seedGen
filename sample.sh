#!/usr/bin/env bash
set -euo pipefail

: "${SIZE:=6144}"
: "${SEED:=$(seed.sh)}"

OUTDIR="${F7D2D}/sample/$SEED"
THUMBS="${OUTDIR}/thumbs"

mkdir -p "${OUTDIR}"

timeIt() {
	duration=$SECONDS
	echo "World generated in $((duration / 60)) minutes and $((duration % 60)) seconds"
}

genOpt() {
	declare OPT_NAME
	OPT_NAME="$1"
	shift
	declare -a OPTS
	OPTS=( "$@" )
	declare opt
	for opt in "${OPTS[@]}"; do
		NAME="${OPT_NAME}-${opt}"

		if [[ -f "${OUTDIR}/${NAME}.zip" ]]; then
			echo >&2 "Skipping ${NAME}"
			continue
		fi

		rm -fr "${F7D2D}/UserData"
		SECONDS=0
		startClient.sh "--${OPT_NAME}" "${opt}" $SIZE $SEED
		timeIt

		COUNTY=$( ls -1rt "${F7D2D}/UserData/GeneratedWorlds/" | tail -1 )
		WORLD="${F7D2D}/UserData/GeneratedWorlds/${COUNTY}"
		savePreview.sh --world "${WORLD}" --name "${NAME}" --output "${OUTDIR}/${NAME}.zip" \
			--options "--${OPT_NAME}" "${opt}" --endoptions $SIZE "${NAME}"

		TASK_LIST="$(tasklist.exe)"
		if grep -q ^7DaysToDie.exe <<<"$TASK_LIST"; then
			taskkill.exe /IM "7DaysToDie.exe" /F /T
		fi
	done
}

for option in rivers craters cracks lakes; do
	genOpt $option None Few Default Many
done

declare -a SEQ
SEQ=( $( seq 0 10 ) )
for option in plains hills mountains random; do
	genOpt $option "${SEQ[@]}"
done

cd "${OUTDIR}"
find . -name '*.zip' -print0 | xargs -0 -x -n1 -i unzip -u {} 'thumbs/*'
cd "${THUMBS}"
montage -geometry "+4+3" \
	-tile 4x \
	-pointsize 48 -label '%c' \
	cracks-None-${SIZE}.png cracks-{Few,Default,Many}-${SIZE}.png \
	rivers-None-${SIZE}.png rivers-{Few,Default,Many}-${SIZE}.png \
	craters-None-${SIZE}.png craters-{Few,Default,Many}-${SIZE}.png \
	lakes-None-${SIZE}.png lakes-{Few,Default,Many}-${SIZE}.png \
	features.png
montage -geometry "+4+3" \
	-tile 11x \
	-pointsize 48 -label '%c' \
	plains-[0-9]-* plains-10* \
	hills-[0-9]-* hills-10* \
	mountains-[0-9]-* mountains-10* \
	random-[0-9]-* random-10* \
	terrain.png

cd "${OUTDIR}"
find . -name '*.zip' -print0 | xargs -0 -x -n1 -i unzip -d dtm -u {} '*-dtm.png'
cd "${OUTDIR}/dtm"
for feature in rivers craters cracks lakes; do
	for level in Few Default Many; do
		[[ -f ${feature}-${level}-${SIZE}-diff.png ]] && continue
		compare \
			-highlight-color red \
			-lowlight-color black \
			-set label $level \
			${feature}-None-${SIZE}-dtm.png \
			${feature}-${level}-${SIZE}-dtm.png \
			${feature}-${level}-${SIZE}-diff.png \
			|| :  # Do not fail if images are different
	done
done

cd "${THUMBS}"
DIM=$((SIZE / 16))
for feature in rivers craters cracks lakes; do
	for level in Few Default Many; do
		# [[ -f ${feature}-${level}-${SIZE}-diff.png ]] && continue
		convert \
			${feature}-${level}-${SIZE}.png \
			\( \
				../dtm/${feature}-${level}-${SIZE}-diff.png \
				-channel rgba \
				-fill 'rgba(255,0,0,0.25)' \
				-opaque red \
				-transparent black \
				-resize ${DIM}x${DIM} \
			\) \
			-composite \
			-set label "${feature^} ${level}" \
			${feature}-${level}-${SIZE}-diff.png
	done
done
montage -geometry "+4+3" \
	-tile 4x \
	-pointsize 48 -label '%c' \
	cracks-None-${SIZE}.png cracks-{Few,Default,Many}-${SIZE}-diff.png \
	rivers-None-${SIZE}.png rivers-{Few,Default,Many}-${SIZE}-diff.png \
	craters-None-${SIZE}.png craters-{Few,Default,Many}-${SIZE}-diff.png \
	lakes-None-${SIZE}.png lakes-{Few,Default,Many}-${SIZE}-diff.png \
	features-diff.png

[[ -f "${THUMBS}/features.png" ]] && echo "${THUMBS}/features.png"
[[ -f "${THUMBS}/features-diff.png" ]] && echo "${THUMBS}/features-diff.png"
[[ -f "${THUMBS}/terrain.png" ]] && echo "${THUMBS}/terrain.png"

