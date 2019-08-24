#!/usr/bin/env bash

HERE=$(cd $(dirname $0) && pwd)
: ${ADJECTIVES:=${HERE}/adjectives/28K adjectives.txt}
: ${NOUNS:=${HERE}/nouns/91K nouns.txt}

ADJ_NUM=$(wc -l "${ADJECTIVES}" | cut -d ' ' -f 1)
NOUNS_NUM=$(wc -l "${NOUNS}" | cut -d ' ' -f 1)

randomize() {
	FILE="$1"
	SIZE="$2"
	WORD_NUM=$((RANDOM % SIZE + 1))
	tail -n "+${WORD_NUM}" "${FILE}" | head -1 | tr -d $'\r'
}

ADJECTIVE=$(randomize "${ADJECTIVES}" "${ADJ_NUM}")
NOUN=$(randomize "${NOUNS}" "${NOUNS_NUM}")

echo "${ADJECTIVE^}${NOUN^}"

