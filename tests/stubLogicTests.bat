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

        call a startTest "-debug -mode pkg -tfm 4.5" || goto x
            call a msgOrFailAt 1 "run action: pkg" || goto x
            call a msgOrFailAt 2 "net45 v4.5" || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -mode package -tfm 4.6.2" || goto x
            call a msgOrFailAt 1 "run action: pkg" || goto x
            call a msgOrFailAt 2 "net462 v4.6.2" || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -mode sys-or-pkg -tfm 4.5 -force" || goto x
            call a msgOrFailAt 1 "run a forced action: sys" || goto x
            call a msgOrFailAt 2 "net45 v4.5" || goto x

            call a findInStreamOrFail "[*] WARN: Failed: 1202" 5,n || goto x
            call a findInStreamOrFail "Switch to pkg mode for second attempt due to '-mode sys-or-pkg'" 7,n || goto x
            call a findInStreamOrFail "Apply .NET Framework v4.5 package ..." 8,n || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -mode system -tfm 4.5 -force" 1202 || goto x
            call a msgOrFailAt 1 "run a forced action: sys" || goto x
            call a msgOrFailAt 2 "net45 v4.5" || goto x
            call a failIfInStream "Apply .NET Framework v4.5 package" || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -mode sys-or-pkg -tfm 4.5 -pkg-version 1.0.3 -force" || goto x
            call a msgOrFailAt 1 "set package version: 1.0.3" || goto x
            call a msgOrFailAt 2 "run a forced action: sys" || goto x
            call a findInStreamOrFail "Apply .NET Framework v4.5 package ..." 8,n || goto x
            call a findInStreamOrFail "dpkg  packages\netfx4sdk.cmd.net45.1.0.3\build\.NETFramework\v4.5" 10,n || goto x

            set /a n+=1
            call a msgOrFailAt !n! "ren " || goto x
            call a msgOrFailAt !n! "v4.5.netfx4sdk.cmd" || goto x

            set /a n+=1
            call a msgOrFailAt !n! "mklink /J " || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -mode system-or-package -tfm 4.5 -no-mklink -pkg-version 1.0.3 -force" || goto x

            call a findInStreamOrFail "[*] WARN: Failed: 1202" 5,n || goto x
            call a findInStreamOrFail "Switch to pkg mode for second attempt due to '-mode sys-or-pkg'" 6,n || goto x

            call a findInStreamOrFail "Apply .NET Framework v4.5 package ..." 8,n || goto x
            call a findInStreamOrFail "dpkg  packages\netfx4sdk.cmd.net45.1.0.3\build\.NETFramework\v4.5" 10,n || goto x

            set /a n+=1
            call a msgOrFailAt !n! "ren " || goto x
            call a msgOrFailAt !n! "v4.5.netfx4sdk.cmd" || goto x

            set /a n+=1
            call a msgOrFailAt !n! "xcp /E " || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -mode system -force" || goto x
            call :test40SystemForce "mklink" || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -mode system -no-mklink -force" || goto x
            call :test40SystemForce "xcp" || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -rollback -tfm 2.0" || goto x
            call a msgOrFailAt 1 "activated rollback" || goto x
            call a msgOrFailAt 2 "net20 v2.0" || goto x
            call a msgOrFailAt 3 "There's nothing to rollback." || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -rollback -tfm 2.0 -force" || goto x
            call a msgOrFailAt 1 "activated a forced rollback" || goto x
            call a msgOrFailAt 2 "net20 v2.0" || goto x
            call a msgOrFailAt 3 "rmdir /Q/S " || goto x
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

exit /B 0


::::::::::::
:: templates

:test40SystemForce {in:mklinkOrXcp}

    call a msgOrFailAt 1 "run a forced action: sys" || exit /B 1
    call a msgOrFailAt 2 "net40 v4.0" || exit /B 1

    call a findInStreamOrFail "Apply hack using assemblies for Windows ..." 7,n || exit /B 1
    call a findInStreamOrFail "-no-less-4 -no-vswhere -no-vs -only-path -notamd64" 8,n || exit /B 1

    set /a n+=1
    call a msgOrFailAt !n! "# 1  : " || exit /B 1
    set /a n+=1
    call a msgOrFailAt !n! "# 2  : 0" || exit /B 1

    set /a n+=1
    call a msgOrFailAt !n! "xcp /E " || exit /B 1
    call a msgOrFailAt !n! "v4.0.netfx4sdk.cmd" || exit /B 1


    set /a n+=2
    call a msgOrFailAt !n! "mkdir " || exit /B 1
    set /a n+=1
    call a msgOrFailAt !n! "%~1 " || exit /B 1
    set /a n+=100
    call a findInStreamOrFail "%~1 " !n!,n || exit /B 1

    set /a n+=1
    call a findInStreamOrFail "mkdir " !n!,n || exit /B 1
    set /a n+=2
    call a msgOrFailAt !n! "mkdir " || exit /B 1

    set /a n+=2
    call a msgOrFailAt !n! "Done." || exit /B 1
exit /B 0
