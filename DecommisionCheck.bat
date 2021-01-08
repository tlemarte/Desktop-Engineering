@echo off
IF EXIST \\backup\path\goes\here\%ComputerName% (
start "Decommision" \\Decommision\path\goes\here
) ELSE (
:start
SET choice= 
SET /p choice=No PCmover backup found, open PCmover? [Y/N]:
IF NOT '%choice%'=='' SET choice=%choice:~0,1%
IF '%choice%'=='Y' GOTO yes
IF '%choice%'=='y' GOTO yes
IF '%choice%'=='N' GOTO no
IF '%choice%'=='n' GOTO no
IF '%choice%'=='' GOTO yes
ECHO "%choice%" is not valid
ECHO.
GOTO start

:no
start "Decommision" \\multicare.org\shares\124\isutils\Tools\DecommissionComputer.exe
EXIT

:yes
start "PCmover" \\mhssms2\PCmover2\PCmover.exe
EXIT
)