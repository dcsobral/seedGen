#!/usr/bin/env bash

ls *.xml | sed 's/-[0-9]*.xml//' | sort > prefabs.tmp
sortByPrefabs.sh | sed 's/^ *//;s/ /,/;s/-[0-9]*//' | sort -t , -k 2 | sed 's/,.*//' > byPrefabs.tmp
sortByUniquePrefabs.sh | sed 's/^ *//;s/ /,/;s/-[0-9]*//' | sort -t , -k 2 | sed 's/,.*//' > byUniquePrefabs.tmp
SPECIAL=tier4.txt sortBySpecialPrefabs.sh | sed 's/^ *//;s/ /,/;s/-[0-9]*//' | sort -t , -k 2 | sed 's/,.*//' > tier4.tmp
SPECIAL=tier5.txt sortBySpecialPrefabs.sh | sed 's/^ *//;s/ /,/;s/-[0-9]*//' | sort -t , -k 2 | sed 's/,.*//' > tier5.tmp
SPECIAL=top7.txt sortBySpecialPrefabs.sh | sed 's/^ *//;s/ /,/;s/-[0-9]*//' | sort -t , -k 2 | sed 's/,.*//' > top7.tmp
SPECIAL=top15.txt sortBySpecialPrefabs.sh | sed 's/^ *//;s/ /,/;s/-[0-9]*//' | sort -t , -k 2 | sed 's/,.*//' > top15.tmp
SPECIAL=stores.txt sortBySpecialPrefabs.sh | sed 's/^ *//;s/ /,/;s/-[0-9]*//' | sort -t , -k 2 | sed 's/,.*//' > stores.tmp
SPECIAL=skyscrapers.txt sortBySpecialPrefabs.sh | sed 's/^ *//;s/ /,/;s/-[0-9]*//' | sort -t , -k 2 | sed 's/,.*//' > skyscrapers.tmp
echo 'Seed,Prefabs,Unique Prefabs,Tier 4,Tier 5,Top 7,Top 15,Stores,Skyscrapers' > allSorts.csv
paste -d , prefabs.tmp byPrefabs.tmp byUniquePrefabs.tmp tier4.tmp tier5.tmp top7.tmp top15.tmp stores.tmp skyscrapers.tmp >> allSorts.csv
rm *.tmp
