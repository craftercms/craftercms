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

REM Script to create the Solr core & Deployer target for a delivery environment.

SET DELIVERY_HOME=%~dp0

call %DELIVERY_HOME%\crafter-setenv.bat

REM Execute Groovy script
%DELIVERY_HOME%\groovy\bin\groovy -cp %DELIVERY_HOME% -Dgrape.root=%DELIVERY_HOME% %DELIVERY_HOME%\init-site.groovy %*
