@echo off
REM Script to upgrade the Crafter installation

SET UPGRADE_HOME=%~dp0
SET CRAFTER_HOME=%UPGRADE_HOME%\..
SET CRAFTER_ROOT=%CRAFTER_HOME%\..
SET UPGRADE_TMP_DIR=%CRAFTER_ROOT%\upgrade

call %CRAFTER_HOME%\crafter-setenv.bat

REM Execute Groovy script
%CRAFTER_HOME%\groovy\bin\groovy -cp %CRAFTER_HOME% -Dgrape.root=%CRAFTER_HOME% %UPGRADE_HOME%\setup.groovy
%UPGRADE_TMP_DIR%\groovy\bin\groovy -cp %UPGRADE_TMP_DIR% -Dgrape.root=%UPGRADE_TMP_DIR% %UPGRADE_TMP_DIR%\upgrade.groovy %*
%CRAFTER_HOME%\groovy\bin\groovy -cp %CRAFTER_HOME% -Dgrape.root=%CRAFTER_HOME% %UPGRADE_HOME%\cleanup.groovy
