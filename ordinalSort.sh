#!/usr/bin/env bash

sort -nr | awk '{if ($1 != prev) num=NR; printf "%3d %s\n", num, $0; prev=$1}' | tac

