_seedExtract() {
    COMPREPLY=($(compgen -f -X '!*.zip' | sed -nr '/-'"$2"'[0-9]+.zip/ s/.*-([0-9]+).zip/\1/p'))
}

_prefabGroups() {
	: "${F7D2D:=/mnt/c/Users/Daniel/Desktop/RH5.5Server}"

	COMPREPLY=( $(xmlstarlet sel -t -m "//prefab_rule[starts-with(@name,'$2')][prefab[@name]]" -v @name -n "${F7D2D}/Data/Config/rwgmixer.xml") )
}

complete -F _seedExtract extractPrefabs.sh
complete -F _prefabGroups sortByGroup.sh
complete -o dirnames -o filenames -f -X '!*.xml' uniquePrefabs.sh
complete -o dirnames -o filenames -f -X '!*.zip' extract.sh
complete -o dirnames -o filenames -f -X '!*.xml' prefabGroups.sh
complete -o dirnames -o filenames -f -X '!*.xml' missingPrefabs.sh
complete -o dirnames -o filenames -f -X '!*.xml' interestingPrefabs.sh
complete -o dirnames -o filenames -f -X '!*.tts' prefabSize.sh
