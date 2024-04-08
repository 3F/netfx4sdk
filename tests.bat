@echo off

:: run tests by default

setlocal
    if exist "bin\Release\raw\" (

        set "rdir=..\bin\Release\raw\"

    ) else if exist ".sha1" (

        set "rdir=..\"

    ) else goto buildError

    cd tests
    call _run %rdir% netfx4sdk.cmd
endlocal
exit /B 0

:buildError
    echo. Tests cannot be started: Check your build first. >&2
exit /B 1