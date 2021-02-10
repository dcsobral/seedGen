#!/usr/bin/env bash

OUT="$PWD/legend.png"

montage -title 'Map Preview Legend' -pointsize 16 \
	-label Trader xc:magenta \
	-label Crop xc:olive \
	-label Any xc:white \
	-label Wilderness xc:saddlebrown \
	-label D/C/I xc:orange \
	-label D/R xc:teal \
	-label D/C xc:slategray \
	-label Downtown xc:gray \
	-label "Residential Old" xc:green \
	-label "Residential New" xc:chartreuse \
	-label Commercial xc:blue \
	-label Industrial xc:yellow \
	-label "Spawn Location" xc:red \
	-label Wasteland 'xc:#949442' \
	-label 'Burnt Forest' 'xc:#393931' \
	-label Forest 'xc:#004000' \
	-label Desert 'xc:#FFE477' \
	-label Snow 'xc:#c3c4d9' \
	-label Water 'xc:#738cce' \
	-label 'Asphalt Road' 'xc:#ceb584' \
	-label 'Gravel Road' 'xc:#9c8c7b' \
	-label Radiation 'xc:rgb(255,0,0)' \
	-shadow -geometry 128x128+5+5 \
	"${OUT}"

echo "${OUT}"

