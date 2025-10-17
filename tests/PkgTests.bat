::! Copyright (c) 2021  Denis Kuzmin <x-3F@outlook.com> github/3F
::! Copyright (c) netfx4sdk contributors https://github.com/3F/netfx4sdk/graphs/contributors
::! Licensed under the MIT License (MIT).
::! See accompanying License.txt file or visit https://github.com/3F/netfx4sdk
@echo off

setlocal enableDelayedExpansion

call a isNotEmptyOrWhitespaceOrFail %~1 || exit /B1

set /a gcount=!%~1! & set /a failedTotal=!%~2!
set "exec=%~3" & set "wdir=%~4"

:::::::::::::::::: :::::::::::::: :::::::::::::::::::::::::
:: Tests

    if exist "%nfxLocalServer%" ( set nfxServer=/p:ngserver="%nfxLocalServer%" ) else set "nfxServer="

    set "netfx4sdkCurrent=netfx4sdk.%appversionNfx%"

    :: check if the package is not published yet /F-156
        set "packageNetfx4sdkIsNotReady="
        call a execute "%wdir%%exec% ~netfx4sdk/%appversionNfx%" 2>nul>nul || set "packageNetfx4sdkIsNotReady=true"
        if defined packageNetfx4sdkIsNotReady echo Warning: Remote package netfx4sdk is not ready. Some tests will be disabled.

    :: NOTE: :startTest will use ` as "
    :: It helps to use double quotes inside double quotes " ... `args` ... "

:::::::::::::::::
    call :cleanup


    ::_______ ------ ______________________________________

        if not defined packageNetfx4sdkIsNotReady (

            call a unsetPackage %netfx4sdkCurrent%
            call a checkFsNo %netfx4sdkCurrent%.html || goto x
            call a checkFsNo hMSBuild.bat || goto x
            call a checkFsNo netfx4sdk.cmd || goto x
            call a checkFsNo "packages\%netfx4sdkCurrent%\netfx4sdk.cmd" || goto x

            call a startTest "~netfx4sdk/%appversionNfx%" || goto x
                call a findInStreamOrFail "netfx4sdk/%appversionNfx% ... "
                call a checkFsNo %netfx4sdkCurrent%.html || goto x
                call a checkFs hMSBuild.bat || goto x
                call a checkFs netfx4sdk.cmd || goto x
                call a checkFsNo "packages\%netfx4sdkCurrent%\netfx4sdk.cmd" || goto x
            call a completeTest
        )
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        if not defined packageNetfx4sdkIsNotReady (
            call a unsetFile hMSBuild.bat
            call a unsetFile netfx4sdk.cmd

            call a startTest "+netfx4sdk/%appversionNfx%" || goto x
                call a findInStreamOrFail "hMSBuild/%appversionNfx% ... "
                call a checkFs %netfx4sdkCurrent%.html || goto x
                call a checkFs hMSBuild.bat || goto x
                call a checkFs netfx4sdk.cmd || goto x
                call a checkFs "packages\%netfx4sdkCurrent%\netfx4sdk.cmd" || goto x
                call a checkFs "packages\%netfx4sdkCurrent%\hMSBuild.bat" || goto x
            call a completeTest
        )
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a unsetFile hMSBuild.bat
        call a unsetFile netfx4sdk.cmd

        call a startTest "~netfx4sdk/%appversionNfx% %nfxServer%" || goto x
            call a checkFs hMSBuild.bat || goto x
            call a checkFs netfx4sdk.cmd || goto x
        call a completeTest
    ::_____________________________________________________


:::::::::::::
call :cleanup

:::::::::::::::::: :::::::::::::: :::::::::::::::::::::::::
::
:x
endlocal & set /a %1=%gcount% & set /a %2=%failedTotal%
if !failedTotal! EQU 0 exit /B 0
exit /B 1

:cleanup
    call a unsetFile %netfx4sdkCurrent%.html
    call a unsetFile hMSBuild.bat
    call a unsetFile netfx4sdk.cmd
    call a unsetPackage %netfx4sdkCurrent%
    call a unsetDir packages
exit /B 0