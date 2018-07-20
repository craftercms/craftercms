@echo off
REM Script to upgrade a target Crafter installation based on this bundle

SET UPGRADE_HOME=%~dp0
SET CRAFTER_HOME=%UPGRADE_HOME%\..
SET CRAFTER_ROOT=%CRAFTER_HOME%\..
SET ENVIRONMENT_NAME=@ENV@

call %CRAFTER_HOME%\crafter-setenv.bat

REM Execute Groovy script
%CRAFTER_HOME%\groovy\bin\groovy -cp %CRAFTER_HOME% -Dgrape.root=%CRAFTER_HOME% %UPGRADE_HOME%\upgrade-target.groovy %*
