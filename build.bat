::! Copyright (c) 2021  Denis Kuzmin <x-3F@outlook.com> github/3F
::! Copyright (c) netfx4sdk contributors https://github.com/3F/netfx4sdk/graphs/contributors
::! Licensed under the MIT License (MIT).
::! See accompanying License.txt file or visit https://github.com/3F/netfx4sdk

@echo off

call hMSBuild -GetNuTool vsSolutionBuildEvent & (
    if [%~1]==[#] exit /B 0
)

set "reltype=%~1" & if not defined reltype set reltype=Release
call packages\vsSolutionBuildEvent\cim.cmd ~x ~c %reltype% || goto err

setlocal enableDelayedExpansion
    cd tests
    call a initAppVersion Nfx
    call a execute "..\bin\Release\raw\netfx4sdk -h" & call a msgOrFailAt 1 "netfx4sdk %appversionNfx%" || goto err
    call a printMsgAt 1 3F "Completed as a "
endlocal
exit /B 0

:err
    echo Failed build>&2
exit /B 1