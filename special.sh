#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

BIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${SPECIAL_FOLDER:=${BIN}/special}"

if [[ $# -lt 2 || ! -f "${SPECIAL_FOLDER}/${1#-}" ]]; then
        echo >&2 "$0 -<special.txt> <cmd> [args]"
        exit 1
fi

export SPECIAL="${1#-}"
shift

exec "$@"

