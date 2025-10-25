::! Copyright (c) 2015  Denis Kuzmin <x-3F@outlook.com> github/3F
::! Copyright (c) GetNuTool contributors https://github.com/3F/GetNuTool/graphs/contributors
::! Licensed under the MIT License (MIT).
::! See accompanying License.txt file or visit https://github.com/3F/GetNuTool
@echo off

if "%~1"=="" echo Empty function name & exit /B 1
if .%~1 EQU .1001 call :NotRealLabel & exit /B
call :shiftArgs 1,99 shProcArgs %* & call :!shProcArgs! & exit /B

:initAppVersion
    :: [1] - Optional postfix.
    :: [2] - Optional path or version string

    set "_pathOrVer=%~2"
    if not defined _pathOrVer set "_pathOrVer=..\.version"

    if exist "%_pathOrVer%" (
        set /p appversion%~1=<"%_pathOrVer%"
    ) else (
        set appversion%~1=%_pathOrVer%
    )
exit /B

:invoke
    ::  (1) - Command.
    :: &(2) - Input arguments inside "..." via variable.
    :: &[3] - Return code.
    :: !!0+ - Error code from (1)

    set "cmd=%~1 !%2!"

    :: NOTE: Use delayed !cmd! instead of %cmd% inside `for /F` due to
    :: `=` (equal sign, which cannot be escaped as `^=` when runtime evaluation %cmd%)

    set "cmd=!cmd! 2^>^&1 ^&call echo %%^^ERRORLEVEL%%"
    set /a msgIdx=0

    for /F "tokens=*" %%i in ('!cmd!') do 2>nul (
        set /a msgIdx+=1
        set msg[!msgIdx!]=%%i
    )

    if not "%3"=="" set %3=!msg[%msgIdx%]!
exit /B !msg[%msgIdx%]!

:execute
    ::  (1) - Command.
    :: !!0+ - Error code from (1)

    call :invoke "%~1" nul retcode
exit /B !retcode!

:invokeShortVersion
    ::   (1) - Input command to get raw version string.
    :: *&(2) - Output in a short version format major.minor.patch
    ::  !!1  - Error code 1 if failed.

    for /F "tokens=1,2,3 delims=." %%a in ('%~1') do (
        set "%2=%%a.%%b.%%c" & exit /B 0
    )
    set "%2="
exit /B 1

:startExTest
    ::  (1) - Logic via :label name
    ::  (2) - Input arguments to core inside "...". Use ` sign to apply " double quotes inside "...".
    ::  [3] - Expected return code. Default, 0. Negative values (e.g. -1) ​​to disable checking.
    :: !!1  - Error code 1 if app's error code is not equal [2] as expected.

    set "tArgs=%~2"
    if "%~3"=="" ( set /a exCode=0 ) else set /a exCode=%~3

    :: netfx4sdk, F-47
    call :cleanStream

    if "!tArgs!" NEQ "" set tArgs=!tArgs:`="!

    set /a gcount+=1
    echo.
    echo - - - - - - - - - - - -
    echo Test #%gcount% @ %TIME%
    echo - - - - - - - - - - - -
    echo keys: !tArgs!
    echo.

    set callback=%~1 & shift

    goto %callback%
    :_logicExTestEnd

    if %exCode% LSS 0 exit /B 0
    if "!retcode!" NEQ "%exCode%" call :failTest & exit /B 1
exit /B 0

:startTest
    ::  (1) - Input arguments to core inside "...". Use ` sign to apply " double quotes inside "...".
    ::  [2] - Expected return code. Default, 0.
    :: !!1  - Error code 1 if app's error code is not equal [2] as expected.

    call :startExTest _logicStartTest %*
    exit /B
    :_logicStartTest
        call :invoke "%wdir%%exec%" tArgs retcode

goto _logicExTestEnd
:: :startTest

:startABTest
    ::   (1) - Input arguments inside "...". Use ` sign to apply " double quotes inside "...".
    ::   (2) - A command
    ::   (3) - B command
    ::  &(4) - Result from (2) A
    ::  &(5) - Result from (3) B

    set "exA=%2" & set "exB=%3"
    set "_4=%4"
    set "_5=%5"

    call :startExTest _logicStartABTest %1
    exit /B
    :_logicStartABTest
        call :invoke !exA! tArgs retcodeA & call :getMsgAt 1 outA
        call :invoke !exB! tArgs retcodeB & call :getMsgAt 1 outB

        set %_4%=!outA! !retcodeA!
        set %_5%=!outB! !retcodeB!
        set /a retcode=0

goto _logicExTestEnd
:: :startABTest

:startABStreamTest
    ::    (1) - Input arguments inside "...". Use ` sign to apply " double quotes inside "...".
    ::    (2) - A command
    ::    (3) - B command
    ::    [4] - Expected return code. Default, 0.
    ::  &*[5] - Result stream from (2) A; e.g. !%argname%[n+]!

    set "exA=%2" & set "exB=%3"
    set "_5=%5"

    call :startExTest _logicStartABStreamTest "-debug %~1" %~4
    exit /B
    :_logicStartABStreamTest

        :: Disables time [ 21:50:25.46 ] as [ - ]
        set "TIME=-"

        call :invoke !exA! tArgs retcodeA
        call :cloneStreamAs _streamA
        call :invoke !exB! tArgs retcodeB

        set /a retcode=%retcodeB%
        call :eqOriginStreamWithOrFail _streamA 1 || set /a retcode=1

        set "TIME="
        if defined _5 set %_5%=_streamA

goto _logicExTestEnd
:: :startABStreamTest

:abStreamTest
    ::    (1) - Input arguments inside "...". Use ` sign to apply " double quotes inside "...".
    ::    (2) - A command
    ::    (3) - B command
    ::    [4] - Expected return code. Default, 0.

    call :startABStreamTest "%~1" "%~2" "%~3" %~4 || exit /B 1
    call :completeTest
exit /B 0

:startVFTest
    ::  (1) - Input core application.
    ::  (2) - Input arguments to core inside "...". Use ` sign to apply " double quotes inside "...".
    ::  (3) - Full path to actual data in the file system.
    :: &(4) - Return actual data.

    set _exapp="%~1"
    set _lwrap="%~3"
    set "_4=%4"

    call :startExTest _logicStartVFTest %2
    exit /B
    :_logicStartVFTest
        call :invoke %_exapp% tArgs retcode
        for /f "usebackq tokens=*" %%i in (`type %_lwrap%`) do set "%_4%=%%i"

goto _logicExTestEnd
:: :startVFTest

:completeTest
    call :cprint 27 [Passed]
exit /B 0

:failTest
    :: [1] - Optional message string.

    set /a "failedTotal+=1"

    if not "%~1"=="" echo %~1
    call :printStream failed
    echo. & call :cprint 47 [Failed]
exit /B 0

:cleanStream
    for /L %%i in (0,1,!msgIdx!) do set "msg[%%i]="
    set /a msgIdx=0
exit /B 0

:printStream
    if "!msgIdx!"=="" exit /B 1
    for /L %%i in (0,1,!msgIdx!) do echo (%%i) *%~1: !msg[%%i]!
exit /B 0

:printStreamAB
    :: &(1) - Stream name to print together with origin.

    if "!msgIdx!"=="" exit /B 1
    for /L %%i in (0,1,!msgIdx!) do (
        echo `!_streamA[%%i]!` & echo `!msg[%%i]!`  & echo --
    )
exit /B 0

:failStreamsTest
    :: &(1) - Stream name to print together with origin.
    ::  [2] - Don't count in the total counter if 1.

    if "%~2" NEQ "1" set /a "failedTotal+=1"
    call :printStreamAB %~1
exit /B 0

:contains
    :: &(1) - Input string via variable
    ::  (2) - Substring to check. Use ` instead of " and do NOT use =(equal sign) since it's not protected.
    :: &(3) - Result, 1 if found.

    :: TODO: L-39 protect from `=` like the main module does; or compare in parts using `#`

    set "input=!%~1!"

    if "%~2"=="" if "!input!"=="" set /a %3=1 & exit /B 0
    if "!input!"=="" if not "%~2"=="" set /a %3=0 & exit /B 0

    set "input=!input:"=`!"
    set "cmp=!input:%~2=!"

    if "!cmp!" NEQ "!input!" ( set /a %3=1 ) else set /a %3=0
exit /B 0

:printMsgAt
    ::  (1) - index at msg
    ::  [2] - color attribute via :color call
    ::  [3] - prefixed message at the same line
    :: !!1  - Error code 1 if &(1) is empty or not valid.

    call :getMsgAt %~1 _msgstr || exit /B 1

    if not "%~2"=="" (
        call :cprint %~2 "%~3!_msgstr!"

    ) else echo !_msgstr!
exit /B 0

:getMsgAt
    ::  (1) - index at msg
    :: &(2) - result string
    :: !!1  - Error code 1 if &(1) is empty or not valid.

    if "%~1"=="" exit /B 1
    if %msgIdx% LSS %~1 exit /B 1
    if %~1 LSS 0 exit /B 1

    set %2=!msg[%~1]!
exit /B 0

:msgAt
    ::  (1) - index at msg
    ::  (2) - substring to check
    :: &(3) - result, 1 if found.

    set /a %3=0
    call :getMsgAt %~1 _msgstr || exit /B 0

    call :contains _msgstr "%~2" _n & set /a %3=!_n!
exit /B 0

:msgOrFailAt
    ::  (1) - index at msg
    ::  (2) - substring to check
    :: !!1  - Error code 1 if the message is not found at the specified index.

    call :msgAt %~1 "%~2" _n & if .!_n! NEQ .1 call :failTest & exit /B 1
exit /B 0

:checkFs
    ::  (1) - Path to directory that must be available or to file that must exist.
    ::  [2] - An optional path to a file that must exist in an accessible directory (1).
    :: !!1  - Error code 1 if the directory or file does not exist.

    if not exist "%~1" call :failTest & exit /B 1
    if not "%~2"=="" if not exist "%~1\%~2" call :failTest & exit /B 1
exit /B 0

:checkFsBase
    ::  (1) - Path to directory that must be available.
    ::  (2) - Path to the file that must exist.
    :: !!1  - Error code 1 if the directory or file does not exist.

    call :checkFs "%basePkgDir%%~1" "%~2"
exit /B

:checkFsNo
    ::  (1) - Path to the file or directory that must NOT exist.
    :: !!1  - Error code 1 if the specified path exists.

    if exist "%~1" call :failTest & exit /B 1
exit /B 0

:checkFsBaseNo
    ::  (1) - Path to the file or directory that must NOT exist.
    :: !!1  - Error code 1 if the specified path exists.

    call :checkFsNo "%basePkgDir%%~1"
exit /B

:unsetDir
    :: (1) - Path to directory.
    call :isStrNotEmptyOrWhitespaceOrFail "%~1" || exit /B 1
    rmdir /S/Q "%~1" 2>nul
exit /B 0

:unsetPackage
    :: (1) - Package directory.
    call :unsetDir "%basePkgDir%%~1"
exit /B 0

:unsetFile
    :: (1) - File name.
    call :isStrNotEmptyOrWhitespaceOrFail "%~1" || exit /B 1
    del /Q "%~1" 2>nul
exit /B 0

:unsetNupkg
    :: (1) - Nupkg file name.
    call :unsetFile "%~1"
exit /B 0

:checkFsNupkg
    ::  (1) - Nupkg file name.
    :: !!1  - Error code 1 if the input (1) does not exist.

    if not exist "%~1" call :failTest & exit /B 1
exit /B 0

:assertEqual
    ::  (1) - value 1
    ::  (2) - value 2
    :: !!1  - Error code 1 if not equal.

    if not "%~1"=="%~2" call :failTest & exit /B 1
exit /B 0

:assertNotEqual
    ::  (1) - value 1
    ::  (2) - value 2
    :: !!1  - Error code 1 if not equal.

    if "%~1"=="%~2" call :failTest & exit /B 1
exit /B 0

:findInStream
    ::  (1) - substring to check
    ::  [2] - Start index, 0 by default.
    :: &[3] - Return index or -1 if not found.
    :: !!1  - Error code 1 if failed.
    :: !!3  - Error code 3 if not found.

    if "%~2"=="" (set /a _sidx=0) else set /a _sidx=%~2
    if %_sidx% LSS 0 exit /B 1
    if %msgIdx% LSS %_sidx% exit /B 1

    for /L %%i in (%_sidx%,1,!msgIdx!) do (
        call :msgAt %%i "%~1" _n & if .!_n! EQU .1 (
            if not "%~3"=="" set /a %3=%%i
            exit /B 0
        )
    )
    if not "%~3"=="" set /a %3=-1
exit /B 3

:findInStreamOrFail
    ::  (1) - substring to check
    ::  [2] - Start index, 0 by default.
    :: &[3] - Return index or -1 if not found.
    :: !!1  - Error code 1 if failed.

    call :findInStream "%~1" %~2 %~3 || ( call :failTest & exit /B 1 )
exit /B 0

:failIfInStream
    ::  (1) - substring to check
    :: !!1  - Error code 1 if the input (1) was not found.

    call :findInStream "%~1" _n & if .!_n! EQU .1 ( call :failTest & exit /B 1 )
exit /B 0

:print
    :: (1) - Input string.

    :: NOTE: delayed `dmsg` because symbols like `)`, `(` ... requires protection after expansion. L-32
    set "dmsg=%~1" & echo [ %TIME% ] !dmsg!
exit /B 0

:cprint
    :: (1) - color attribute via :color call
    :: (2) - Input string.

    call :color %~1 "%~2" & echo.
exit /B 0

:color
    :: (1) - color attribute, {background} | {foreground}
            :: 0 = Black       8 = Gray
            :: 1 = Blue        9 = Light Blue
            :: 2 = Green       A = Light Green
            :: 3 = Aqua        B = Light Aqua
            :: 4 = Red         C = Light Red
            :: 5 = Purple      D = Light Purple
            :: 6 = Yellow      E = Light Yellow
            :: 7 = White       F = Bright White

    :: (2) - Input string.

    <nul set/P= >"%~2"
    findstr /a:%~1  "%~2" nul
    del "%~2">nul
exit /B 0

:isNotEmptyOrWhitespace
    :: &(1) - Input variable.
    :: !!1  - Error code 1 if &(1) is empty or contains only whitespace characters.

    set "_v=!%~1!"
    if not defined _v exit /B 1

    set _v=%_v: =%
    if not defined _v exit /B 1

    :: e.g. set a="" not set "a="
exit /B 0

:getSha1At
    ::  (1) - Stream index.
    :: &(2) - sha1 result.
    ::  [3] - Start position in input stream.
    set "_posSha1=%~3"
    if not defined _posSha1 set "_posSha1=0"
    set %2=!msg[%~1]:~%_posSha1%,40!
exit /B 0

:sha1At
    ::  (1) - Stream index.
    :: &(2) - sha1 result.
    call :getSha1At %1 _sha1 45
    set %2=!_sha1!
exit /B 0

:errargs
    echo.
    echo. Incorrect arguments. >&2
exit /B 1

:isNotEmptyOrWhitespaceOrFail
    :: &(1) - Input variable.
    :: !!1  - Error code 1 if &(1) is empty or contains only whitespace characters.
    call :isNotEmptyOrWhitespace %1 || (call :errargs & exit /B 1)
exit /B 0

:isStrNotEmptyOrWhitespaceOrFail
    :: (1) - Input string.
    :: !!1  - Error code 1 if (1) is empty or contains only whitespace characters.
    set "_wstrv=%~1"
    call :isNotEmptyOrWhitespaceOrFail _wstrv
exit /B

:cloneStreamAs
    :: &(1) - Destination.

    for /L %%i in (0,1,!msgIdx!) do set "%~1[%%i]=!msg[%%i]!"
exit /B

:eqOriginStreamWith
    :: &(1) - Current stream with stream from (1).
    :: &(2) - Return 1 if both streams are equal.

    for /L %%i in (0,1,!msgIdx!) do (
        if not "!%~1[%%i]!"=="!msg[%%i]!" ( set "%2=0" & exit /B 0 )
    )
    set "%2=1"
exit /B 0

:eqOriginStreamWithOrFail
    :: &(1) - Current stream with stream from (1).
    ::  [2] - Don't count in the total counter if 1.

    call :eqOriginStreamWith %~1 _r & if !_r! EQU 0 (
        call :failStreamsTest %~1 %~2 & exit /B 1
    )
exit /B 0

:disableAppVersion
    :: [1] - Optional postfix.
    set "appversion%~1=off"
exit /B 0

:shiftArgs
    ::   (1) - Start index from 1.
    ::   (2) - End index.
    ::  &(3) - Result.
    :: [4+] - %*

    set /a idx=0
    set /a start=%~1 + 2
    set /a end=%~2 + 1
    set "ret=" & set "rName=%3"
    :_shiftArg
        shift & set /a idx+=1
        if %idx% LSS %start% if "%~1" NEQ "" goto _shiftArg

        :: Y-60, hMSBuild; don't use `set "ret=!ret!%1 "` due to "..." and `&`, `|`, etc.
        set ret=!ret!%1

    :: NOTE: give preference to `defined` because of possible empty "" (a two double quotes together)
    set _argf=%1
    if defined _argf set ret=!ret!,& if %idx% LEQ %end% goto _shiftArg

    set "%rName%=!ret!"
exit /B 0

:initGlobalUnspecLabelMsg
    :: (G_UnspecLabelMsg) - Pattern when the system cannot find the label.
    if not defined G_UnspecLabelMsg call :getUnspecLabelMsg G_UnspecLabelMsg
exit /B 0

:getUnspecLabelMsg
    :: &(1) - Output message.

    for /F "tokens=*" %%i in ('%~dpnx0 1001 2^>^&1') do set _ul_msg=%%i
    set "%~1=%_ul_msg:NotRealLabel=%"
exit /B 0

:thisOrBase
    :: (1) - Process return code.
    :: (2) - Process stderr via file.
    :: (3) - Use a negative number (less than 0) to finish processing.

    set "_msgErr=" & set /p _msgErr=<%2

    if .%~1 NEQ .1 (
        if defined _msgErr echo !_msgErr! >&2
        exit /B 0
    )

    call :initGlobalUnspecLabelMsg
    call :contains _msgErr "%G_UnspecLabelMsg%" _n
    if .!_n! NEQ .1 (
        if defined _msgErr echo !_msgErr! >&2
        exit /B 0
    )

    if %~3 LEQ -1 if defined _msgErr echo !_msgErr! >&2
exit /B 1

:tryThisOrBase
    ::  (1) - Process return code.
    ::  (2) - Process stderr via file.
    :: [3-9]
    :: (G_AutoCleanThisOrBase)

    if .%~1 EQU .0 set "_currentLevelTOB=" & exit /B 0

    if !_currentLevelTOB! LSS 0 set "_currentLevelTOB="
    if not defined _currentLevelTOB set /a _currentLevelTOB=G_LevelChild*2-1

    set /a _currentLevelTOB-=1

    set /a rCode=%~1
    call :thisOrBase %~1 %2 0 || (

        :: TODO: (performance) reduce the number of I/O interruptions
        call :shiftArgs 3,99 shArgs %* & call :!shArgs! 2>%2
        set /a rCode=!ERRORLEVEL!
        call :thisOrBase !rCode! %2 !_currentLevelTOB!
    )
    if defined G_AutoCleanThisOrBase call :cleanForThisOrBase %2
exit /B !rCode!

:cleanForThisOrBase
    :: [1] - Optional specific .err file.

    set _cltf=%2
    if not defined _cltf set _cltf=%~nx0.err
    del /Q/F %_cltf% 2>nul
exit /B 0
