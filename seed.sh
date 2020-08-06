#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

declare -g SEED_DICTIONARY_FOLDER SEED_FIRST_WORD_FILE SEED_SECOND_WORD_FILE

: "${SEED_DICTIONARY_FOLDER:=${BIN}/dictionary}"
: "${SEED_FIRST_WORD_FILE:=adjectives/28K adjectives.txt}"
: "${SEED_SECOND_WORD_FILE:=nouns/91K nouns.txt}"

randomize() {
	FILE="${SEED_DICTIONARY_FOLDER}/$1"
	SIZE=$(wc -l "${FILE}" | cut -d ' ' -f 1)
	WORD_NUM=$((RANDOM % SIZE + 1))
	tail -n "+${WORD_NUM}" "${FILE}" | head -1 | tr -d $'\r' ||
		if [[ $? -eq 141 ]]; then true; else exit $?; fi
}

FIRST_WORD=$(randomize "${SEED_FIRST_WORD_FILE}")
SECOND_WORD=$(randomize "${SEED_SECOND_WORD_FILE}")

echo "${FIRST_WORD^}${SECOND_WORD^}"

