#!/usr/bin/env bash

if [[ $# -lt 1 ]]; then
	echo >&2 "$0 {map.zip}"
	exit 1
fi

for file; do
	unzip "$file" -d "${file%-*.zip}"
done

