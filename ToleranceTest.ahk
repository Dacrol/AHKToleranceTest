#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force
SetTitleMatchMode, 1
DetectHiddenWindows, On
DetectHiddenText, On
CoordMode, ToolTip, Screen 
CoordMode, Mouse, Screen 
CoordMode, Pixel, Screen 
SendMode Input 	;Input|Play|Event|InputThenPlay 
				/*Event probably works best for game engines that detect mouse positions*/
SetWinDelay, 8 ;default 100

/*
This script tests and finds the necessary tolerance for searching an image/icon on the screen. Modify the ImageName, maximum tolerance to test, hotkey and SearchTerm to suit the testing.
------
Set image name and max tolerance here. Image should be in the same directory as the script. Maximum possible tolerance is 255 (0-255). Anything over 100 becomes very slow, modify the image instead and use black or white as transparency with the *TransBlack or *TransWhite flags in the search term (see further down).
*/
MinTol := 140
MaxTol := 154
ImageName = TestImage.png
/*
------
*/
/*
------
Uncomment this and change the window name to constrain the test to a specific application.
*/
;#IfWinActive, 7 Days To Die
/*
------
*/
/*
------
Specify the search area and transparency here: (Set start values to 0 and end values to 1 for whole screen)
*/
StartX := A_ScreenWidth * 0.44 ;669x (0.348438%) 191y (0.176852%)
StartY := A_ScreenHeight * 0.22
EndX := A_ScreenWidth * 0.58 ;1067x (0.555729%) 442y (0.409259%)
EndY := A_ScreenHeight * 0.52 
Trans := "0x606060" ;Color to consider transparent
;MsgBox, %StartX% %StartY% %EndX% %EndY%
/*
Defaults for searching the entire screen is: 
StartX := 0
StartY := 0
EndX := A_ScreenWidth
EndY := A_ScreenHeight
Trans := 0x000000
------
*/

SoundPlay, %A_WinDir%\Media\Speech On.wav ;Ready!

/*
------
Set your hotkey here: (!t = Alt+T, ^ for Ctrl, + for Shift, ^!+t = Ctrl+Alt+Shift+T)
*/
!t::

Tol := MinTol
ErrorLevel := -1
Abort := 0
SetTimer, RemoveProgress, Delete
Progress, Off
Progress,% "B R" . MinTol . "-" . MaxTol . " H125 W250 " . ("Y" . H := A_ScreenHeight*0.75),,Testing Tolerance: ,


while(Tol <= MaxTol && ErrorLevel != 0 && Abort == 0){
Progress, %Tol%, %Tol%  of  %MaxTol%...,,Testing Tolerance: ,
/*
------
Modify the searchterm here: (black is considered transparent with *TransBlack flag, can be replaced with any color by using *TransFFFFFF instead)
Do not modify if you want to use transparency value set above.
*/
SearchTerm := "*" . Tol . " *Trans" . Trans . " " . A_ScriptDir . "\" . ImageName
;SearchTerm := "*" . Tol . " " . A_ScriptDir . "\" . ImageName ;Optional with no transparency
/*
------
*/


ImageSearch, FoundX, FoundY, StartX, StartY, EndX, EndY, %SearchTerm% 
Tol++
}
Tol--
if(Abort != 0){
	ErrorLevel := 1
}
if(ErrorLevel == 0){
Progress, %MaxTol%, Image found at %FoundX%x %FoundY%y and Tolerance = %Tol%  of  %MaxTol% :),,, 

Offset := 16
FoundX := FoundX + Offset
FoundY := FoundY + Offset
;MouseMove, FoundX, FoundY

;SetMouseDelay, 10 ;default 10
;SetDefaultMouseSpeed, 2 ;default 2

MouseGetPos, LocX, LocY
;SendInput {Click, %FoundX%, %FoundY%}
;SendEvent {Click, %FoundX%, %FoundY%} ;If you want to see the mouse move with SetMouseDelay
;SendPlay {Click, %FoundX%, %FoundY%} ;Doesn't seem to work
;Click, %FoundX%, %FoundY%
MouseClick, Left, %FoundX%, %FoundY%, 1, 1 ;This seems superior
Sleep, 18 ;Increase this if it doesn't work properly at lower FPS
MouseMove, %LocX%, %LocY%, 1 ;Move back


SoundPlay, %A_WinDir%\Media\tada.wav
;MsgBox, "Clicked on %FoundX%x %FoundY%y.`nTolerance = " . Tol.
}
else if(ErrorLevel == 1){
Progress, %Tol%, Image was not recognized at any tolerance :(`nTested %Tol%  of  %MaxTol%,,,
}
else if(ErrorLevel == 2){
MsgBox, Unable to search. Wrong filename?
}

SetTimer, RemoveProgress, -7500
return

RemoveToolTip:
ToolTip
return

RemoveProgress:
Progress, Off
return


/*
Abort with escape:
*/
~Esc::
Abort = 1
Send, {Esc}
return
/*
Terminate script with Alt+E
*/
!e::ExitApp

/*
Reload with Alt+R
*/
!r::
SoundPlay, %A_WinDir%\Media\Speech Off.wav, 1
;SoundPlay, %A_WinDir%\Media\Speech On.wav, 1
Progress, Off
Reload
return

/*
Test Colors at the mouse with Alt+C
*/
!c::
color := 0
MouseX := 0
MouseY := 0
MouseGetPos, MouseX, MouseY
PixelGetColor, color, %MouseX%, %MouseY%, Slow RGB
MsgBox, 4,,The color at the current cursor position is %color%. Copy to clipboard?
IfMsgBox Yes
	StringTrimLeft, color, color, 2
	clipboard = %color%
return
return

/*
Get current mouse position with Alt+P
*/
!p::
MouseX := 0
MouseY := 0
MouseGetPos, MouseX, MouseY
PercX := MouseX/A_ScreenWidth
PercY := MouseY/A_ScreenHeight
Msgbox, 4,,The cursor is at %MouseX%x (%PercX%`%) %MouseY%y (%PercY%`%). Copy to clipboard?
IfMsgBox Yes
	clipboard = %MouseX%x (%PercX%`%) %MouseY%y (%PercY%`%)
return
