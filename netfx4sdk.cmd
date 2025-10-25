::! netfx4sdk (c) Denis Kuzmin <x-3F@outlook.com> github.com/3F

@echo off & echo Incomplete script. Build it using build.bat @ github.com/3F/netfx4sdk >&2 & exit /B 1

:: Copyright (c) 2021  Denis Kuzmin <x-3F@outlook.com> github/3F
:: Copyright (c) netfx4sdk contributors https://github.com/3F/netfx4sdk/graphs/contributors
:: Licensed under the MIT License (MIT).
:: See accompanying License.txt file or visit https://github.com/3F/netfx4sdk

set "dp0=%~dp0"
set args=%*
set /a EXIT_CODE=0
setlocal enableDelayedExpansion

if not defined args goto usage

:: /? will cause problems for the call commands below, so we just escape this via supported alternative:
set esc=!args:/?=-h!

call :initargs arg esc amax
goto commands

:usage

echo.
echo netfx4sdk $core.version$
echo Copyright (c) 2021-2025  Denis Kuzmin ^<x-3F@outlook.com^> github/3F
echo Copyright (c) netfx4sdk contributors
echo.
echo Under the MIT License https://github.com/3F/netfx4sdk
echo.
echo ....
echo Keys
echo.
echo  -mode {value}
echo    * system            - (Recommended) Hack using assemblies for Windows.
echo    * package           - Apply remote package. Read [About modes] below.
echo    * sys               - Alias to 'system'.
echo    * pkg               - Alias to 'package'.
echo    * system-or-package - Fallback to 'system'. Use 'package' if 'system' failed.
echo    * package-or-system - Fallback to 'package'. Use 'system' if 'package' failed.
echo    * sys-or-pkg        - Alias to 'system-or-package'.
echo    * pkg-or-sys        - Alias to 'package-or-system'.
echo.
echo. -tfm {version}
echo    * 4.0 - Process for .NET Framework 4.0 (default)
echo    * 2.0, 3.5, 4.5, 4.6, 4.7, 4.8
echo    * 4.5.1, 4.5.2, 4.6.1, 4.6.2, 4.7.1, 4.7.2, 4.8.1
echo.
echo  -force      - Aggressive behavior when applying etc.
echo  -rollback   - Rollback applied modifications.
echo  -global     - To use the global toolset, like hMSBuild.
echo  -no-mklink  - Use direct copying instead of mklink (junction / symbolic).
echo  -stub       - Use a stub instead of actual processing.
echo.
echo  -pkg-version {arg} - Specific package version in pkg mode. Where {arg}:
echo      * 1.0.3 ...
echo      * latest - (keyword) To use latest version;
echo.
echo  -debug    - To show debug information.
echo  -version  - Display version of %~nx0.
echo  -help     - Display this help. Aliases: -help -h -?
echo.
echo ...........
echo About modes
echo.
echo '-mode sys' highly recommended because:
echo  [++] All modules are under Windows support.
echo  [+] It does not require internet connection (portable).
echo  [+] No decompression required (faster) compared to package mode.
echo  [-] This is behavior-based hack;
echo      Report or please fix us if something:
echo      https://github.com/3F/netfx4sdk
echo.
echo '-mode pkg' will try to apply remote package to the environment.
echo  [-] Officially dropped support since VS2022.
echo  [-] Requires internet connection to receive ~30 MB via GetNuTool.
echo  [-] Requires decompression of received data to 178 MB before use.
echo  [+] Well known official behavior.
echo.
echo ...................
echo %~n0 -mode sys
echo %~n0 -rollback
echo %~n0 -debug -force -mode package
echo %~n0 -mode pkg -pkg-version 1.0.2
echo %~n0 -mode pkg -tfm 4.5
echo %~n0 -global -mode pkg -tfm 3.5 -no-mklink -force
echo call %~n0 -mode sys ^|^| call %~n0 -mode pkg
echo %~n0 -mode sys-or-pkg

goto endpoint

:commands

set "vpkg=1.0.3"
set "tfms=2.0 3.5 4.0 4.5 4.6 4.7 4.8 4.5.1 4.5.2 4.6.1 4.6.2 4.7.1 4.7.2 4.8.1"
set "tModes=system sys package pkg system-or-package sys-or-pkg package-or-system pkg-or-sys"

set "kDebug="
set "kMode="
set "kRollback="
set "kForce="
set "kGlobal="
set "kNoMklink="
set "kTfm="
set "tfm="
set "kStub="
set "kFallback="

set /a ERROR_SUCCESS=0
set /a ERROR_FAILED=1
set /a ERROR_PATH_NOT_FOUND=3

set /a ERROR_NO_MODE=1000
set /a ERROR_ENV_W=1001
set /a ERROR_HMSBUILD_UNSUPPORTED=1002
set /a ERROR_HMSBUILD_NOT_FOUND=1003
set /a ERROR_UNAUTHORIZED_ACCESS=1004

set /a ERROR_ROLLBACK=1100
set /a ERROR_INVALID_KEY_OR_VALUE=1200
set /a ERROR_TFM_UNSUPPORTED=1202
set /a ERROR_GNT_FAIL=1400
set /a ERROR_CMD_BAD_COMMAND_OR_FILE=9009

set /a idx=0

:loopargs
set key=!arg[%idx%]!

    :: The help command

    if [!key!]==[-help] ( goto usage ) else if [!key!]==[-h] ( goto usage ) else if [!key!]==[-?] ( goto usage )

    :: Available keys

    if [!key!]==[-debug]
    (
        set kDebug=1
        goto continue
    )
    else if [!key!]==[-mode]
    ( set /a "idx+=1" & call :eval arg[!idx!] v

        call :isValidV !v! tModes || ( echo Mode '!v!' is not allowed. Use one of %tModes%>&2 & goto errkey )

        :: aliases

        if "!v!"=="system"
        (
            set "kMode=sys"
        )
        else if "!v!"=="package"
        (
            set "kMode=pkg"
        )
        else if "!v!"=="system-or-package"
        (
            set "kMode=sys-or-pkg"
        )
        else if "!v!"=="package-or-system"
        (
            set "kMode=pkg-or-sys"
        )
        else ( set "kMode=!v!" )

        :: fallback

        if "!kMode!"=="sys-or-pkg"
        (
            set "kMode=sys"
            set "kFallback=pkg"
        )
        else if "!kMode!"=="pkg-or-sys"
        (
            set "kMode=pkg"
            set "kFallback=sys"
        )
        goto continue
    )
    else if [!key!]==[-rollback]
    (
        set kRollback=1
        goto continue
    )
    else if [!key!]==[-pkg-version]
    ( set /a "idx+=1" & call :eval arg[!idx!] v

        set vpkg=!v!
        call :dbgprint "set package version:" v
        goto continue
    )
    else if [!key!]==[-version]
    (
        @echo $core.version$
        goto endpoint
    )
    else if [!key!]==[-no-mklink]
    (
        set kNoMklink=1
        goto continue
    )
    else if [!key!]==[-stub]
    (
        set kStub=1
        goto continue
    )
    else if [!key!]==[-global]
    (
        set kGlobal=1
        goto continue
    )
    else if [!key!]==[-force]
    (
        set kForce= a forced
        goto continue
    )
    else if [!key!]==[-tfm]
    ( set /a "idx+=1" & call :eval arg[!idx!] v

        call :isValidV !v! tfms || ( echo Version '!v!' is not allowed. Use one of %tfms%>&2 & goto errkey )

        set "kTfm=net!v:.=!"
        set "tfm=v!v!"

        goto continue
    )
    else
    (
        :errkey
        call :warn "Invalid key or value for '!key!'"
        set /a EXIT_CODE=%ERROR_INVALID_KEY_OR_VALUE%
        goto endpoint  ::~:
    )

:continue
set /a "idx+=1" & if %idx% LSS !amax! goto loopargs

:: - - -
:: Main 
:action

    call :initDefaultTfm 4.0

    if defined kRollback
    (
        call :dbgprint "activated!kForce! rollback"
    )
    else
    (
        call :dbgprint "run!kForce! action:" kMode
    )

    set "devdir=%ProgramFiles(x86)%"
    if not exist "!devdir!" set "devdir=%ProgramFiles%"
    set "devdir=!devdir!\Reference Assemblies\Microsoft\Framework\.NETFramework\"

    set "tdir=!devdir!!tfm!"
    set "rdir=!tdir!.%~nx0"

    call :dbgprint "!kTfm! !tfm!" tdir

    if defined kRollback
    (
        if not exist "!rdir!" if not defined kForce
        (
            echo There's nothing to rollback.
            if exist "!tdir!" echo Use '-force' key to delete !kTfm! without restrictions.
            goto endpoint
        )

        call :stub "rmdir" /Q/S "!tdir!" 2>nul

        if exist "!rdir!"
        (
            call :dbgprint "ren " rdir tfm
            ( call :stub "ren" "!rdir!" !tfm! 2>nul ) || ( set /a EXIT_CODE=%ERROR_ROLLBACK% & goto endpoint )
        )

        echo Rollback completed.
        goto endpoint
    )

    if exist "!rdir!"
    (
        echo %~nx0 has already been applied before. There's nothing to do anymore.
        echo Use '-rollback' key to re-apply with another mode if needed.
        exit /B 0
    )

    if exist "!tdir!\mscorlib.dll"
    (
        if not defined kForce
        (
            echo The Developer Pack was found successfully. There's nothing to do here at all.
            echo Use '-force' key to suppress the restriction if you really know what you're doing.
            set /a EXIT_CODE=%ERROR_SUCCESS% & goto endpoint
        )
        call :dbgprint "Suppress found SDK " tdir
    )

    if not defined kMode ( set /a EXIT_CODE=%ERROR_NO_MODE% & goto endpoint )

    if defined kGlobal ( set "engine=hMSBuild" ) else ( set engine="%~dp0hMSBuild" )

    call :invoke engine "-version" || ( set /a EXIT_CODE=%ERROR_HMSBUILD_NOT_FOUND% & goto endpoint )

    ( call :getFirstMsg engineVersion & call :checkEngine engineVersion 2,4,0 ) ||
        (
            set /a EXIT_CODE=%ERROR_HMSBUILD_UNSUPPORTED% & goto endpoint
        )

    if not defined kNoMklink
    (
        mklink 2>nul>nul
            & if !ERRORLEVEL! EQU %ERROR_CMD_BAD_COMMAND_OR_FILE%
            (
                echo NOTE: '-no-mklink' is activated because links are not supported in this environment.
                set "kNoMklink=2"
            )
    )

:activateMode

    call :dbgprint "kNoMklink " kNoMklink

    if "!kMode!"=="sys"
    (
        if not "!tfm!"=="v4.0" (
            set /a EXIT_CODE=%ERROR_TFM_UNSUPPORTED% & goto endpoint
        )

        echo Apply hack using assemblies for Windows ...

        call :invoke engine "-no-less-4 -no-vswhere -no-vs -only-path -notamd64"
        set /a EXIT_CODE=!ERRORLEVEL! & if !EXIT_CODE! NEQ 0 goto endpoint

        call :getFirstMsg lDir
        call :xcpDbg "!tdir!" "!rdir!" + || (
            set /a EXIT_CODE=%ERROR_UNAUTHORIZED_ACCESS% & goto endpoint
        )

        set lDir=!lDir:msbuild.exe=!

        :: NOTE: older xcopy doesn't like double slashes with single slashes, e.g. dir1\dir2\\file1 results as "File not found" /F-42
        :: that's why we need to fix the path from hmsbuild 2.5 (and older)
        set lDir=!lDir:\\=\!

        call :dbgprint "lDir " lDir
        if not exist "!lDir!" ( set /a EXIT_CODE=%ERROR_PATH_NOT_FOUND% & goto endpoint )

        call :stub "mkdir" "!tdir!" 2>nul
        for /F "tokens=*" %%i in ('dir /B "!lDir!*.dll"') do call :copyOrLinkFileDbg "!lDir!%%i" "!tdir!\%%i"
        for /F "tokens=*" %%i in ('dir /B "!lDir!WPF\*.dll"') do call :copyOrLinkFileDbg "!lDir!WPF\%%i" "!tdir!\%%i"

        set "xdir=!tdir!\RedistList" & call :stub "mkdir" "!xdir!" 2>nul
        set content=^<?xml version="1.0" encoding="utf-8"?^>^<FileList Redist="Microsoft-Windows-CLRCoreComp.4.0" Name=".NET Framework 4" RuntimeVersion="4.0" ToolsVersion="4.0" /^>
        call :fStub content "!xdir!\FrameworkList.xml"

        set "xdir=!tdir!\PermissionSets" & call :stub "mkdir" "!xdir!" 2>nul
        set content=^<PermissionSet version="1" class="System.Security.PermissionSet" Unrestricted="true" /^>
        call :fStub content "!xdir!\FullTrust.xml"
    )
    else if "!kMode!"=="pkg"
    (
        set npkg=Microsoft.NETFramework.ReferenceAssemblies.!kTfm!
        echo Apply .NET Framework !tfm! package ...

        set opkg=%~nx0.!kTfm!.%vpkg%
        if "%vpkg%"=="latest" ( set "vpkg=" ) else ( set "vpkg=/%vpkg%" )

        if defined kDebug set engine=!engine! -debug
        call !engine! -GetNuTool /p:ngpackages="!npkg!!vpkg!:!opkg!" ||
            (
                set /a EXIT_CODE=%ERROR_GNT_FAIL% & goto endpoint
            )

        set "dpkg=packages\!opkg!\build\.NETFramework\!tfm!"
        call :dbgprint "dpkg " dpkg

        if not exist "!dpkg!" (
            set /a EXIT_CODE=%ERROR_ENV_W% & goto endpoint
        )

        call :stub "ren" "!tdir!" !tfm!.%~nx0 2>nul || (
            set /a EXIT_CODE=%ERROR_UNAUTHORIZED_ACCESS% & goto endpoint
        )
        call :copyOrLinkFolder "!dpkg!" "!tdir!"
    )

echo Done.

set /a EXIT_CODE=%ERROR_SUCCESS%
goto endpoint


:: - - - - - - -
:: Post-actions
:endpoint

if !EXIT_CODE! NEQ 0
(
    call :warn "Failed: !EXIT_CODE!"
    set "hmsurl=https://github.com/3F/hMSBuild"

    if !EXIT_CODE! EQU %ERROR_PATH_NOT_FOUND%
    (
        call :warn "File or path was not found, use -debug"
    )
    else if !EXIT_CODE! EQU %ERROR_NO_MODE%
    (
        call :warn "Mode '-mode' is not specified, use -help"
    )
    else if !EXIT_CODE! EQU %ERROR_ENV_W%
    (
        call :warn "Wrong or unknown data in the specified '-mode !kMode!'"
    )
    else if !EXIT_CODE! EQU %ERROR_HMSBUILD_UNSUPPORTED%
    (
        call :warn "Unsupported hMSBuild version !engineVersion!, update !hmsurl!"
    )
    else if !EXIT_CODE! EQU %ERROR_HMSBUILD_NOT_FOUND%
    (
        call :warn "hMSBuild is not found. Try -global key or visit !hmsurl!"
    )
    else if !EXIT_CODE! EQU %ERROR_ROLLBACK%
    (
        call :warn "Something went wrong. Try to restore manually: !rdir!"
    )
    else if !EXIT_CODE! EQU %ERROR_TFM_UNSUPPORTED%
    (
        call :warn ".NET Framework !tfm! is not supported in the selected '-mode !kMode!'"
    )
    else if !EXIT_CODE! EQU %ERROR_GNT_FAIL%
    (
        call :warn "Failed network or there are no permissions to complete '-mode !kMode!'"
    )
    else if !EXIT_CODE! EQU %ERROR_UNAUTHORIZED_ACCESS%
    (
        call :warn "Unauthorized access. Make sure you have read/write permissions to the folders listed in '-debug'. Try run %~nx0 as administrator."
    )

    if defined kFallback
    (
        echo.& echo Switch to !kFallback! mode for second attempt due to '-mode !kMode!-or-!kFallback!'
        set "kMode=!kFallback!" & set "kFallback="
        goto activateMode
    )
)
exit /B !EXIT_CODE!


:: Functions
:: ::

:xcpDbg {in:src} {in:dst} {in:subdirs}
    if not defined kStub if not defined kDebug (
        call :xcp "%~1" "%~2" "%~3" >nul
        exit /B
    )
    call :xcp "%~1" "%~2" "%~3"
exit /B
:: :xcpDbg

:xcp {in:src} {in:dst} {in:subdirs}
    ( set "src=%~1" & set "dst=%~2" & set "subdirs=%~3" )
    if defined subdirs ( set "subdirs=/E" ) else ( set "subdirs=" )

    if not defined kStub ( call :dbgprint "xcp !subdirs!" src dst )
    set _x=xcopy "%src%" "%dst%" !subdirs!/I/Q/H/K/O/X/Y  ::&:

    :: NOTE: possible "Invalid switch - /B" in older xcopy

    if defined kNoMklink (
        call :stub %_x% || exit /B %ERROR_ENV_W%
    )
    else (
        call :stub %_x%/B 2>nul || call :stub %_x% || exit /B %ERROR_ENV_W%
    )
exit /B 0
:: :xcp

:checkEngine
    ::  &(1) - Raw version string e.g. 2.5.0.3303+ae68d39
    ::   (2) - Major. Must be greater or equal to.
    ::   (3) - Minor. Must be greater or equal to.
    ::   (4) - Patch. Must be greater or equal to.
    ::  !!1  - Error code 1 if unsupported version.

    for /F "tokens=1,2,3 delims=." %%a in ("!%~1!") do
    (
        if %%a LSS %~2 exit /B 1
        if %%a EQU %~2 (
            if %%b LSS %~3 exit /B 1
            if %%b EQU %~3 if %%c LSS %~4 exit /B 1
        )
    )
exit /B 0
:: :checkEngine

:copyOrLinkFileDbg {in:src} {in:dst}
    if not defined kStub if not defined kDebug (
        call :copyOrLinkFile "%~1" "%~2" >nul
        exit /B
    )
    call :copyOrLinkFile "%~1" "%~2"
exit /B
:: :copyOrLinkFileDbg

:copyOrLinkFile {in:src} {in:dst}
    if defined kNoMklink (
        call :xcpDbg "%~1" "%~2*"
    )
    else (
        call :stub "mklink" "%~2" "%~1"
    )
exit /B 0
:: :copyOrLinkFile

:copyOrLinkFolder {in:src} {in:dst}
    if defined kNoMklink (
        call :xcpDbg "%~1" "%~2" +
    )
    else (
        call :stub "mklink" /J "%~2" "%~1"
    )
exit /B 0
:: :copyOrLinkFolder

:initDefaultTfm {in:version}
    set "_v=%~1"
    if not defined kTfm set "kTfm=net!_v:.=!"
    if not defined tfm set "tfm=v!_v!"
exit /B 0
:: :initDefaultTfm

:isValidV {in:value} {in:&list}
    for %%t in (!%~2!) do (
        if "%~1"=="%%t" exit /B 0
    )
exit /B 1
:: :isValidV

:warn {in:msg}
    echo   [*] WARN: %~1 >&2
exit /B 0
:: :warn

:dbgprint {in:str} [{in:uneval1}, [{in:uneval2}]]
    if defined kDebug
    (
        :: NOTE: delayed 'dmsg' because symbols like ')', '(' ... requires protection after expansion. L-32
        set "dmsg=%~1" & echo [ %TIME% ] !dmsg! !%2! !%3!
    )
exit /B 0
:: :dbgprint

:initargs {in:vname} {in:arguments} {out:index}
    :: Usage: 1- the name for variable; 2- input arguments; 3- max index

    set _ieqargs=!%2!

    :: unfortunately, we also need to protect the equal sign '='
    :_eqp
    for /F "tokens=1* delims==" %%a in ("!_ieqargs!") do
    (
        if "%%~b"=="" (
            call :nqa %1 !_ieqargs! %3 & exit /B 0
        )
        else set _ieqargs=%%a E %%b
    )
    goto _eqp
    :nqa

    set "vname=%~1"
    set /a idx=-1

    :_initargs
        :: -
        set /a idx+=1
        set %vname%[!idx!]=%~2
        set %vname%{!idx!}=%2

        :: NOTE1: 'shift & ...' may be evaluated incorrectly without {newline} symbols;
        ::         Either shift + {newline} + ... + if %~3 ...; or if %~4 ... shift & ...

        :: NOTE2: %~4 because the next %~3 is reserved for {out:index}
        if "%~4" NEQ "" shift & goto _initargs

    set %3=!idx!
exit /B 0
:: :initargs

:eval {in:unevaluated} {out:evaluated}
    :: Usage: 1- input; 2- evaluated output

    :: delayed evaluation
    set _vl=!%1!  ::&:
    if not defined _vl set %2=&exit/B0

    :: data from %..% below should not contain double quotes, thus we need to protect this:

    :: set "_vl=%_vl: T =^%"   ::&:
    :: set "_vl=%_vl: L =^!%"  ::&:
    :: set _vl=!_vl: E ==!     ::&:

    set %2=!_vl!
exit /B 0
:: :eval

:invoke
    ::  (1) - Command via variable.
    :: &(2) - Input arguments.
    :: &[3] - Return code.
    :: !!0+ - Error code from (1)

    set "cmd=!%~1! %~2"

    :: NOTE: Use delayed !cmd! instead of %cmd% inside 'for /F' due to
    :: '=' (equal sign, which cannot be escaped as '^=' when runtime evaluation %cmd%)

    call :dbgprint "invoke: " cmd

    set "cmd=!cmd! 2^>^&1 ^&call echo %%^^ERRORLEVEL%%"
    set /a msgIdx=0

    for /F "tokens=*" %%i in ('!cmd!') do 2>nul
    (
        set /a msgIdx+=1
        set msg[!msgIdx!]=%%i
        call :dbgprint "# !msgIdx!  : %%i"
    )

    if not "%3"=="" set %3=!msg[%msgIdx%]!
exit /B !msg[%msgIdx%]!
:: :invoke

:getFirstMsg {out:message}
    set "%1=!msg[1]!"
exit /B 0
:: :getFirstMsg

:stub {in:app} {in:*}
    ( set "app=%~1" & shift )
    set appArgs=%1 %2 %3 %4 %5 %6 %7 %8 %9
    if not defined kStub ( call !app! !appArgs! & exit /B )
    echo !app! !appArgs!
exit /B 0
:: :stub

:fStub {in:&dstr} {in:path}
    if defined kStub ( echo !%~1!^> "%~2" ) else ( echo !%~1!> "%~2" )
exit /B 0
:: :fStub
