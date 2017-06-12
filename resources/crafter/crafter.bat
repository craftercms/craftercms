@echo off
SET CRAFTER_ROOT=%~dp0
for %%i in ("%~dp0..") do set "CRAFTER_HOME=%%~fi"
SET DEPLOYER_HOME=%CRAFTER_ROOT%\crafter-deployer

SET CATALINA_HOME=%CRAFTER_ROOT%\apache-tomcat
SET CATALINA_PID=%CATALINA_HOME%\tomcat.pid
SET CATALINA_LOGS_DIR=%CRAFTER_HOME%\logs\tomcat
SET CATALINA_OUT=%CATALINA_LOGS_DIR%\catalina.out
SET CATALINA_OPTS="-Dcatalina.logs=%CATALINA_LOGS_DIR% -server -Xss1024K -Xms1G -Xmx4G"
SET SOLR_PORT=@SOLR_PORT@
SET SOLR_INDEXES_DIR=%CRAFTER_HOME%\data\indexes
SET SOLR_LOGS_DIR=%CRAFTER_ROOT%\logs\solr
SET SOLR_JAVA_OPTS="-server -Xss1024K -Xmx1G"
SET DEPLOYER_PORT=@DEPLOYER_PORT@
SET DEPLOYER_DATA_DIR=%CRAFTER_HOME%\data\deployer
SET DEPLOYER_TARGET_DIR=%DEPLOYER_DATA_DIR%\targets
SET DEPLOYER_PRODCESSED_COMMITS_DIR=%DEPLOYER_DATA_DIR%\processed-commits
SET DEPLOYER_LOGS_DIR=%CRAFTER_HOME%\logs\deployer
SET DEPLOYER_DEPLOYMENTS_DIR=%DEPLOYER_DATA_DIR%\@DEPLOYMENT_DIR@
SET DEPLOYER_SDOUT=%DEPLOYER_LOGS_DIR%\crafter-deployer.out
SET DEPLOYER_JAVA_OPTS="-server -Xss1024K -Xmx1G"
SET MONGODB_PORT=@MONGODB_PORT@
SET MONGODB_HOME="%CRAFTER_HOME%\mongodb"
SET MONGODB_PID="%CRAFTER_HOME%\data\mongodb\mongod.lock"
SET MONGODB_DATA_DIR="%CRAFTER_HOME%\data\mongodb"
SET MONGODB_LOGS_DIR="%CRAFTER_HOME%\logs\mongodb"
SET TOMCAT_HTTP_PORT=@TOMCAT_HTTP_PORT@
SET MYSQL_DATA="%CRAFTER_HOME%\data\db"
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
 mkdir %CRAFTER_ROOT%mongodb
 cd %CRAFTER_ROOT%mongodb
 java -jar %CRAFTER_ROOT%craftercms-utils.jar download mongodb
 msiexec.exe /norestart /passive /i  mongodb.msi INSTALLLOCATION="%CRAFTER_ROOT%\mongodb" ADDLOCAL="all"
 cd %CRAFTER_ROOT%
goto :init

:init
set mongoDir=%CRAFTER_ROOT%mongodb
IF NOT EXIST "%mongoDir%" goto installMongo
IF NOT EXIST "%MONGODB_DATA_DIR%" mkdir %MONGODB_DATA_DIR%

start %DEPLOYER_HOME%\%DEPLOYER_STARTUP%
IF NOT EXIST "%MONGODB_DATA_DIR%" mkdir %MONGODB_DATA_DIR%
IF NOT EXIST "%MONGODB_LOGS_DIR%" mkdir %MONGODB_LOGS_DIR%
start %mongoDir%\bin\mongod --dbpath=%MONGODB_DATA_DIR% --directoryperdb --journal --logpath=%MONGODB_LOGS_DIR%\mongod.log --port 27020
IF NOT EXIST "%CRAFTER_HOME%\data\indexes" mkdir %CRAFTER_HOME%\data\indexes
start %CRAFTER_ROOT%solr\bin\solr start -f -p 8694 -Dcrafter.solr.index=%CRAFTER_HOME%\data\indexes
call %CATALINA_HOME%\bin\startup.bat
goto cleanOnExit


:cleanOnExit
exit /b 0
