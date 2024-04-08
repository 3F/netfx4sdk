@echo off
:: Copyright (c) 2021  Denis Kuzmin <x-3F@outlook.com> github/3F
:: Tests. Part of https://github.com/3F/netfx4sdk

setlocal enableDelayedExpansion

:: path to the directory where the release is located
set "rdir=%~1"

:: path to core
set "core=%~2"

call a isNotEmptyOrWhitespaceOrFail core || exit /B1
call a isNotEmptyOrWhitespaceOrFail rdir || exit /B1

call a initAppVersion Hms

echo.
call a cprint 0E  ----------------------
call a cprint F0  "netfx4sdk .cmd testing"
call a cprint 0E  ----------------------
echo.

if "!gcount!" LSS "1" set /a gcount=0
if "!failedTotal!" LSS "1" set /a failedTotal=0

:::::::::::::::::: :::::::::::::: :::::::::::::::::::::::::
:: Tests

    echo. & call a print "Tests - 'keysAndLogicTests'"
    call .\keysAndLogicTests gcount failedTotal "%core%" "%rdir%"


::::::::::::::::::
::
echo.
call a cprint 0E ----------------
echo  [Failed] = !failedTotal!
set /a "gcount-=failedTotal"
echo  [Passed] = !gcount!
call a cprint 0E ----------------
echo.

if !failedTotal! GTR 0 goto failed
echo.
call a cprint 0A "All Passed."
exit /B 0

:failed
    echo.
    call a cprint 0C "Tests failed." >&2
exit /B 1
