/*
original version:
 https://autohotkey.com/board/topic/54972-sweet-dreams-music-fade-out/
 AutoHotkey Version: 1.x
 Language:       English
 Platform:       Tested on Windows 7 x64
 Author:         <see orig. forum post>
 
 Original forum post:
 https://autohotkey.com/board/topic/54972-sweet-dreams-music-fade-out/

 Script Function (original version):
   Waits a specified amount of time, then takes a specified amount of time to reduce the windows
   sound volume to 0. After that, it pauses iTunes and/or Spotify, resets the volume to 100,
   then either exits or shuts the computer down.

===

 SweetDreamsAHK_mod by nofish
 changes to original version:
 
 v1.0:
 - stores previous wait and fade time values in .ini file (in same folder as the comiled .exe), 
    recalled when script is started again
 - starts fading from current volume and restores to original volume (not 100% as in original version)
 - screen is turned off (periodically every minute if idle) 
 
 v1.0.1
 # renamed .exe to SeetDreamsAHK_mod (no version nr.)
 # version nr. now displayed in title
 # clicking Cancel = exit
 
 */
 

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

NAME = SweetDreamsAHK_
VERSION = 1.0
BOXTITLE = %NAME%%VERSION%


; read previous values from .ini file
IniRead readInitialTimeMin, SweetDreamsAHK.ini, variables, storedInitialTimeMin, 25 ; 25 = default value when reading failed
IniRead readReduceTimeMin, SweetDreamsAHK.ini, variables, storedReduceTimeMin, 10

; en-/disable debug msg's
_DEBUG_ := False   ; True|False


If (_DEBUG_) {
MsgBox, The value is %readInitialTimeMin%.
MsgBox, The value is %readReduceTimeMin%.
}


InputBox, initalTimeMin, %BOXTITLE%, Time to wait before decreasing volume (minutes):, , , , , , , , %readInitialTimeMin%
if ErrorLevel
 ExitApp

InputBox, reduceTimeMin, %BOXTITLE%, Time to decrease volume over (minutes):, , , , , , , , %readReduceTimeMin%
if ErrorLevel
 ExitApp

MsgBox, 4, %BOXTITLE%, Shut down afterwards?
IfMsgBox Yes 
{
   shutdown := "true"
}
else 
{
   shutdown := "false"
}

; store values to ini file
IniWrite %initalTimeMin%, SweetDreamsAHK.ini, variables, storedInitialTimeMin
IniWrite %reduceTimeMin%, SweetDreamsAHK.ini, variables, storedReduceTimeMin

; read current master volume
SoundGet, currentMasterVolume
If (_DEBUG_) {
MsgBox, Master volume is %master_volume% percent.
}

sleep 5000
SendMessage,0x112,0xF170,2,,Program Manager ; turn off monitor

; calculations
initalTimeMillisec := initalTimeMin * 60 * 1000
reduceTimeMillisec := reduceTimeMin * 60 * 1000
stepsPerMin := currentMasterVolume / reduceTimeMin
If (_DEBUG_) {
MsgBox, stepsPerMin: %stepsPerMin%.
}
oneStepDurationSec := 60 / stepsPerMin * 2 ; two steps at once, hence factor 2
oneStepDurationMillisec := oneStepDurationSec * 1000
If (_DEBUG_) {
MsgBox, oneStepDurationSec %oneStepDurationSec%.
}
numberOfSteps := Round(stepsPerMin * reduceTimeMin / 2)
If (_DEBUG_) {
MsgBox, numberOfSteps %numberOfSteps%.
}


; sleep loop
Loop %initalTimeMin%
{
  ; turn monitor off again after key input
  if (A_TimeIdlePhysical >= 5000) {
    SendMessage,0x112,0xF170,2,,Program Manager ; turn off monitor
  }
  sleep 60000 ; sleep one minute
}

;sound reducing loop
Loop %numberOfSteps% 
{
    /*
    ; tray tip
    curVol := SoundGet, currentMasterVolume
    timeBeforeShutdownMin := curVol * oneStepDurationSec / 60
    ; myTrayTip = "Shutting down in..." . timeBeforeShutdownMin
    Menu, Tray, Tip, myTrayTip
    */
    
	SoundSet, -2
	sleep %oneStepDurationMillisec%
    
    ; turn monitor off again after key input
    if (A_TimeIdlePhysical >= 5000){
      SendMessage,0x112,0xF170,2,,Program Manager ; turn off monitor
    }
}

;pause itunes and/or spotify, to stop any sudden sounds when we reset the volume
DetectHiddenWindows , On
ControlSend , ahk_parent, {space}, iTunes ahk_class iTunes
ControlSend , ahk_parent, {space}, ahk_class SpotifyMainWindow
DetectHiddenWindows , Off

; --- stop other audio player(s), add your own here ---
; exit AIMP
Process, Exist, AIMP.exe
If ErrorLevel <> 0
	Process, Close, AIMP.exe

Sleep 5000 ; wait a little before shutting down so players can finish closing

SoundSet, currentMasterVolume ; set volume back to original value

if (shutdown = "true")
{
   Shutdown, 8
}

exit
