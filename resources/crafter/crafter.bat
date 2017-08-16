@echo off
SET CRAFTER_BIN_FOLDER=%~dp0
for %%i in ("%~dp0..") do set CRAFTER_HOME=%%~fi\
SET DEPLOYER_HOME=%CRAFTER_BIN_FOLDER%\crafter-deployer

SET CATALINA_HOME=%CRAFTER_BIN_FOLDER%apache-tomcat
SET CATALINA_PID=%CATALINA_HOME%\tomcat.pid
SET CATALINA_LOGS_DIR=%CRAFTER_HOME%logs\tomcat
SET CATALINA_OUT=%CATALINA_LOGS_DIR%catalina.out
SET CRAFTER_APPLICATION_LOGS=%CATALINA_LOGS_DIR%
SET CATALINA_OPTS=-Dcatalina.logs=%CATALINA_LOGS_DIR% -server -Xss1024K -Xms1G -Xmx4G -Dapplication.logs=%CRAFTER_APPLICATION_LOGS%
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

IF /i "%1%"=="backup" goto backup
IF /i "%1%"=="restore" goto restore

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

:backup
SET TARGET_NAME=%2
IF NOT DEFINED TARGET_NAME (
  IF EXIST "%MYSQL_DATA%" (
    SET TARGET_NAME=crafter-authoring-backup
  ) ELSE (
    SET TARGET_NAME=crafter-delivery-backup
  )
)
FOR /F "tokens=2-4 delims=/ " %%a IN ("%DATE%") DO (SET CDATE=%%c-%%a-%%b)
FOR /F "tokens=1-3 delims=:. " %%a IN ("%TIME%") DO (SET CTIME=%%a-%%b-%%c)
SET TARGET_FILE="%CRAFTER_HOME%%TARGET_NAME%-%CDATE%-%CTIME%.zip"
SET TEMP_FOLDER=%CRAFTER_HOME%backup

echo "Starting backup into %TARGET_FILE%"
md %TEMP_FOLDER%
del /Q %TARGET_FILE%

REM MySQL Dump
IF EXIST "%MYSQL_DATA%" (
	echo "Adding MySQL dump"
	start cmd /c %CRAFTER_BIN_FOLDER%dbms\bin\mysqldump.exe --databases crafter --port=@MARIADB_PORT@ --protocol=tcp --user=root ^> %TEMP_FOLDER%\crafter.sql 
)

REM MongoDB Dump
IF EXIST %MONGODB_DATA_DIR% (
  echo "Adding mongodb dump"
  %CRAFTER_BIN_FOLDER%\mongodb\bin\mongodump --port %MONGODB_PORT% --out "%TEMP_FOLDER%\mongodb" --quiet
  cd "%TEMP_FOLDER%\mongodb"
  java -jar %CRAFTER_BIN_FOLDER%\craftercms-utils.jar zip . "%TEMP_FOLDER%\mongodb.zip"
  cd %CRAFTER_BIN_FOLDER%
  rd /Q /S %TEMP_FOLDER%\mongodb
)

REM ZIP git repos
echo "Adding git repos"
cd "%CRAFTER_HOME%\data\repos"
java -jar %CRAFTER_BIN_FOLDER%\craftercms-utils.jar zip . "%TEMP_FOLDER%\repos.zip"
REM ZIP solr indexes
echo "Adding solr indexes"
cd "%SOLR_INDEXES_DIR%"
java -jar %CRAFTER_BIN_FOLDER%\craftercms-utils.jar zip . "%TEMP_FOLDER%\indexes.zip"
REM ZIP deployer data
echo "Adding deployer data"
cd "%DEPLOYER_DATA_DIR%"
java -jar %CRAFTER_BIN_FOLDER%\craftercms-utils.jar zip . "%TEMP_FOLDER%\deployer.zip"
REM ZIP everything (without compression)
cd "%TEMP_FOLDER%"
java -jar %CRAFTER_BIN_FOLDER%\craftercms-utils.jar zip . "%TARGET_FILE%" true

rd /Q /S "%TEMP_FOLDER%"
echo "Backup completed"
goto cleanOnExit

:restore
SET SOURCE_FILE=%2
IF NOT EXIST "%SOURCE_FILE%" (
  echo "The file does not exist"
  exit /b 1
)

SET TEMP_FOLDER="%CRAFTER_HOME%backup"
echo "Starting restore from %SOURCE_FILE%"
md "%TEMP_FOLDER%"

REM UNZIP everything
java -jar %CRAFTER_BIN_FOLDER%craftercms-utils.jar unzip "%SOURCE_FILE%" "%TEMP_FOLDER%"

REM MongoDB Dump
IF NOT EXIST "%TEMP_FOLDER%\mongodb.zip" ( goto skipMongo )
echo "Checking folder %MONGODB_DATA_DIR%"
IF EXIST "%MONGODB_DATA_DIR%" (
  SET /P DO_IT= Folder already exist, do you want to overwrite it? yes/no 
  IF /i NOT "%DO_IT%"=="yes" ( goto skipMongo )
)
echo "Restoring MongoDB"
IF NOT EXIST "%MONGODB_DATA_DIR%" mkdir %MONGODB_DATA_DIR%
IF NOT EXIST "%MONGODB_LOGS_DIR%" mkdir %MONGODB_LOGS_DIR%
start "MongoDB" %CRAFTER_BIN_FOLDER%mongodb\bin\mongod --dbpath=%MONGODB_DATA_DIR% --directoryperdb --journal --logpath=%MONGODB_LOGS_DIR%\mongod.log --port %MONGODB_PORT%
java -jar %CRAFTER_BIN_FOLDER%craftercms-utils.jar unzip "%TEMP_FOLDER%\mongodb.zip" "%TEMP_FOLDER%\mongodb"
start "MongoDB Restore" /W %CRAFTER_BIN_FOLDER%mongodb\bin\mongorestore --port %MONGODB_PORT% "%TEMP_FOLDER%\mongodb"
taskkill /IM mongod.exe
:skipMongo

REM UNZIP git repos
IF NOT EXIST "%TEMP_FOLDER%\repos.zip" ( goto skipRepos )
echo "Checking folder %CRAFTER_HOME%data\repos"
IF EXIST "%CRAFTER_HOME%data\repos" (
  SET /P DO_IT= Folder already exist, do you want to overwrite it? yes/no 
  IF /i NOT "%DO_IT%"=="yes" ( goto skipRepos )
)
echo "Restoring git repos"
rd /Q /S "%CRAFTER_HOME%\data\repos"
java -jar %CRAFTER_BIN_FOLDER%craftercms-utils.jar unzip "%TEMP_FOLDER%\repos.zip" "%CRAFTER_HOME%data/repos"
:skipRepos

REM UNZIP solr indexes
IF NOT EXIST "%TEMP_FOLDER%\indexes.zip" ( goto skipIndexes )
echo "Checking folder %SOLR_INDEXES_DIR%"
IF EXIST "%SOLR_INDEXES_DIR%" (
  SET /P DO_IT= Folder already exist, do you want to overwrite it? yes/no 
  IF /i NOT "%DO_IT%"=="yes" ( goto skipIndexes )
)
echo "Restoring solr indexes"
rd /Q /S "%SOLR_INDEXES_DIR%"
java -jar %CRAFTER_BIN_FOLDER%craftercms-utils.jar unzip "%TEMP_FOLDER%\indexes.zip" "%SOLR_INDEXES_DIR%"
:skipIndexes
    
REM UNZIP deployer data
IF NOT EXIST "%TEMP_FOLDER%\deployer.zip" ( goto skipDeployer )
echo "Checking folder %DEPLOYER_DATA_DIR%"
IF EXIST "%DEPLOYER_DATA_DIR%" (
  SET /P DO_IT= Folder already exist, do you want to overwrite it? yes/no 
  IF /i NOT "%DO_IT%"=="yes" ( goto skipDeployer )
)
echo "Restoring deployer data"
rd /Q /S "%DEPLOYER_DATA_DIR%"
java -jar %CRAFTER_BIN_FOLDER%craftercms-utils.jar unzip "%TEMP_FOLDER%\deployer.zip" "%DEPLOYER_DATA_DIR%"
:skipDeployer

REM If it is an authoring env then sync the repos
IF NOT EXIST "%TEMP_FOLDER%\crafter.sql" ( goto skipAuth )
echo "Restoring Authoring Data"
md "%MYSQL_DATA%"
REM Start DB
start "MySQL Server" %CRAFTER_BIN_FOLDER%\dbms\bin\mysqld.exe --no-defaults --console --skip-grant-tables --max_allowed_packet=64M --basedir=dbms --datadir="%MYSQL_DATA%" --port=@MARIADB_PORT@ --innodb_large_prefix=TRUE --innodb_file_format=BARRACUDA --innodb_file_format_max=BARRACUDA --innodb_file_per_table=TRUE
timeout /nobreak 5
REM Import
start "MySQL Import" /W %CRAFTER_BIN_FOLDER%\dbms\bin\mysql.exe --user=root --port=@MARIADB_PORT@ -e "source %TEMP_FOLDER%\crafter.sql"
REM Stop DB
taskkill /IM mysqld.exe
REM start tomcat
call :init
echo "Waiting for studio to start"
timeout /nobreak 120
cd %CRAFTER_HOME%data\repos\sites
FOR /D %%S in (*) do (
  echo "Running sync for site '%%S'"
  start java -jar %CRAFTER_BIN_FOLDER%\craftercms-utils.jar post "http://localhost:8080/studio/api/1/services/api/1/repo/sync-from-repo.json" "{ \"site_id\":\"%%S\" }"
)
:skipAuth
  
rd /S /Q "%TEMP_FOLDER%"
echo "Restore completed"
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
