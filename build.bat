@echo off

call .tools\hMSBuild ~x -GetNuTool & (
    if [%~1]==[#] exit /B 0
)
call packages\vsSolutionBuildEvent\cim.cmd /v:m /m:7 /p:Configuration="Release" || (
    echo Failed>&2
    exit /B 1
)
exit /B 0