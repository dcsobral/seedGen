#!/usr/bin/env bash

# find is worse than ls in this particular case
# shellcheck disable=SC2012
ls -- *.xml | sed 's/-[0-9]*.xml//' | sort > prefabs.tmp
sortByPrefabs.sh | sed 's/^ *//;s/  */,/g;s/-[0-9]*//' | sort -t , -k 3 | cut -d , -f 2 > byPrefabs.tmp
sortByUniquePrefabs.sh | sed 's/^ *//;s/  */,/g;s/-[0-9]*//' | sort -t , -k 3 | cut -d , -f 2 > byUniquePrefabs.tmp
SPECIAL=tier4.txt sortBySpecialPrefabs.sh | sed 's/^ *//;s/  */,/g;s/-[0-9]*//' | sort -t , -k 3 | cut -d , -f 2 > tier4.tmp
SPECIAL=tier5.txt sortBySpecialPrefabs.sh | sed 's/^ *//;s/  */,/g;s/-[0-9]*//' | sort -t , -k 3 | cut -d , -f 2 > tier5.tmp
SPECIAL=top7.txt sortBySpecialPrefabs.sh | sed 's/^ *//;s/  */,/g;s/-[0-9]*//' | sort -t , -k 3 | cut -d , -f 2 > top7.tmp
SPECIAL=top15.txt sortBySpecialPrefabs.sh | sed 's/^ *//;s/  */,/g;s/-[0-9]*//' | sort -t , -k 3 | cut -d , -f 2 > top15.tmp
SPECIAL=stores.txt sortBySpecialPrefabs.sh | sed 's/^ *//;s/  */,/g;s/-[0-9]*//' | sort -t , -k 3 | cut -d , -f 2 > stores.tmp
SPECIAL=skyscrapers.txt sortBySpecialPrefabs.sh | sed 's/^ *//;s/  */,/g;s/-[0-9]*//' | sort -t , -k 3 | cut -d , -f 2 > skyscrapers.tmp
echo 'Seed,Prefabs,Unique Prefabs,Tier 4,Tier 5,Top 7,Top 15,Stores,Skyscrapers' > allSorts.csv
paste -d , prefabs.tmp byPrefabs.tmp byUniquePrefabs.tmp tier4.tmp tier5.tmp top7.tmp top15.tmp stores.tmp skyscrapers.tmp >> allSorts.csv
rm ./*.tmp
