@echo off

REM Copyright (C) 2007-2019 Crafter Software Corporation. All Rights Reserved.
REM
REM This program is free software: you can redistribute it and/or modify
REM it under the terms of the GNU General Public License as published by
REM the Free Software Foundation, either version 3 of the License, or
REM (at your option) any later version.
REM
REM This program is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
REM GNU General Public License for more details.
REM
REM You should have received a copy of the GNU General Public License
REM along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
