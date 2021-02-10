#!/usr/bin/env bash

OUT="$PWD/legendV.png"

montage -pointsize 48 -gravity west \
	-size 64x64 xc:magenta \( -size 512x64 xc:white -annotate 0x0+0+0 Trader \) \
	-size 64x64 xc:olive \( -size 512x64 xc:white -annotate 0x0+0+0 Crop \) \
	-size 64x64 xc:white \( -size 512x64 xc:white -annotate 0x0+0+0 Any \) \
	-size 64x64 xc:saddlebrown \( -size 512x64 xc:white -annotate 0x0+0+0 Wilderness \) \
	-size 64x64 xc:orange \( -size 512x64 xc:white -annotate 0x0+0+0 D/C/I \) \
	-size 64x64 xc:teal \( -size 512x64 xc:white -annotate 0x0+0+0 D/R \) \
	-size 64x64 xc:slategray \( -size 512x64 xc:white -annotate 0x0+0+0 D/C \) \
	-size 64x64 xc:gray \( -size 512x64 xc:white -annotate 0x0+0+0 Downtown \) \
	-size 64x64 xc:green \( -size 512x64 xc:white -annotate 0x0+0+0 "Residential Old" \) \
	-size 64x64 xc:chartreuse \( -size 512x64 xc:white -annotate 0x0+0+0 "Residential New" \) \
	-size 64x64 xc:blue \( -size 512x64 xc:white -annotate 0x0+0+0 Commercial \) \
	-size 64x64 xc:yellow \( -size 512x64 xc:white -annotate 0x0+0+0 Industrial \) \
	-size 64x64 xc:red \( -size 512x64 xc:white -annotate 0x0+0+0 "Spawn Location" \) \
	-size 64x64 'xc:#949442' \( -size 512x64 xc:white -annotate 0x0+0+0 Wasteland \) \
	-size 64x64 'xc:#393931' \( -size 512x64 xc:white -annotate 0x0+0+0 'Burnt Forest' \) \
	-size 64x64 'xc:#004000' \( -size 512x64 xc:white -annotate 0x0+0+0 Forest \) \
	-size 64x64 'xc:#FFE477' \( -size 512x64 xc:white -annotate 0x0+0+0 Desert \) \
	-size 64x64 'xc:#c3c4d9' \( -size 512x64 xc:white -annotate 0x0+0+0 Snow \) \
	-size 64x64 'xc:#738cce' \( -size 512x64 xc:white -annotate 0x0+0+0 Water \) \
	-size 64x64 'xc:#ceb584' \( -size 512x64 xc:white -annotate 0x0+0+0 'Asphalt Road' \) \
	-size 64x64 'xc:#9c8c7b' \( -size 512x64 xc:white -annotate 0x0+0+0 'Gravel Road' \) \
	-size 64x64 'xc:rgb(255,0,0)' \( -size 512x64 xc:white -annotate 0x0+0+0 Radiation \) \
	-geometry +5+5 \
	-tile 2x \
	"${OUT}"

echo "${OUT}"

