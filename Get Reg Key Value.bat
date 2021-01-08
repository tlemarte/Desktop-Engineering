@echo OFF

setlocal ENABLEEXTENSIONS
::FOR 64 BIT SYSTEMS
set KEY_NAME="HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\SSOProvider\ISXAgent"
set VALUE_NAME=Type

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
pause