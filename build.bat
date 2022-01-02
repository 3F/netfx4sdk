@echo off

call .tools\hMSBuild -GetNuTool /p:wpath="%cd%" /p:ngconfig=".tools\packages.config" /nologo /v:m /m:7 & (
    if [%~1]==[#] exit /B 0
)
call packages\vsSolutionBuildEvent\cim.cmd /v:m /m:7 /p:Configuration="Release" || (
    echo. Failed 1>&2
    exit /B 1
)
exit /B 0