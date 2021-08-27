#!/usr/bin/env bash

_seedExtract() {
    COMPREPLY=($(compgen -f -X '!*.zip' | sed -nr '/-'"$2"'[0-9]+.zip/ s/.*-([0-9]+).zip/\1/p'))
}

_prefabRules() {
	if [[ -n $F7D2D ]]; then
		COMPREPLY=( $(xmlstarlet sel -t -m "//prefab_rule[starts-with(@name,'$2')][prefab[@name]]" -v @name -n "${F7D2D}/Data/Config/rwgmixer.xml") )
	else
		COMPREPLY=()
	fi
}

_prefabNames() {
	COMPREPLY=()
	if [[ -n $F7D2D ]]; then
		while IFS= read -r -d '' dir; do
			COMPREPLY+=( $(cd "${dir}" && compgen -f -- "$2" | sort -u | sed -e 's/\.[^ ]*//g') )
		done < <(find "${F7D2D}/Data/Prefabs" -type d -print0)
	fi
}

_special() {
	if [[ "${COMP_CWORD}" == "1" ]]; then
		BIN="$(cd "$(dirname "$(type -P special.sh)")" && pwd)"
		: "${SPECIAL_FOLDER:=${BIN}/special}"
		IFS=$'\n'
		COMPREPLY=( $(cd "${SPECIAL_FOLDER}" && compgen -f -X '.*' -P '-' -- "${2#-}") )
		IFS=$' \t\n'
	else
		_command "$@"
	fi
}

_prefab() {
	IFS=$'\n'
	COMPREPLY=( $(compgen -o dirnames -o filenames -f -X '!*.xml' -- "$2") )
	IFS=$' \t\n'
}

_image() {
	IFS=$'\n'
	COMPREPLY=( $(compgen -o dirnames -o filenames -f -X '!*.png' -- "$2") )
	IFS=$' \t\n'
}

_size() {
	nosuffix="${1%.*}"
	noprefix="${nosuffix##*-}"
	if [[ "$noprefix" =~ [0-9]+ ]]; then
		COMPREPLY=( "$noprefix" )
	else
		COMPREPLY=( 4096 6144 8192 10240 )
	fi
}

_prefabThenSpecial() {
	if [[ "${COMP_CWORD}" == "1" ]]; then
		_prefab "$@"
	elif [[ "${COMP_CWORD}" == "2" ]]; then
		BIN="$(cd "$(dirname "$(type -P special.sh)")" && pwd)"
		: "${SPECIAL_FOLDER:=${BIN}/special}"
		IFS=$'\n'
		COMPREPLY=( $(cd "${SPECIAL_FOLDER}" && compgen -f -X '.*' -- "$2") )
		IFS=$' \t\n'
	fi
}

_imageThenSize() {
	local nosuffix noprefix
	if [[ "${COMP_CWORD}" == "1" ]]; then
		_image "$@"
	elif [[ "${COMP_CWORD}" == "2" ]]; then
		_size "${COMP_WORDS[1]}"
	fi
}

_seedName() {
	COMPREPLY=( $(compgen -f -- "$2" | sed -e 's/\.[^ ]*//g') )
	if [[ -d "$F7D2D/previews" ]]; then
		COMPREPLY+=( $(cd "$F7D2D/previews" && compgen -f -- "$2" | sed -e 's/\.[^ ]*//g') )
	fi
}

complete -F _seedExtract prefabs.sh
complete -F _prefabRules sortByRule.sh
complete -F _prefabNames -o filenames rulesWith.sh
complete -F _prefabNames -o filenames zoning.sh
complete -F _prefabNames -o filenames prefabSize.sh
complete -F _prefabNames -o filenames showPrefab.sh
complete -o dirnames -o filenames -f -X '!*.xml' uniquePrefabs.sh
complete -o dirnames -o filenames -f -X '!*.zip' uz.sh
complete -o dirnames -o filenames -f -X '!*.xml' prefabRules.sh
complete -o dirnames -o filenames -f -X '!*.xml' rate.py
complete -F _prefabThenSpecial missingPrefabs.sh
complete -F _prefabThenSpecial listSpecials.sh
complete -F _imageThenSize drawRate.sh
complete -F _command greatest.sh
complete -F _command tops.sh
complete -F _special special.sh
complete -F _seedName showSeed.sh
complete -F _seedName showBiomeDistribution.sh
complete -F _seedName showZoningDistribution.sh

