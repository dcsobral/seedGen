/*
 *
 * Random Gen RWG Script
 * - by dcsobral (originally written by HarveyUK 2019/12/20)
*/

#SingleInstance Force
SetWorkingDir %A_ScriptDir%
;if not A_IsAdmin
;    Run *RunAs "%A_ScriptFullPath%"
#Include %A_ScriptDir%
#Include stdio.ahk

; Command line args
RWGSize := A_Args[1]
RWGSeed := A_Args[2]
RWGTowns := A_Args[3]
RWGRivers := A_Args[4]
RWGCraters := A_Args[5]
RWGCracks := A_Args[6]
RWGLakes := A_Args[7]
RWGPlains := A_Args[8]
RWGHills := A_Args[9]
RWGMountains := A_Args[10]
RWGRandom := A_Args[11]

/*
* Defined Co-ordinates
*
*/

Coordmode, Mouse, Screen

; World Seed Box

worldSeedX := 874
worldSeedY := 341

; Arrows horizontal location
leftArrowX := 696
rightArrowX := 1071

; World Size vertical arrows

sizeArrowY := 406

; Towns vertical arrows

townsArrowY := 516

; Rivers vertical arrows

riversArrowY := 566

; Craters vertical arrows

cratersArrowY := 626

; Cracks vertical arrows

cracksArrowY := 676

; Lakes vertical arrows

lakesArrowY := 736

; Plains Weight vertical arrows

plainsArrowY := 796

; Hills Weight vertical arrows

hillsArrowY := 846

; Mountains Weight vertical arrows

mountainsArrowY := 906

; Random Weight vertical arrows

randomArrowY := 956

; World Generation Button

worldGenX := 900
worldGenY := 1000

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

Stdout("Seed: " . RWGSeed)
MouseClick, Left, worldSeedX, worldSeedY ; Location in the 7D2D Client where the World Seed Box is.

Sleep, 500

Send, %RWGSeed%

Sleep, 500

move := 10 ; Default to avoid errors
if RWGSize = 6144
{
    move := -1
}
else if RWGSize = 8192
{
    move := 0
}
else if RWGSize = 10240
{
    move := 1
}
else if RWGSize = Default
{
    move := 0
}

changeOption("World Size", RWGSize, move, leftArrowX, rightArrowX, sizeArrowY)

move := 10 ; Default to avoid errors
if RWGTowns = No
{
    move := -1
}
else if RWGTowns = Yes
{
    move := 0
}
else if RWGTowns = Default
{
    move := 0
}
changeOption("Gen Towns", RWGTowns, move, leftArrowX, rightArrowX, townsArrowY)

changeNoneToManyOption("Rivers", RWGRivers, leftArrowX, rightArrowX, riversArrowY)
changeNoneToManyOption("Craters", RWGCraters, leftArrowX, rightArrowX, cratersArrowY)
changeNoneToManyOption("Cracks", RWGCracks, leftArrowX, rightArrowX, cracksArrowY)
changeNoneToManyOption("Lakes", RWGLakes, leftArrowX, rightArrowX, lakesArrowY)

changeZeroToTenOption("Plains Weight", RWGPlains, leftArrowX, rightArrowX, plainsArrowY)
changeZeroToTenOption("Hills Weight", RWGHills, leftArrowX, rightArrowX, hillsArrowY)
changeZeroToTenOption("Mountains Weight", RWGMountains, leftArrowX, rightArrowX, mountainsArrowY)
changeZeroToTenOption("Random Weight", RWGRandom, leftArrowX, rightArrowX, randomArrowY)

; Start generation
Stdout("Generate World")
MouseClick, Left, worldGenX, worldGenY ; Location of the Generate World Button

changeZeroToTenOption(name, value, leftArrowX, rightArrowX, arrowY)
{
    if value = Default
    {
        move := 0
    }
    else
    {
        move := value - 5
    }

    changeOption(name, value, move, leftArrowX, rightArrowX, arrowY)
}

changeNoneToManyOption(name, value, leftArrowX, rightArrowX, arrowY)
{
    ; Default value to avoid errors
    move := 10

    if value = None
    {
        move := -2
    }
    else if value = Few
    {
        move := -1
    }
    else if value = Default
    {
        move := 0
    }
    else if value = Many
    {
        move := 1
    }
    else
    {
        Stdout("Unknown option '" . value . "' for " . name)
        return
    }

    changeOption(name, value, move, leftArrowX, rightArrowX, arrowY)
}

changeOption(name, value, move, leftArrowX, rightArrowX, arrowY)
{
    Stdout(name . ": " . value . " (" . move . ")")
    While move != 0
    {
        if move < 0
        {
            MouseClick, Left, leftArrowX, arrowY
            move := move + 1
        }
        else if move > 0
        {
        MouseClick, Left, rightArrowX, arrowY
            move := move - 1
        }
        Sleep, 250
    }
}

/* vim: set ts=4 sw=4 tw=100 et :*/
