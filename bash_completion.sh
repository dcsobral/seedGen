_seedExtract ()
{
    COMPREPLY=($(compgen -f -X '!*.zip' | sed -nr '/-'"$2"'[0-9]+.zip/ s/.*-([0-9]+).zip/\1/p'))
}
complete -o dirnames -o filenames -f -X '!*.xml' uniquePrefabs.sh
complete -F _seedExtract extractPrefabs.sh
complete -o dirnames -o filenames -f -X '!*.zip' extract.sh
complete -o dirnames -o filenames -f -X '!*.xml' prefabGroups.sh
complete -o dirnames -o filenames -f -X '!*.xml' missingPrefabs.sh
complete -o dirnames -o filenames -f -X '!*.xml' interestingPrefabsCount.sh
complete -o dirnames -o filenames -f -X '!*.tts' prefabSize.sh
