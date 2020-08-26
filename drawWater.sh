#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'


if [[ $# -ne 3 ]]; then
        echo >&2 "$0 <water_info.xml> <image> <size>"
        exit 1
fi

XML="$1"
IMG="$2"
SIZE="$3"
DIM="${SIZE}x${SIZE}"
CENTER="$((SIZE / 2))"
WATER_IMG="water-${IMG}"
MASK_IMG="mask-${IMG}"
TMPIMG="tmp-${IMG}"

water() {
	# no argument expansion is intended with $c
	# shellcheck disable=SC2016
	xmlstarlet sel -t -m "//Water" --sort a:n:- "str:tokenize(@pos, ',')[2]" \
		--var "c=str:tokenize(@pos, ',')" \
		-v '$c[2]' -o ';' \
		-v '$c[1]' -o , -v '$c[3]' -o ';' \
		-v @minx -o , -v @maxx -o , -v @minz -o , -v @maxz \
		-n "${XML}" | tr -d ' '
}

water > water_info.txt

mapfile -t DEPTHS < <(cut -d ';' -f 1 water_info.txt | sort -u)
convert -size "${DIM}" xc:black -alpha on -transparent black "${MASK_IMG}"
for depth in "${DEPTHS[@]}"; do
	echo "Depth $depth"
	file="water${depth}.txt"
	threshold=$((depth * 256 + 128))
	grep "^${depth};" water_info.txt > water_depth.txt

	mapfile -t MASKS < <(cut -d ';' -f 3 water_depth.txt | sort -u)

	echo "push defs" > "${file}"
	for mask in "${MASKS[@]}"; do
		echo "Clip path mask $mask"
		IFS=',' read -r x1 x2 z1 z2 <<<"$mask"
		xmin=$((CENTER + x1))
		xmax=$((CENTER + x2 - 1))
		zmin=$((CENTER - z2))
		zmax=$((CENTER - z1 - 1))
		#clip_path="${xmin}_${zmin}_${xmax}_${zmax}"
		clip_path="$mask"
		cat >> "${file}" <<-CLIPMASK
			push clip-path "${clip_path}"
				push graphic-context
					rectangle ${xmin},${zmin} ${xmax},${zmax}
				pop graphic-context
			pop clip-path
		CLIPMASK
	done
	# shellcheck disable=SC2129
	echo "pop defs" >> "${file}"

	echo "fill white" >> "${file}"
	echo "border-color white" >> "${file}"
	for mask in "${MASKS[@]}"; do
		echo "Filling Mask $mask"
		clip_path="$mask"

		mapfile -t POINTS < <(grep ";${mask}$" water_depth.txt | cut -d ';' -f 2)
		echo "push graphic-context" >> "${file}"
		echo "clip-path url(#${clip_path})" >> "${file}"
		for point in "${POINTS[@]}"; do
			IFS=',' read -r x z <<<"$point"
			xabs=$((CENTER + x))
			zabs=$((CENTER - z))
			echo "color ${xabs},${zabs} filltoborder" >> "${file}"
		done
		echo "pop graphic-context" >> "${file}"
	done
	time convert -size "${DIM}" -depth 16 gray:dtm.raw -flip \
		-threshold "$threshold" \
		-depth 8 \
		-write mpr:mask \
		-monitor -draw "@${file}" \
		mpr:mask -compose minus_src -composite \
		-alpha on -transparent black \
		"${MASK_IMG}" -compose src-over -composite \
		"${TMPIMG}"
	mv -f "${TMPIMG}" "${MASK_IMG}"
done

convert "${IMG}" \
	\( "${MASK_IMG}" -fill '#738cce' -opaque white \) \
	-composite "${WATER_IMG}"

echo "${WATER_IMG}"

