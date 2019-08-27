#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

: "${F7D2D:=/mnt/c/Users/Daniel/Desktop/RH5.5Server}"

prefabRules() {
	xmlstarlet sel -t -m "//prefab_rule[prefab[@name]]" -v @name -n "${F7D2D}/Data/Config/rwgmixer.xml"
}

prefabs() {
	xmlstarlet sel -t -m "//prefab_rule[@name='$1']/prefab[@name]" -v @name -n "${F7D2D}/Data/Config/rwgmixer.xml"
}

declare -a RULES
declare -A DIM

if [[ $# -eq 0 ]]; then
	mapfile -t RULES < <(prefabRules)
else
	RULES=( "$@" )
fi

for rule in "${RULES[@]}"; do
	prefabs=( $(prefabs "$rule") )
	echo "$rule"
	for prefab in "${prefabs[@]}"; do
		if [[ -n ${DIM["$prefab"]+abc} ]]; then
			IFS=',' read x y z <<<"${DIM["$prefab"]}"
		else
			IFS=',' read x y z < <("${BIN}/prefabSize.sh" "${prefab}")
			DIM["$prefab"]="$x,$y,$z"
		fi
		area=$((x * z))
		printf "\t%d\t%s\t%s\n" $area "$x,$y,$z" "$prefab"
	done | sort -n
done

