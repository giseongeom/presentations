@echo off

for %%i in ("%JAVA_HOME%\..") do set "parent=%%~fi"
%parent%\nodejs\markdown-to-slides -s style.css -t -d -w -o ec2-custom-ami-with-packer.html ec2-custom-ami-with-packer.md

