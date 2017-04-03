# SweetDreamsAHK_mod
AHK script to fade out music over a specific time (optionally set time before fading starts)

original version:
https://autohotkey.com/board/topic/54972-sweet-dreams-music-fade-out/

changes to original version:
v1.0:
 - stores previous wait and fade time values in .ini file (in same folder as the comiled .exe), 
    recalled when script is started again
 - starts fading from current volume and restores to original volume (not 100% as in original version)
 - screen is turned off (periodically every minute if idle) 
