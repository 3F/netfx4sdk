::! Copyright (c) 2021  Denis Kuzmin <x-3F@outlook.com> github/3F
::! Copyright (c) netfx4sdk contributors https://github.com/3F/netfx4sdk/graphs/contributors
::! Licensed under the MIT License (MIT).
::! See accompanying License.txt file or visit https://github.com/3F/netfx4sdk
@echo off

:: Arguments: https://github.com/3F/GetNuTool?tab=readme-ov-file#touch--install--run
:: 1 tmode "path to the working directory" "path to the package"
if "%~1" LSS "1" echo Version "%~1" is not supported. 2>&1 & exit /B1

set "tmode=%~2"
set "wdir=%~3"
set "pdir=%~4"

if not exist "%pdir%\netfx4sdk.cmd.sha1" exit /B1
set /p _version=<"%pdir%\.version"

if not defined use (

    call :xcopy "%pdir%\netfx4sdk.cmd"
    call :copy "%pdir%\hMSBuild.bat"
    call :doc %tmode%

    if "%tmode%"=="install" call :createValidationWrapper
    if "%tmode%"=="run" call :createValidationWrapper

) else if "%use%"=="doc" (
    call :doc %tmode% docmode

) else if "%use%"=="documentation" (
    call :doc %tmode% docmode

) else if "%use%"=="-" (
    exit /B 0

) else (
    echo "%use%" is not supported 2>&1 & exit /B1
)

exit /B 0

:doc
    :: (1) tMode
    if not exist "%pdir%\doc\netfx4sdk.%_version%.html" exit /B 1

    if "%~1"=="install" (
        call :xcopy "%pdir%\doc\netfx4sdk.%_version%.html"

    ) else if "%~1"=="run" (
        "%pdir%\doc\netfx4sdk.%_version%.html"

    ) else if "%~1"=="touch" if "%~2"=="docmode" (
        call :xcopy "%pdir%\doc\netfx4sdk.%_version%.html"
        "%wdir%\netfx4sdk.%_version%.html"
    )
exit /B 0

:xcopy
    :: xcopy: including the readonly (/R) attr
    :: (1) input file
    :: [2] optional new name
    xcopy %1 "%wdir%\%~2" /Y/R/V/I/Q 2>nul>nul || call :copy %1
exit /B 0

:copy
    :: copy: fail on the readonly attr
    :: (1) input file
    :: [2] optional new name
    copy /Y/V %1 "%wdir%\%~2" 2>nul>nul || goto :error
exit /B 0

:createValidationWrapper
    set _vwrapper="%wdir%\validate.netfx4sdk.cmd"
    echo @echo off>%_vwrapper%
    echo pushd "%pdir%">>%_vwrapper%
    echo     call validate.netfx4sdk.cmd "%wdir%">>%_vwrapper%
    echo popd>>%_vwrapper%
    echo pause>>%_vwrapper%
exit /B 0

:error
exit /B 1