#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

: "${F7D2D:?Please export F7D2D with 7D2D install folder}"

usage() {
        cat >&2 <<-USAGE
                $0 [options] [<size> [<seed>]]

		Defaults to all features and topologies with size 6144 and random seed.

		Options:
		  --features    Generate variations of all six features below
		  --towns
		  --wilderness
		  --rivers
		  --craters
		  --cracks
		  --lakes
		  --terrain     Generate variations of all four topologies below
		  --plains
		  --hills
		  --mountains
		  --random
	USAGE
	exit 1
}

if [[ $# == 0 || $1 != -* ]]; then
	set -- --features --terrain "$@"
fi

declare -a FEATURES=( )
declare -a TERRAIN=( )
# TODO: towns and wilderness as a different category than features
# TODO: compare terrain and features without prefabs
# TODO: accept "reference" options to select the default to compare against
# TODO: accept options to change the "default" settings
while [[ $# -gt 0 && $1 == -* ]]; do
	case "$1" in
	--towns | --wilderness | --rivers | --craters | --cracks | --lakes)
		FEATURES=( "${FEATURES[@]}" "${1:2}" )
		;;
	--plains | --hills | --mountains | --random)
		TERRAIN=( "${TERRAIN[@]}" "${1:2}" )
		;;
	--features)
		FEATURES=( towns wilderness rivers craters cracks lakes )
		;;
	--terrain)
		TERRAIN=( plains hills mountains random )
		;;
	*)
		usage
		;;
	esac
	shift
done

if [[ $# -gt 2 ]]; then
	usage
fi

SIZE="${1:-6144}"
SEED="${2:-$(seed.sh)}"

echo "Generating samples of seed ${SEED} size ${SIZE}"

OUTDIR="${F7D2D}/sample/${SEED}"
THUMBS="${OUTDIR}/thumbs"
DTM="${OUTDIR}/dtm"

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
		[[ -f stop ]] && break
		NAME="${OPT_NAME}-${opt}"

		if [[ -f "${OUTDIR}/${NAME}.zip" ]]; then
			echo >&2 "Skipping ${NAME}"
			continue
		fi

		rm -fr "${F7D2D}/UserData"
		SECONDS=0
		startClient.sh "--${OPT_NAME}" "${opt}" --wilderness None "${SIZE}" "${SEED}"
		timeIt

		# shellcheck disable=SC2012
		COUNTY=$( ls -1rt "${F7D2D}/UserData/GeneratedWorlds/" | tail -1 )
		WORLD="${F7D2D}/UserData/GeneratedWorlds/${COUNTY}"
		savePreview.sh --world "${WORLD}" --name "${NAME}" --output "${OUTDIR}/${NAME}.zip" \
			--options "--${OPT_NAME}" "${opt}" --endoptions "${SIZE}" "${NAME}"

		TASK_LIST="$(tasklist.exe)"
		if grep -q ^7DaysToDie.exe <<<"${TASK_LIST}"; then
			taskkill.exe /IM "7DaysToDie.exe" /F /T
		fi
	done
}

NAME="Default"
if [[ -f "${OUTDIR}/${NAME}.zip" ]]; then
	echo >&2 "Skipping ${NAME}"
else
	rm -fr "${F7D2D}/UserData"
	SECONDS=0
	startClient.sh --wilderness None "${SIZE}" "${SEED}"
	timeIt

	# shellcheck disable=SC2012
	COUNTY=$( ls -1rt "${F7D2D}/UserData/GeneratedWorlds/" | tail -1 )
	WORLD="${F7D2D}/UserData/GeneratedWorlds/${COUNTY}"
	savePreview.sh --world "${WORLD}" --name "${NAME}" --output "${OUTDIR}/${NAME}.zip" \
		"${SIZE}" "${NAME}"

	TASK_LIST="$(tasklist.exe)"
	if grep -q ^7DaysToDie.exe <<<"${TASK_LIST}"; then
		taskkill.exe /IM "7DaysToDie.exe" /F /T
	fi
fi

if [[ ${#FEATURES[@]} -gt 0 ]]; then
	echo "Generating features ${FEATURES[*]}"
	for feature in "${FEATURES[@]}"; do
		[[ -f stop ]] && break
		if [[ "$feature" == towns ]]; then
			genOpt "${feature}" Few Many
		else
			genOpt "${feature}" None Few Many
		fi
	done
fi

if [[ ${#TERRAIN[@]} -gt 0 ]]; then
	echo "Generating topologies ${TERRAIN[*]}"
	declare -a SEQ
	SEQ=( $( seq 0 10 ) )
	for topology in "${TERRAIN[@]}"; do
		[[ -f stop ]] && break
		genOpt "${topology}" "${SEQ[@]}"
	done
fi

if [[ ${#FEATURES[@]} -gt 0 && ! -f stop ]]; then
	cd "${OUTDIR}"
	find . -name '*.zip' -print0 | xargs -0 -x -n1 -i unzip -u {} 'thumbs/*'

	cd "${THUMBS}"
	declare -a FILES=( -label Default "Default-${SIZE}.png" -label '%c' null: null: )
	for feature in "${FEATURES[@]}"; do
		if [[ "$feature" == towns ]]; then
			FILES=( "${FILES[@]}" null: "${feature}-"{Few,Many}"-${SIZE}.png" )
		else
			FILES=( "${FILES[@]}" "${feature}-"{None,Few,Many}"-${SIZE}.png" )
		fi
	done
	montage -geometry "+4+3" \
		-tile 3x \
		-pointsize 48 \
		"${FILES[@]}" \
		features.png

	cd "${OUTDIR}"
	find . -name '*.zip' -print0 | xargs -0 -x -n1 -i unzip -d dtm -u {} '*-dtm.png'

	cd "${DTM}"
	for feature in "${FEATURES[@]}"; do
		for level in None Few Many; do
			[[ -f "${feature}-${level}-${SIZE}-diff.png" ]] && continue
			[[ -f "${feature}-${level}-${SIZE}-dtm.png" ]] || continue
			compare \
				-highlight-color red \
				-lowlight-color black \
				-set label $level \
				"Default-${SIZE}-dtm.png" \
				"${feature}-${level}-${SIZE}-dtm.png" \
				"${feature}-${level}-${SIZE}-diff.png" \
				|| :  # Do not fail if images are different
		done
	done

	cd "${THUMBS}"
	DIM=$((SIZE / 16))
	for feature in "${FEATURES[@]}"; do
		for level in None Few Many; do
			[[ -f "${feature}-${level}-${SIZE}-diff.png" ]] && continue
			[[ -f "${feature}-${level}-${SIZE}.png" ]] || continue
			convert \
				"${feature}-${level}-${SIZE}.png" \
				\( \
					"../dtm/${feature}-${level}-${SIZE}-diff.png" \
					-channel rgba \
					-fill 'rgba(255,0,0,0.25)' \
					-opaque red \
					-transparent black \
					-resize ${DIM}x${DIM} \
				\) \
				-composite \
				-set label "${feature^} ${level}" \
				"${feature}-${level}-${SIZE}-diff.png"
		done
	done

	FILES=( -label Default "Default-${SIZE}.png" -label '%c' null: null: )
	for feature in "${FEATURES[@]}"; do
		if [[ "$feature" == towns ]]; then
			FILES=( "${FILES[@]}" null: "${feature}-"{Few,Many}"-${SIZE}-diff.png" )
		else
			FILES=( "${FILES[@]}" "${feature}-"{None,Few,Many}"-${SIZE}-diff.png" )
		fi
	done
	montage -geometry "+4+3" \
		-tile 3x \
		-pointsize 48 \
		"${FILES[@]}" \
		features-diff.png

fi

if [[ ${#TERRAIN[@]} -gt 0 && ! -f stop ]]; then
	cd "${OUTDIR}"
	find . -name '*.zip' -print0 | xargs -0 -x -n1 -i unzip -u {} 'thumbs/*'
	cd "${THUMBS}"
	declare -a FILES=( )
	FILES=( )
	for topology in "${TERRAIN[@]}"; do
		FILES=( "${FILES[@]}" "${topology}-"[0-9]"-${SIZE}.png" "${topology}-10-${SIZE}.png" )
	done
	montage -geometry "+4+3" \
		-tile 11x \
		-pointsize 48 -label '%c' \
		"${FILES[@]}" \
		terrain.png
fi

[[ -f stop ]] && rm -f stop

[[ -f "${THUMBS}/features.png" ]] && echo "${THUMBS}/features.png"
[[ -f "${THUMBS}/features-diff.png" ]] && echo "${THUMBS}/features-diff.png"
[[ -f "${THUMBS}/terrain.png" ]] && echo "${THUMBS}/terrain.png"

