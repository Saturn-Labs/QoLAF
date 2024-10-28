@echo off
setlocal ENABLEDELAYEDEXPANSION

for /f "tokens=*" %%i in ('git rev-parse HEAD') do (
    set "commit_sha=%%i"
)

set "commit_sha=!commit_sha:~0,7!"

set project=%cd%
echo Incrementing build number...
set /p build=<data/build.txt
set /a build=build+1
set /p template_string=<data/metadata/BuildData.as.template
set builddata_string=%template_string:[build_number]=!build!%
set builddata_string=%builddata_string:[commit_sha]=!commit_sha!%

echo %build% > data/build.txt
echo %builddata_string% > src/metadata/BuildData.as
echo Current build number: %build%
echo Current commit: %commit_sha%
