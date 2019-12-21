#SingleInstance Force
SetWorkingDir %A_ScriptDir%
;if not A_IsAdmin
;    Run *RunAs "%A_ScriptFullPath%"

/*
* Defined Co-ordinates
*
*/

Coordmode, Mouse, Screen

; Quit

quitX := 581
quitY := 1225

WinActivate, 7 Days To Die

Sleep, 500

Send, {F1}

Sleep, 500

Send, xui open mainMenu

Sleep, 500

Send, {Return}

Sleep, 500

Send, {F1}

Sleep, 500

MouseClick, Left, quitX, quitY ; Quit button

Sleep, 500

/* vim: set ts=4 sw=4 tw=100 et :*/
