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
    call :createEmptyPackages 1.0.3
    call :isMklinkSupported mklinkSupport

    ::_______ ------ ______________________________________

        call a startTest "-debug -mode pkg -tfm 4.5" || goto x
            call a msgOrFailAt 1 "run action: pkg" || goto x
            call a msgOrFailAt 2 "net45 v4.5" || goto x
            call :failIfInStreamExcept "\\" "# 1  : " || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -mode package -tfm 4.6.2" || goto x
            call :failIfInStreamExcept "\\" "# 1  : " || goto x
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
            call :failIfInStreamExcept "\\" "# 1  : " || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -mode system -tfm 4.5 -force" 1202 || goto x
            call a msgOrFailAt 1 "run a forced action: sys" || goto x
            call a msgOrFailAt 2 "net45 v4.5" || goto x
            call a failIfInStream "Apply .NET Framework v4.5 package" || goto x
            call :failIfInStreamExcept "\\" "# 1  : " || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -mode sys-or-pkg -tfm 4.5 -pkg-version 1.0.3 -force" || goto x
            if not defined mklinkSupport (
                call a findInStreamOrFail "NOTE: '-no-mklink' is activated because links are not supported in this environment." 1,n || goto x
                call :test45SysOrPkgForce "xcopy" || goto x

            ) else (
                call :test45SysOrPkgForce "mklink" || goto x
            )
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -mode system-or-package -tfm 4.5 -no-mklink -pkg-version 1.0.3 -force" || goto x
            call :test45SysOrPkgForce "xcopy" || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -mode system -force" || goto x
            if not defined mklinkSupport (
                call a findInStreamOrFail "NOTE: '-no-mklink' is activated because links are not supported in this environment." 1,n || goto x
                call :test40SystemForce "xcopy" || goto x

            ) else (
                call :test40SystemForce "mklink" || goto x
            )
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -mode system -no-mklink -force" || goto x
            call :test40SystemForce "xcopy" || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -rollback -tfm 2.0" || goto x
            call :failIfInStreamExcept "\\" "# 1  : " || goto x
            call a msgOrFailAt 1 "activated rollback" || goto x
            call a msgOrFailAt 2 "net20 v2.0" || goto x
            call a msgOrFailAt 3 "There's nothing to rollback." || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -rollback -tfm 2.0 -force" || goto x
            call :failIfInStreamExcept "\\" "# 1  : " || goto x
            call a msgOrFailAt 1 "activated a forced rollback" || goto x
            call a msgOrFailAt 2 "net20 v2.0" || goto x
            call a msgOrFailAt 3 "rmdir /Q/S " || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-mode system -force" || goto x
            if not defined mklinkSupport (
                call a findInStreamOrFail "NOTE: '-no-mklink' is activated because links are not supported in this environment." 1,n || goto x
                call :test40SystemForceNoDebug "xcopy" || goto x

            ) else (
                call :test40SystemForceNoDebug "mklink" || goto x
            )
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-mode system -no-mklink -force" || goto x
            call :test40SystemForceNoDebug "xcopy" || goto x
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
    call a unsetDir packages
exit /B 0


::::::::::::
:: templates

:test40SystemForce {in:mklinkOrXcp}

    call :failIfInStreamExcept "\\" "# 1  : " || exit /B 1
    call a msgOrFailAt 1 "run a forced action: sys" || exit /B 1
    call a msgOrFailAt 2 "net40 v4.0" || exit /B 1

    call a findInStreamOrFail "Apply hack using assemblies for Windows ..." 4,n || exit /B 1
    call a findInStreamOrFail "-no-less-4 -no-vswhere -no-vs -only-path -notamd64" 5,n || exit /B 1

    set /a n+=1
    call a msgOrFailAt !n! "# 1  : " || exit /B 1
    set /a n+=1
    call a msgOrFailAt !n! "# 2  : 0" || exit /B 1

    set /a n+=1
    call a msgOrFailAt !n! "xcopy " || exit /B 1
    call a msgOrFailAt !n! "v4.0.netfx4sdk.cmd` /E/I/Q/H/K/O/X/Y" || exit /B 1

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

:test45SysOrPkgForce {in:mklinkOrXcp}

    call :failIfInStreamExcept "\\" "# 1  : " || exit /B 1
    call a msgOrFailAt 1 "set package version: 1.0.3" || exit /B 1
    call a msgOrFailAt 2 "run a forced action: sys" || exit /B 1
    call a findInStreamOrFail "[*] WARN: Failed: 1202" 5,n || exit /B 1
    call a findInStreamOrFail "Switch to pkg mode for second attempt due to '-mode sys-or-pkg'" 6,n || exit /B 1

    call a findInStreamOrFail "Apply .NET Framework v4.5 package ..." 8,n || exit /B 1
    call a findInStreamOrFail "dpkg  packages\netfx4sdk.cmd.net45.1.0.3\build\.NETFramework\v4.5" 10,n || exit /B 1

    set /a n+=1
    call a msgOrFailAt !n! "ren " || exit /B 1
    call a msgOrFailAt !n! "v4.5.netfx4sdk.cmd" || exit /B 1

    set /a n+=1
    if "%~1"=="mklink" (

        call a msgOrFailAt !n! "mklink /J " || exit /B 1

    ) else (
        call a msgOrFailAt !n! "xcopy `packages\netfx4sdk.cmd.net45.1.0.3" || exit /B 1
        call a msgOrFailAt !n! "/E/I/Q/H/K/O/X/Y" || exit /B 1
    )
exit /B 0

:test40SystemForceNoDebug {in:mklinkOrXcp}

    call a failIfInStream "\\" || exit /B 1
    call a failIfInStream "run a forced action:" || exit /B 1
    call a failIfInStream "net40 v4.0" || exit /B 1

    call a findInStreamOrFail "Apply hack using assemblies for Windows ..." 1,n || exit /B 1
    call a findInStreamOrFail "%~1 " 100,n || exit /B 1

    set /a n+=1
    call a findInStreamOrFail "mkdir " !n!,n || exit /B 1
    set /a n+=2
    call a msgOrFailAt !n! "mkdir " || exit /B 1

    set /a n+=2
    call a msgOrFailAt !n! "Done." || exit /B 1
exit /B 0

::::::::::
:: helpers

:createEmptyPackages
    :: (1) - package version
    call :createEmptyPackage %~1 4.0
    call :createEmptyPackage %~1 4.5
    call :createEmptyPackage %~1 4.6.2
exit /B 0

:createEmptyPackage
    :: (1) - package version
    :: (2) - tfm version
    set _tfmv=%~2
    mkdir packages 2>nul>nul
    mkdir packages\netfx4sdk.cmd.net%_tfmv:.=%.%~1\build\.NETFramework\v%_tfmv%
exit /B 0

:failIfInStreamExcept
    ::  (1) - substring to check
    ::  (2) - ignore if the found contains this substring
    :: !!1  - Error code 1 if failed.

    set /a _lineSubstring=0
    :_whileLineSubstring
    call a findInStream "%~1" !_lineSubstring! _lineSubstring && (

        call a msgAt !_lineSubstring! "%~2" _lineIgnore
        if .!_lineIgnore! NEQ .1 (
            call a failTest
            exit /B 1
        )

        if !_lineSubstring! LSS !msgIdx! (
            set /a _lineSubstring+=1
            goto _whileLineSubstring
        )
    )
exit /B 0

:isMklinkSupported
    :: *&(1) Results as a defined variable if supported.
    mklink 2>nul>nul
    if !ERRORLEVEL! EQU 9009 ( set "%1=" ) else ( set "%1=1" )
exit /B 0