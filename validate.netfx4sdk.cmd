::! Copyright (c) 2021  Denis Kuzmin <x-3F@outlook.com> github/3F
::! Copyright (c) netfx4sdk contributors https://github.com/3F/netfx4sdk/graphs/contributors
::! Licensed under the MIT License (MIT).
::! See accompanying License.txt file or visit https://github.com/3F/netfx4sdk
@echo off
:: [1] Optional input directory  where gnt.bat is located.

set "input=%~1"
if not defined input set "input=.\"

set core="%input%netfx4sdk.cmd"
if not exist %core% call :notfound %core% & exit /B2

call hMSBuild -GetNuTool ~

call :check ".\netfx4sdk.cmd.sha1" %core% LF
echo.
call :check ".\netfx4sdk.cmd.crlf.sha1" %core% CRLF

echo.
if "%~1"=="" pause
exit /B 0

:check
    :: (1) path .sha1
    :: (2) path to core
    :: (2) LF/CRLF type
    if not exist %1 call :notfound %1 & exit /B2
    set /p _sha1=<%1

        echo %~2 ?= %_sha1% (%~3)
        call svc.gnt -sha1-cmp %2 %_sha1% -package-as-path
exit /B 0

:notfound
    echo %1 is not found>&2
exit /B 0