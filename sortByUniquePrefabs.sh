#!/usr/bin/env bash

BIN="$(cd "$(dirname "$0")" && pwd)"

list() {
	for file in *.xml; do
		echo -n "$file "
		xmlstarlet sel -t -m /prefabs -v "count(decoration[not(@name=preceding-sibling::*/@name)])" -n "$file"
	done
}

list | sort -k 2 -n

