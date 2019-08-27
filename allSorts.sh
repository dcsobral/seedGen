#!/usr/bin/env bash

paste <(sortByPrefabs.sh)  <(sortByInterestingPrefabs.sh) <(sortByTotalInterestingPrefabs.sh) <(sortByUniquePrefabs.sh)  | column -t

