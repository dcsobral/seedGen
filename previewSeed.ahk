/*
 *
 * Ravenhearst RWG Script
 * - by HarveyUK for dancapo
 * - 2019/12/20
 * (adapted)
*/

#SingleInstance Force
SetWorkingDir %A_ScriptDir%
;if not A_IsAdmin
;    Run *RunAs "%A_ScriptFullPath%"

; Command line args
RWGSize := A_Args[1]
RWGSeed := A_Args[2]

/*
* Defined Co-ordinates
*
*/

Coordmode, Mouse, Screen

; World Seed Box

worldSeedX := 874
worldSeedY := 341

; World Size Left Arrow

leftArrowX := 696
leftArrowY := 406

; World Size Right Arrow

rightArrowX := 1071
rightArrowY := 406

; World Generation Button

worldGenX := 885
worldGenY := 467

WinActivate, 7 Days To Die

Sleep, 500

Send, {F1}

Sleep, 500

Send, xui open rwgeditor

Sleep, 500

Send, {Return}

Sleep, 500

Send, {F1}

Sleep, 500

MouseClick, Left, worldSeedX, worldSeedY ; Location in the 7D2D Client where the World Seed Box is.

Sleep, 500

Send, %RWGSeed%

Sleep, 500

; Ravenhearst 6.2
;if RWGSize = 4096
;{
;	Move := -2
;}
;else if RWGSize = 6144
;{
;	Move := -1
;}
;else if RWGSize = 8192
;{
;	Move := 0
;}
;else if RWGSize = 10240
;{
;	Move := 1
;}
;else if RWGSize = 12288
;{
;	Move := 2
;}
;else if RWGSize = 14366
;{
;	Move := 3
;}
;else if RWGSize = 16384
;{
;	Move := 4
;}

; Alpha 18.3
if RWGSize = 4096
{
	Move := -1
}
else if RWGSize = 8192
{
	Move := 0
}

While Move != 0
{
	if Move < 0
	{
		MouseClick, Left, leftArrowX, leftArrowY ; Location of the left arrow of world size
		Move := Move + 1
	}
	else if Move > 0
	{
	MouseClick, Left, rightArrowX, rightArrowY ; Location of the right arrow of world size
		Move := Move - 1
	}
	Sleep, 250
}

MouseClick, Left, worldGenX, worldGenY ; Location of the Generate World Button

/* vim: set ts=4 sw=4 tw=100 et :*/
