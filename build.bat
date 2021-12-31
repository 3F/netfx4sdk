@echo off

call .tools\hMSBuild -GetNuTool /p:wpath="%cd%" /p:ngconfig=".tools\packages.config" /nologo /v:m /m:7
call packages\vsSolutionBuildEvent\cim.cmd /v:m /m:7 /p:Configuration="Release" || goto err

exit /B 0

:err
echo. Build failed. 1>&2
exit /B 1