@echo off
SETLOCAL

for %%i in ("%JAVA_HOME%\..") do set "parent=%%~fi"
set WORKING_DIR=%~dp0
cd /d %WORKING_DIR%
%parent%\nodejs\markdown-to-slides -s style.css -t -d -w -o ec2-custom-ami-with-packer.html ec2-custom-ami-with-packer.md

ENDLOCAL