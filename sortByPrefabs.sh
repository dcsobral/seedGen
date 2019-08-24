#!/usr/bin/env bash

grep -c decoration *.xml | tr : ' ' | sort -k 2 -n
