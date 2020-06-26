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
	if [[ -n $F7D2D ]]; then
		COMPREPLY=( $(xmlstarlet sel -t -m "//prefab_rule/prefab[starts-with(@name,'$2')]" -v @name -n "${F7D2D}/Data/Config/rwgmixer.xml" | sort -u) )
	else
		COMPREPLY=()
	fi
}

complete -F _seedExtract prefabs.sh
complete -F _prefabRules sortByRule.sh
complete -F _prefabNames -o filenames rulesWith.sh
complete -F _prefabNames -o filenames zoning.sh
complete -F _prefabNames -o filenames prefabSize.sh
complete -o dirnames -o filenames -f -X '!*.xml' uniquePrefabs.sh
complete -o dirnames -o filenames -f -X '!*.zip' uz.sh
complete -o dirnames -o filenames -f -X '!*.xml' prefabRules.sh
complete -o dirnames -o filenames -f -X '!*.xml' missingPrefabs.sh
complete -o dirnames -o filenames -f -X '!*.xml' specialPrefabs.sh
complete -F _command tops.sh
