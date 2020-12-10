#SingleInstance Force
SetWorkingDir %A_ScriptDir%
;if not A_IsAdmin
;    Run *RunAs "%A_ScriptFullPath%"

#Include %A_ScriptDir%
#Include stdio.ahk

/*
* Defined Co-ordinates
*
*/

Coordmode, Mouse, Screen

; Quit

; Ravenhearst 6.2
quitX := 581
quitY := 1225

; Alpha 18.3
quitX := 1160
quitY := 1326

if WinExist("7 Days to die")
{
    Stdout("Activating 7 Days to die")
    WinActivate, 7 Days to die
}
else if WinExist("7 Days to Die")
{
    Stdout("Activating 7 Days to Die")
    WinActivate, 7 Days to Die
}
else if WinExist("7 Days To Die")
{
    Stdout("Activating 7 Days To Die")
    WinActivate, 7 Days To Die
}
else
{
    Stdout("Could not find 7 days to die application to close it.")
    Exit, 1
}

Sleep, 5000

MouseClick, Left, quitX, quitY ; Click on screen to ensure it's active

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
