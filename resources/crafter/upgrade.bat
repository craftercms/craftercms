@echo off
REM Script to upgrade the Crafter installation

SET CRAFTER_HOME=%~dp0
SET CRAFTER_ROOT=%CRAFTER_HOME%\..

call %CRAFTER_HOME%\crafter-setenv.bat

REM Execute Groovy script
%CRAFTER_HOME%\groovy\bin\groovy -Dgrape.root=%CRAFTER_HOME% %CRAFTER_HOME%\init-site.groovy %*
