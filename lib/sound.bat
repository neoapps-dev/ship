set "sfx=lib\sfx"

:_playSound
REM %@playSound% "path"
set "@playSound=start "" /B %~dp0\..\lib\cmdwiz\cmdwiz playsound"