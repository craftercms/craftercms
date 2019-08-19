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

REM Locations variables
IF NOT DEFINED CRAFTER_LOGS_DIR SET "CRAFTER_LOGS_DIR=%CRAFTER_HOME%\logs"
IF NOT DEFINED CRAFTER_DATA_DIR SET "CRAFTER_DATA_DIR=%CRAFTER_HOME%\data"

SET "DEPLOYER_HOME=%CRAFTER_BIN_DIR%\crafter-deployer"
SET "CATALINA_HOME=%CRAFTER_BIN_DIR%\apache-tomcat"
SET "CATALINA_PID=%CATALINA_HOME%\tomcat.pid"
SET "CATALINA_LOGS_DIR=%CRAFTER_LOGS_DIR%\tomcat"
SET "CATALINA_OUT=%CATALINA_LOGS_DIR%\catalina.out"
SET "CATALINA_TMPDIR=%CRAFTER_HOME%\temp\tomcat"
SET "CRAFTER_APPLICATION_LOGS=%CATALINA_LOGS_DIR%"
SET CATALINA_OPTS=-Dcrafter.home="%CRAFTER_HOME%" -Dcrafter.bin.dir="%CRAFTER_BIN_DIR%" -Dcrafter.data.dir="%CRAFTER_DATA_DIR%" -Dcrafter.logs.dir="%CRAFTER_LOGS_DIR%" -Dcatalina.logs="%CATALINA_LOGS_DIR%" -Djava.net.preferIPv4Stack=true -server -Xss1024K -Xms1G -Xmx4G -Dapplication.logs="%CRAFTER_APPLICATION_LOGS%"
SET SOLR_PORT=@SOLR_PORT@
SET SOLR_DEBUG_PORT=@SOLR_PORT_D@
SET "SOLR_INDEXES_DIR=%CRAFTER_DATA_DIR%\indexes"
SET SOLR_LOGS_DIR="%CRAFTER_LOGS_DIR%\solr"
SET SOLR_OPTS=-server -Xss1024K -Xmx1G
SET "SOLR_HOME=%CRAFTER_BIN_DIR%\solr\server\solr"
SET DEPLOYER_PORT=@DEPLOYER_PORT@
SET DEPLOYER_DEBUG_PORT=@DEPLOYER_D_PORT@
SET "DEPLOYER_DATA_DIR=%CRAFTER_DATA_DIR%\deployer"
SET "DEPLOYER_TARGET_DIR=%DEPLOYER_DATA_DIR%\targets"
SET "DEPLOYER_PRODCESSED_COMMITS_DIR=%DEPLOYER_DATA_DIR%\processed-commits"
SET "DEPLOYER_LOGS_DIR=%CRAFTER_LOGS_DIR%\deployer"
SET "DEPLOYER_DEPLOYMENTS_DIR=%CRAFTER_DATA_DIR%\repos\sites"
SET "DEPLOYER_SDOUT=%DEPLOYER_LOGS_DIR%\crafter-deployer.out"
SET DEPLOYER_JAVA_OPTS=-server -Xss1024K -Xmx1G
SET MONGODB_PORT=@MONGODB_PORT@
SET "MONGODB_HOME=%CRAFTER_HOME%\mongodb"
SET "MONGODB_PID=%CRAFTER_DATA_DIR%\mongodb\mongod.lock"
SET "MONGODB_DATA_DIR=%CRAFTER_DATA_DIR%\mongodb"
SET "MONGODB_LOGS_DIR=%CRAFTER_LOGS_DIR%\mongodb"
SET TOMCAT_HTTP_PORT=@TOMCAT_HTTP_PORT@
SET "MYSQL_DATA=%CRAFTER_DATA_DIR%\db"
SET MYSQL_PID_FILE_NAME=
SET MARIADB_PORT=@MARIADB_PORT@
SET DEPLOYER_WIN_TITLE="Crafter Deployer @ENV@"
SET DEPLOYER_STARTUP=startup.bat
SET DEPLOYER_SHUTDOWN=shutdown.bat
SET DEPLOYER_DEBUG=debug.bat
SET "PROFILE_DEPLOY_WAR_PATH=%CATALINA_HOME%/webapps/crafter-profile"
SET "PROFILE_WAR_PATH=%CATALINA_HOME%/webapps/crafter-profile.war"
SET FORCE_MONGO=%1
@rem in Seconds
SET TIME_BEFORE_KILL=20
SET GIT_CONFIG_NOSYSTEM=true
