@echo off
SET CRAFTER_BIN_FOLDER=%~dp0
for %%i in ("%~dp0..") do set CRAFTER_HOME=%%~fi\
SET DEPLOYER_HOME=%CRAFTER_BIN_FOLDER%\crafter-deployer

SET CATALINA_HOME=%CRAFTER_BIN_FOLDER%apache-tomcat
SET CATALINA_PID=%CATALINA_HOME%\tomcat.pid
SET CATALINA_LOGS_DIR=%CRAFTER_HOME%logs\tomcat
SET CATALINA_OUT=%CATALINA_LOGS_DIR%catalina.out
SET CATALINA_OPTS=-Dcatalina.logs=%CATALINA_LOGS_DIR% -server -Xss1024K -Xms1G -Xmx4G
SET SOLR_PORT=@SOLR_PORT@
SET SOLR_DEBUG_PORT=@SOLR_PORT_D@
SET SOLR_INDEXES_DIR=%CRAFTER_HOME%data\indexes
SET SOLR_LOGS_DIR=%CRAFTER_HOME%logs\solr
SET SOLR_OPTS=-server -Xss1024K -Xmx1G
SET DEPLOYER_PORT=@DEPLOYER_PORT@
SET DEPLOYER_DEBUG_PORT=@DEPLOYER_D_PORT@
SET DEPLOYER_DATA_DIR=%CRAFTER_HOME%data\deployer
SET DEPLOYER_TARGET_DIR=%DEPLOYER_DATA_DIR%\targets
SET DEPLOYER_PRODCESSED_COMMITS_DIR=%DEPLOYER_DATA_DIR%\processed-commits
SET DEPLOYER_LOGS_DIR=%CRAFTER_HOME%logs\deployer
SET DEPLOYER_DEPLOYMENTS_DIR=%DEPLOYER_DATA_DIR%\data\repos\sites
SET DEPLOYER_SDOUT=%DEPLOYER_LOGS_DIR%\crafter-deployer.out
SET DEPLOYER_JAVA_OPTS=-server -Xss1024K -Xmx1G
SET MONGODB_PORT=@MONGODB_PORT@
SET MONGODB_HOME=%CRAFTER_HOME%mongodb
SET MONGODB_PID=%CRAFTER_HOME%data\mongodb\mongod.lock
SET MONGODB_DATA_DIR=%CRAFTER_HOME%data\mongodb
SET MONGODB_LOGS_DIR=%CRAFTER_HOME%logs\mongodb
SET TOMCAT_HTTP_PORT=@TOMCAT_HTTP_PORT@
SET MYSQL_DATA=%CRAFTER_HOME%data\db
SET MYSQL_PID_FILE_NAME=
SET DEPLOYER_WIN_TITLE=Crafter Deployer
SET DEPLOYER_STARTUP=startup.bat
SET DEPLOYER_SHUTDOWN=shutdown.bat
SET DEPLOYER_DEBUG=debug.bat

IF /i "%1%"=="start" goto init
IF /i "%1%"=="-s" goto init

IF /i "%1%"=="stop" goto skill
IF /i "%1%"=="-k" goto skill

IF /i "%1%"=="debug" goto debug
IF /i "%1%"=="-d" goto debug

goto shelp
exit 0;

:shelp
echo "Crafter Bat script"
echo "-s start, Start crafter deployer"
echo "-k stop, Stop crafter deployer"
echo "-d debug, Impli  eds start, Start crafter deployer in debug mode"
exit /b 0

:installMongo
 mkdir %CRAFTER_BIN_FOLDER%mongodb
 cd %CRAFTER_BIN_FOLDER%mongodb
 java -jar %CRAFTER_BIN_FOLDER%craftercms-utils.jar download mongodb
 msiexec.exe /norestart /passive /i  mongodb.msi INSTALLLOCATION="%CRAFTER_BIN_FOLDER%\mongodb" ADDLOCAL="all"
 cd %CRAFTER_BIN_FOLDER%
goto :init

:init
cd ..
set mongoDir=%CRAFTER_BIN_FOLDER%mongodb
IF NOT EXIST "%mongoDir%" goto installMongo
IF NOT EXIST "%MONGODB_DATA_DIR%" mkdir %MONGODB_DATA_DIR%

start %DEPLOYER_HOME%\%DEPLOYER_STARTUP%
IF NOT EXIST "%MONGODB_DATA_DIR%" mkdir %MONGODB_DATA_DIR%
IF NOT EXIST "%MONGODB_LOGS_DIR%" mkdir %MONGODB_LOGS_DIR%
start %mongoDir%\bin\mongod --dbpath=%MONGODB_DATA_DIR% --directoryperdb --journal --logpath=%MONGODB_LOGS_DIR%\mongod.log --port %MONGODB_PORT%
IF NOT EXIST "%CRAFTER_HOME%\data\indexes" mkdir %CRAFTER_HOME%\data\indexes
start %CRAFTER_BIN_FOLDER%solr\bin\solr start -f -p %SOLR_PORT% -Dcrafter.solr.index=%CRAFTER_HOME%\data\indexes
call %CATALINA_HOME%\bin\startup.bat
goto cleanOnExit

:debug
set mongoDir=%CRAFTER_BIN_FOLDER%mongodb
IF NOT EXIST "%mongoDir%" goto installMongo
IF NOT EXIST "%MONGODB_DATA_DIR%" mkdir %MONGODB_DATA_DIR%
start %DEPLOYER_HOME%\%DEPLOYER_DEBUG%
IF NOT EXIST "%MONGODB_DATA_DIR%" mkdir %MONGODB_DATA_DIR%
IF NOT EXIST "%MONGODB_LOGS_DIR%" mkdir %MONGODB_LOGS_DIR%
start %mongoDir%\bin\mongod --dbpath=%MONGODB_DATA_DIR% --directoryperdb --journal --logpath=%MONGODB_LOGS_DIR%\mongod.log --port %MONGODB_PORT%
IF NOT EXIST "%CRAFTER_HOME%\data\indexes" mkdir %CRAFTER_HOME%\data\indexes
start %CRAFTER_BIN_FOLDER%solr\bin\solr start -f -p %SOLR_PORT% -Dcrafter.solr.index=%CRAFTER_HOME%\data\indexes -a "-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=%SOLR_DEBUG_PORT%
call %CATALINA_HOME%\bin\catalina.bat jpda start
goto cleanOnExit

:skill
start %CRAFTER_BIN_FOLDER%solr\bin\solr stop -f -p %SOLR_PORT%
taskkill /IM mongod.exe
call %CATALINA_HOME%\bin\shutdown.bat
start %DEPLOYER_HOME%\%DEPLOYER_SHUTDOWN%
goto cleanOnExit


:cleanOnExit
cd %CRAFTER_BIN_FOLDER%
exit /b 0
