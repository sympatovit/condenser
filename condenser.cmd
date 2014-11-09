@echo off
powershell.exe -command "Unblock-File condenser.ps1"
setlocal
set tempscript=%temp%\%~n0.%random%.ps1
echo $ErrorActionPreference="Stop" >"%tempscript%"
echo ^& "%~dpn0.ps1" %* >>"%tempscript%"
powershell.exe -command "& \"%tempscript%\""
set errlvl=%ERRORLEVEL%
del "%tempscript%"
exit /b %errlvl%