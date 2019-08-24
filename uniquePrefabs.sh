#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
	echo "$0 <prefabs.xml>"
fi

xmlstarlet sel -t -m /prefabs -m "decoration[not(@name=preceding-sibling::*/@name)]" --sort a:t:- @name -v @name -n "$1"

