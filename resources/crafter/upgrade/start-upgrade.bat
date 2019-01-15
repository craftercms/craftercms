@echo off
REM Script download new version of the Crafter installation bundle

SET UPGRADE_HOME=%~dp0
SET CRAFTER_BIN_DIR=%UPGRADE_HOME%\..
SET CRAFTER_HOME=%CRAFTER_BIN_DIR%\..
SET UPGRADE_TMP_DIR=%CRAFTER_HOME%\temp\upgrade
SET ENVIRONMENT_NAME=@ENV@
SET DOWNLOADS_BASE_URL=https://downloads.craftercms.org

call %CRAFTER_BIN_DIR%\crafter-setenv.bat

REM Execute Groovy script
%CRAFTER_BIN_DIR%\groovy\bin\groovy -cp %CRAFTER_BIN_DIR% -Dgrape.root=%CRAFTER_BIN_DIR% %UPGRADE_HOME%\start-upgrade.groovy %*
