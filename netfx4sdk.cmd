@echo off & echo Incomplete script. Compile it first via 'build.bat' - github.com/3F/netfx4sdk 1>&2 & exit /B 1

:: netfx4sdk $core.version$
:: Copyright (c) 2021-2024  Denis Kuzmin <x-3F@outlook.com> github/3F
:: Copyright (c) netfx4sdk contributors https://github.com/3F/netfx4sdk

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
echo Copyright (c) 2021-2024  Denis Kuzmin ^<x-3F@outlook.com^> github/3F
echo Copyright (c) netfx4sdk contributors https://github.com/3F/netfx4sdk
echo.
echo ....
echo Keys
echo.
echo  -mode {value}
echo   * system   - (Recommended) Hack using assemblies for windows.
echo   * package  - Apply obsolete remote package. Read [About modes] below.
echo   * sys      - Alias to `system`
echo   * pkg      - Alias to `package`
echo.
echo  -force    - Aggressive behavior when applying etc.
echo  -rollback - Rollback applied modifications.
echo  -global   - To use the global toolset, like hMSBuild.
echo.
echo  -pkg-version {arg} - Specific package version. Where {arg}:
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
echo `-mode sys` highly recommended because
echo  [++] All modules are under windows support.
echo  [+] It does not require internet connection (portable).
echo  [+] No decompression required (faster) compared to package mode.
echo  [-] This is behavior-based hack;
echo      Report or please fix us if something:
echo      https://github.com/3F/netfx4sdk
echo.
echo `-mode package` will try to apply obsolete package to the environment.
echo  [-] Officially dropped support since VS2022.
echo  [-] Requires internet connection to receive ~30 MB via GetNuTool.
echo  [-] Requires decompression of received data to 178 MB before use.
echo  [+] Well known official behavior.
echo.
echo ...................
echo netfx4sdk -mode sys
echo netfx4sdk -rollback
echo netfx4sdk -debug -force -mode package
echo netfx4sdk -mode pkg -pkg-version 1.0.2

goto endpoint

:commands

set "tfm=v4.0"
set "vpkg=1.0.3"

set "kDebug=" & set "kMode=" & set "kRollback=" & set "kForce=" & set "kGlobal="

set /a ERROR_SUCCESS=0
set /a ERROR_FAILED=1
set /a ERROR_PATH_NOT_FOUND=3
set /a ERROR_NO_MODE=1000
set /a ERROR_ENV_W=1001
set /a ERROR_HMSBUILD_UNSUPPORTED=1002
set /a ERROR_HMSBUILD_NOT_FOUND=1003
set /a ERROR_ROLLBACK=1100

set /a idx=0

:loopargs
set key=!arg[%idx%]!

    :: The help command

    if [!key!]==[-help] ( goto usage ) else if [!key!]==[-h] ( goto usage ) else if [!key!]==[-?] ( goto usage )

    :: Available keys

    if [!key!]==[-debug] (

        set kDebug=1

        goto continue
    ) else if [!key!]==[-mode] ( set /a "idx+=1" & call :eval arg[!idx!] v
        
        if not "!v!"=="sys" if not "!v!"=="system" if not "!v!"=="pkg" if not "!v!"=="package" goto errkey

        if "!v!"=="system" ( set "kMode=sys" ) else if "!v!"=="package" ( set "kMode=pkg" ) else set "kMode=!v!"

        goto continue
    ) else if [!key!]==[-rollback] (
        
        set kRollback=1

        goto continue
    ) else if [!key!]==[-pkg-version] ( set /a "idx+=1" & call :eval arg[!idx!] v

        set vpkg=!v!
        call :dbgprint "set package version:" v

        goto continue
    ) else if [!key!]==[-version] ( 

        @echo $core.version$
        goto endpoint

    ) else if [!key!]==[-global] (

        set kGlobal=1

        goto continue
    ) else if [!key!]==[-force] ( 

        set kForce=1

        goto continue
    ) else (
        ::&:
        :errkey
        call :warn "Incorrect key or value for `!key!`"
        set /a EXIT_CODE=%ERROR_FAILED%
        goto endpoint  ::&:
    )

:continue
set /a "idx+=1" & if %idx% LSS !amax! goto loopargs

:: - - -
:: Main 
:action

    call :dbgprint "run action... " kMode kForce

    set devdir=%ProgramFiles(x86)%
    if not exist "%devdir%" set devdir=%ProgramFiles%
    set devdir=%devdir%\Reference Assemblies\Microsoft\Framework\.NETFramework\

    set tdir=%devdir%%tfm%
    set rdir=%tdir%.%~nx0

    if defined kRollback (

        if not exist "%rdir%" (
            echo There's nothing to rollback.
            goto endpoint
        )

        rmdir /Q/S "%tdir%" 2>nul
        call :dbgprint "ren " rdir tfm
        ( ren "%rdir%" %tfm% 2>nul ) || ( set /a EXIT_CODE=%ERROR_ROLLBACK% & goto endpoint )

        echo Rollback completed.
        goto endpoint

    )

    if exist "%rdir%" (
        echo %~nx0 has already been applied before. There's nothing to do anymore.
        echo Use `-rollback` key to re-apply with another mode if needed.
        exit /B 0
    )

    if exist "%tdir%\mscorlib.dll" (

        if not defined kForce (
            echo The Developer Pack was found successfully. There's nothing to do here at all.
            echo Use `-force` key to suppress the restriction if you really know what you are doing.
            set /a EXIT_CODE=%ERROR_SUCCESS% & goto endpoint
        )
        call :dbgprint "Suppress found SDK " tdir

    )

    if not defined kMode ( set /a EXIT_CODE=%ERROR_NO_MODE% & goto endpoint )

    if defined kGlobal ( set "engine=hMSBuild" ) else set engine="%~dp0hMSBuild"

    call :invoke engine "-version" || ( set /a EXIT_CODE=%ERROR_HMSBUILD_NOT_FOUND% & goto endpoint )
    call :getFirstMsg engineVersion & if !engineVersion! LSS 2.4 (
        set /a EXIT_CODE=%ERROR_HMSBUILD_UNSUPPORTED% & goto endpoint
    )

    if "%kMode%"=="sys" (

        echo Apply hack using assemblies for windows ...

        call :invoke engine "-no-less-4 -no-vswhere -no-vs -only-path -notamd64"
        set /a EXIT_CODE=%ERRORLEVEL% & if !EXIT_CODE! NEQ 0 goto endpoint

        call :getFirstMsg lDir
        call :xcp "%tdir%" "%rdir%" || goto endpoint

        set lDir=!lDir:msbuild.exe=!
        call :dbgprint "lDir " lDir
        if not exist "!lDir!" ( set /a EXIT_CODE=%ERROR_PATH_NOT_FOUND% & goto endpoint )

        mkdir "%tdir%" 2>nul
        for /F "tokens=*" %%i in ('dir /B "!lDir!*.dll"') do mklink "%tdir%\%%i" "!lDir!%%i" >nul 2>nul
        for /F "tokens=*" %%i in ('dir /B "!lDir!WPF\*.dll"') do mklink "%tdir%\%%i" "!lDir!WPF\%%i" >nul 2>nul

        set "xdir=%tdir%\RedistList" & mkdir "!xdir!" 2>nul
        echo ^<?xml version="1.0" encoding="utf-8"?^>^<FileList Redist="Microsoft-Windows-CLRCoreComp.4.0" Name=".NET Framework 4" RuntimeVersion="4.0" ToolsVersion="4.0" /^>> "!xdir!\FrameworkList.xml"

        set "xdir=%tdir%\PermissionSets" & mkdir "!xdir!" 2>nul
        echo ^<PermissionSet version="1" class="System.Security.PermissionSet" Unrestricted="true" /^>> "!xdir!\FullTrust.xml"


    ) else if "%kMode%"=="pkg" (

        set npkg=Microsoft.NETFramework.ReferenceAssemblies.net40
        echo Apply !npkg! package ...

        set opkg=%~nx0.%vpkg%
        if "%vpkg%"=="latest" ( set "vpkg=" ) else set vpkg=/%vpkg%

        if defined kDebug set engine=!engine! -debug
        call !engine! -GetNuTool /p:ngpackages="!npkg!!vpkg!:!opkg!"

        set "dpkg=packages\!opkg!\build\.NETFramework\%tfm%"
        call :dbgprint "dpkg " dpkg

        if not exist "!dpkg!" (
            set /a EXIT_CODE=%ERROR_ENV_W% & goto endpoint
        )

        ren "%tdir%" %tfm%.%~nx0 2>nul
        mklink /J "%tdir%" "!dpkg!"

    )

echo Done.

set /a EXIT_CODE=%ERROR_SUCCESS%
goto endpoint


:: - - - - - - -
:: Post-actions
:endpoint

if !EXIT_CODE! NEQ 0 (
    call :warn "Failed: !EXIT_CODE!"

    if !EXIT_CODE! EQU %ERROR_PATH_NOT_FOUND% (
        call :warn "File or path was not found, use -debug"
    )
    else if !EXIT_CODE! EQU %ERROR_NO_MODE% (
        call :warn "Mode is not specified"
    )
    else if !EXIT_CODE! EQU %ERROR_ENV_W% (
        call :warn "Wrong or unknown data in specified mode"
    )
    else if !EXIT_CODE! EQU %ERROR_HMSBUILD_UNSUPPORTED% (
        call :warn "Unsupported version of hMSBuild"
    )
    else if !EXIT_CODE! EQU %ERROR_HMSBUILD_NOT_FOUND% (
        call :warn "hMSBuild is not found, try -global"
    )
    else if !EXIT_CODE! EQU %ERROR_ROLLBACK% (
        call :warn "Something went wrong. Try to restore manually: %rdir%"
    )
)
exit /B !EXIT_CODE!


:: Functions
:: ::

:xcp {in:src} {in:dst}
set "src=%~1" & set "dst=%~2"

    call :dbgprint "xcp " src dst
    set _x=xcopy "%src%" "%dst%" /E/I/Q/H/K/O/X  ::&:
    :: Invalid switch - /B in older xcopy
    %_x%/B 2>nul>nul || %_x% >nul || exit /B %ERROR_ENV_W%
exit /B 0
:: :xcp

:warn {in:msg}
    echo   [*] WARN: %~1 >&2
exit /B 0
:: :warn

:dbgprint {in:str} [{in:uneval1}, [{in:uneval2}]]
    if defined kDebug (
        :: NOTE: delayed `dmsg` because symbols like `)`, `(` ... requires protection after expansion. L-32
        set "dmsg=%~1" & echo [ %TIME% ] !dmsg! !%2! !%3!
    )
exit /B 0
:: :dbgprint

:initargs {in:vname} {in:arguments} {out:index}
    :: Usage: 1- the name for variable; 2- input arguments; 3- max index

    set _ieqargs=!%2!

    :: unfortunately, we also need to protect the equal sign '='
    :_eqp
    for /F "tokens=1* delims==" %%a in ("!_ieqargs!") do (
        if "%%~b"=="" (

            call :nqa %1 !_ieqargs! %3 & exit /B 0

        ) else set _ieqargs=%%a E %%b
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

        :: NOTE1: `shift & ...` may be evaluated incorrectly without {newline} symbols;
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

    :: NOTE: Use delayed !cmd! instead of %cmd% inside `for /F` due to
    :: `=` (equal sign, which cannot be escaped as `^=` when runtime evaluation %cmd%)

    call :dbgprint "invoke: " cmd

    set "cmd=!cmd! 2^>^&1 ^&call echo %%^^ERRORLEVEL%%"
    set /a msgIdx=0

    for /F "tokens=*" %%i in ('!cmd!') do 2>nul (
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
