@echo off
REM Script to upgrade a target Crafter installation based on this bundle

SET UPGRADE_HOME=%~dp0
SET CRAFTER_BIN_DIR=%UPGRADE_HOME%\..
SET CRAFTER_HOME=%CRAFTER_BIN_DIR%\..
SET ENVIRONMENT_NAME=@ENV@

call %CRAFTER_BIN_DIR%\crafter-setenv.bat

REM Execute Groovy script
%CRAFTER_BIN_DIR%\groovy\bin\groovy -cp %CRAFTER_BIN_DIR% -Dgrape.root=%CRAFTER_BIN_DIR% %UPGRADE_HOME%\upgrade-target.groovy %*
