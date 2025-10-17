::! Copyright (c) 2021  Denis Kuzmin <x-3F@outlook.com> github/3F
::! Copyright (c) netfx4sdk contributors https://github.com/3F/netfx4sdk/graphs/contributors
::! Licensed under the MIT License (MIT).
::! See accompanying License.txt file or visit https://github.com/3F/netfx4sdk
@echo off

if not exist netfx4sdk.cmd exit /B1
set /p _version=<"%~dp0.version"
if not defined _version exit /B1

set "tpldir=%temp%\netfx4sdk.%~nx0.%random%%random%"
set "tplnupkg=%tpldir%\netfx4sdk.%_version%.nupkg"

set "dstdir=%~dp0netfx4sdk"
set srv="%dstdir%\%_version%"

if exist %srv% (
    del /F/Q %srv% >nul
    rmdir /S/Q "%dstdir%" 2>nul>nul
)

call "%~dp0\hMSBuild" -GetNuTool /t:pack /p:ngin="%~dp0/";ngout="%tpldir%/" >nul
if not exist "%tplnupkg%" exit /B2

mkdir "%dstdir%" 2>nul>nul
copy /Y/B/V "%tplnupkg%" %srv% >nul

del /F/Q "%tplnupkg%" >nul
rmdir /Q "%tpldir%" >nul

echo.
echo Ready... use it like:
echo    hMSBuild -GetNuTool *netfx4sdk/%_version% /p:ngserver=.\
echo.
echo Built-in GetNuTool. Syntax and relevant documentation:
echo    hMSBuild -GetNuTool -help
echo    hMSBuild -GetNuTool ~/p:use=documentation