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

    :: NOTE: :startTest will use ` as "
    :: It helps to use double quotes inside double quotes " ... `args` ... "

:::::::::::::::::
    call :cleanup

    ::_______ ------ ______________________________________

        call a startTest "-help" || goto x
            call a msgOrFailAt 0 "" || goto x

            if not defined appversionHms call a failTest "Empty *appversionHms" & goto x
            if not "%appversionHms%"=="off" (
                call a msgOrFailAt 1 "netfx4sdk %appversionHms%" || goto x
            )
            call a msgOrFailAt 2 "github/3F" || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-version" || goto x
            if not defined appversionHms call a failTest "Empty *appversionHms" & goto x
            if not "%appversionHms%"=="off" (
                call a msgOrFailAt 1 "%appversionHms%" || goto x
            )
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-?" || goto x
            call a msgOrFailAt 1 "netfx4sdk %appversionHms%" || goto x
            call a msgOrFailAt 2 "github/3F" || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "/?" || goto x
            call a msgOrFailAt 1 "netfx4sdk %appversionHms%" || goto x
            call a msgOrFailAt 2 "github/3F" || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-h" || goto x
            call a msgOrFailAt 1 "netfx4sdk %appversionHms%" || goto x
            call a msgOrFailAt 2 "github/3F" || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-mode" 1 || goto x
            call a msgOrFailAt 1 "Incorrect key or value for `-mode`" || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-mode notrealmode" 1 || goto x
            call a msgOrFailAt 1 "Incorrect key or value for `-mode`" || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-notrealkey" 1 || goto x
            call a msgOrFailAt 1 "Incorrect key or value for `-notrealkey`" || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "qwertyvalue" 1 || goto x
            call a msgOrFailAt 1 "Incorrect key or value for `qwertyvalue`" || goto x
        call a completeTest
    ::_____________________________________________________



    :: TODO: mocking core logic to test other keys


:::::::::::::
call :cleanup

:::::::::::::::::: :::::::::::::: :::::::::::::::::::::::::
::
:x
endlocal & set /a %1=%gcount% & set /a %2=%failedTotal%
if !failedTotal! EQU 0 exit /B 0
exit /B 1

:cleanup

exit /B 0