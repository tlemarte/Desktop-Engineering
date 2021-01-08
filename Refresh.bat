@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
setlocal ENABLEEXTENSIONS

set KEYNAME="HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\SSOProvider\ISXAgent"
set VALUENAME=Type

::Get OS version as variable
SET count=1
FOR /F "tokens=* USEBACKQ" %%F IN (`wmic os get version`) DO (
  SET var!count!=%%F
  SET /a count=!count!+1
)

::IF windows10, open the refresh tool
IF "%var2:~0,2%"=="10" (
	powershell -noexit "& ""\\Refresh\tool\path\goes\here"""
) ELSE (

::IF SINGLE/MUD, run PCMover or decom
	FOR /F "usebackq skip=4 tokens=1-3" %%A IN (`REG QUERY %KEY_NAME% /v %VALUE_NAME% 2^>nul`) DO (
		set ValueName=%%A
		set ValueType=%%B
		set ValueValue=%%C
	)
	if defined ValueName (
    		@echo Value Name = %ValueName%
		@echo Value Type = %ValueType%
		@echo Value Value = %ValueValue%
	) else (
	    @echo %KEY_NAME%\%VALUE_NAME% not found.
	)
	IF %KEYVALUE% == "0X1" (
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
		:: start "Decommision" \\Decommision\path\goes\here
		EXIT

		:yes
		:: start "PCmover" \\PCMover\path\goes\here


		EXIT
::IF SHARED, backup last 2 months of users then open decom
	) ELSE(

	)
)
ENDLOCAL
PAUSE