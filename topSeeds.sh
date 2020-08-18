#!/usr/bin/env bash

grep -Eo '  1 +[0-9]+ +\S+' | grep -Eo '[[:alpha:]]\S+'

