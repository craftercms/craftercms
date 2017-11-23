@echo off

Rem Dont bother do anything if OS is not 64
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OSARCH=32BIT || set OSARCH=64BIT
if %OSARCH%==32BIT (
  echo "CrafterCMS is not support 32bit OS"
  pause
  exit 4
)

rem Make sure this variable is clean.
SET CRAFTER_BIN_FOLDER=
SET CATALINA_OPTS=
rem Reinit variables
SET CRAFTER_BIN_FOLDER=%~dp0
for %%i in ("%~dp0..") do set CRAFTER_HOME=%%~fi\

call %CRAFTER_BIN_FOLDER%\crafter-setenv.bat %2

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
 java -jar %CRAFTER_BIN_FOLDER%craftercms-utils.jar download mongodbmsi
 msiexec.exe /i mongodb.msi /passive INSTALLLOCATION="%CRAFTER_BIN_FOLDER%mongodb\" /l*v "%CRAFTER_BIN_FOLDER%mongodb\mongodb.log" /norestart
 SET MONGODB_BIN_DIR= "%CRAFTER_BIN_FOLDER%mongodb\bin\mongod.exe"
 IF NOT EXIST %MONGODB_BIN_DIR% (
     echo "Mongodb bin path not found trying download the zip %MONGODB_BIN_DIR%"
     java -jar %CRAFTER_BIN_FOLDER%craftercms-utils.jar download mongodb
     java -jar  %CRAFTER_BIN_FOLDER%craftercms-utils.jar unzip mongodb.zip %CRAFTER_BIN_FOLDER%mongodb\bin true
 )
 cd %CRAFTER_BIN_FOLDER%
goto :init

:initWithOutExit
@rem Windows does not support Or in the If soo...
netstat -o -n -a | findstr  "0.0.0.0:%MARIADB_PORT%"
IF %ERRORLEVEL% equ 0 (
 echo Crafter CMS Database Port: %MARIADB_PORT% is in use.
 echo This might be because of a prior unsuccessful or incomplete shut down.
 echo "Please terminate that process before attempting to start Crafter CMS."
 pause
 exit /b 2
)

IF EXIST %PROFILE_WAR_PATH% set start_mongo=true
IF /i "%FORCE_MONGO%"=="forceMongo" set start_mongo=true

IF /i "%start_mongo%"=="true" (
  set mongoDir=%CRAFTER_BIN_FOLDER%mongodb
  IF NOT EXIST "%mongoDir%" goto installMongo
  IF NOT EXIST "%MONGODB_DATA_DIR%" mkdir %MONGODB_DATA_DIR%
  IF NOT EXIST "%MONGODB_DATA_DIR%" mkdir %MONGODB_DATA_DIR%
  IF NOT EXIST "%MONGODB_LOGS_DIR%" mkdir %MONGODB_LOGS_DIR%
  start %mongoDir%\bin\mongod --dbpath=%MONGODB_DATA_DIR% --directoryperdb --journal --logpath=%MONGODB_LOGS_DIR%\mongod.log --port %MONGODB_PORT%
)
start %DEPLOYER_HOME%\%DEPLOYER_STARTUP%
IF NOT EXIST "%CRAFTER_HOME%\data\indexes" mkdir %CRAFTER_HOME%\data\indexes
start %CRAFTER_BIN_FOLDER%solr\bin\solr start -f -p %SOLR_PORT% -s %SOLR_HOME% -Dcrafter.solr.index=%CRAFTER_HOME%\data\indexes
call %CATALINA_HOME%\bin\startup.bat
@rem Windows keep variables live until terminal dies.
set start_mongo=false
goto :eof

:init
call :initWithOutExit
goto cleanOnExitKeepTermAlive

:debug
@rem Windows does not support Or in the If soo...

IF EXIST %PROFILE_WAR_PATH% set start_mongo=true
IF /i "%FORCE_MONGO%"=="forceMongo" set start_mongo=true

IF /i "%start_mongo%"=="true" (
  set mongoDir=%CRAFTER_BIN_FOLDER%mongodb
  IF NOT EXIST "%mongoDir%" goto installMongo
  IF NOT EXIST "%MONGODB_DATA_DIR%" mkdir %MONGODB_DATA_DIR%
  IF NOT EXIST "%MONGODB_DATA_DIR%" mkdir %MONGODB_DATA_DIR%
  IF NOT EXIST "%MONGODB_LOGS_DIR%" mkdir %MONGODB_LOGS_DIR%
  start %mongoDir%\bin\mongod --dbpath=%MONGODB_DATA_DIR% --directoryperdb --journal --logpath=%MONGODB_LOGS_DIR%\mongod.log --port %MONGODB_PORT%
)
start %DEPLOYER_HOME%\%DEPLOYER_DEBUG%
IF NOT EXIST "%CRAFTER_HOME%\data\indexes" mkdir %CRAFTER_HOME%\data\indexes
start %CRAFTER_BIN_FOLDER%solr\bin\solr start -f -p %SOLR_PORT% -s %SOLR_HOME% -Dcrafter.solr.index=%CRAFTER_HOME%\data\indexes -a "-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=%SOLR_DEBUG_PORT%
call %CATALINA_HOME%\bin\catalina.bat jpda start
@rem Windows keep variables live until terminal dies.
set start_mongo=false
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
SET TARGET_FILE="%CRAFTER_HOME%backups\%TARGET_NAME%-%CDATE%-%CTIME%.zip"
SET TEMP_FOLDER=%CRAFTER_HOME%temp

echo "Starting backup into %TARGET_FILE%"
md %TEMP_FOLDER%
md "%CRAFTER_HOME%backups"

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

cd "%CRAFTER_HOME%"
rd /Q /S "%TEMP_FOLDER%"
echo "Backup completed"
goto cleanOnExitKeepTermAlive

:restore
netstat -o -n -a | findstr "0.0.0.0:%TOMCAT_HTTP_PORT%"
IF %ERRORLEVEL% equ 0 (
  echo "Please stop the system before starting the restore process."
  goto cleanOnExitKeepTermAlive
)
SET SOURCE_FILE=%2
IF NOT EXIST "%SOURCE_FILE%" (
  echo "The file does not exist"
  exit /b 1
)

SET /P DO_IT= Warning, you're about to restore CrafterCMS from a backup, which will wipe the ^

existing sites and associated database and replace everything with the restored data. If you ^

care about the existing state of the system then stop this process, backup the system, and then ^

attempt the restore. Are you sure you want to proceed? (yes/no)

IF /i NOT "%DO_IT%"=="yes" ( exit /b 0 )

echo "Clearing all existing data"
rd /q /s %CRAFTER_HOME%\data

SET TEMP_FOLDER="%CRAFTER_HOME%temp"
echo "Starting restore from %SOURCE_FILE%"
md "%TEMP_FOLDER%"

REM UNZIP everything
java -jar %CRAFTER_BIN_FOLDER%craftercms-utils.jar unzip "%SOURCE_FILE%" "%TEMP_FOLDER%"

REM MongoDB Dump
IF NOT EXIST "%TEMP_FOLDER%\mongodb.zip" ( goto skipMongo )
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
echo "Restoring git repos"
java -jar %CRAFTER_BIN_FOLDER%craftercms-utils.jar unzip "%TEMP_FOLDER%\repos.zip" "%CRAFTER_HOME%data/repos"
:skipRepos

REM UNZIP solr indexes
IF NOT EXIST "%TEMP_FOLDER%\indexes.zip" ( goto skipIndexes )
echo "Restoring solr indexes"
java -jar %CRAFTER_BIN_FOLDER%craftercms-utils.jar unzip "%TEMP_FOLDER%\indexes.zip" "%SOLR_INDEXES_DIR%"
:skipIndexes

REM UNZIP deployer data
IF NOT EXIST "%TEMP_FOLDER%\deployer.zip" ( goto skipDeployer )
echo "Restoring deployer data"
java -jar %CRAFTER_BIN_FOLDER%craftercms-utils.jar unzip "%TEMP_FOLDER%\deployer.zip" "%DEPLOYER_DATA_DIR%"
:skipDeployer

REM If it is an authoring env then sync the repos
IF NOT EXIST "%TEMP_FOLDER%\crafter.sql" ( goto skipAuth )
echo "Restoring Authoring Data"
md "%MYSQL_DATA%"
REM Install DB
start "MySQL Installation" /W %CRAFTER_BIN_FOLDER%dbms\bin\mysql_install_db.exe --datadir="%MYSQL_DATA%"
REM Start DB
start "MySQL Server" %CRAFTER_BIN_FOLDER%dbms\bin\mysqld.exe --no-defaults --console --skip-grant-tables --max_allowed_packet=64M --basedir="%CRAFTER_BIN_FOLDER%dbms" --datadir="%MYSQL_DATA%" --port=@MARIADB_PORT@ --innodb_large_prefix=TRUE --innodb_file_format=BARRACUDA --innodb_file_format_max=BARRACUDA --innodb_file_per_table=TRUE
timeout /nobreak /t 5
REM Import
start "MySQL Import" /W %CRAFTER_BIN_FOLDER%dbms\bin\mysql.exe --user=root --port=@MARIADB_PORT@ -e "source %TEMP_FOLDER%\crafter.sql"
timeout /nobreak /t 5
REM Stop DB
taskkill /IM mysqld.exe
REM start tomcat
call :initWithOutExit
echo "Waiting for studio to start"
timeout /nobreak /t 120
cd %CRAFTER_HOME%data\repos\sites
FOR /D %%S in (*) do (
  echo "Running sync for site '%%S'"
  start /b java -jar %CRAFTER_BIN_FOLDER%craftercms-utils.jar post "http://localhost:%TOMCAT_HTTP_PORT%/studio/api/1/services/api/1/repo/sync-from-repo.json" "{ \"site_id\":\"%%S\" }"
)
:skipAuth

rd /S /Q "%TEMP_FOLDER%"
echo "Restore completed"
goto cleanOnExitKeepTermAlive


:skill
call %CRAFTER_BIN_FOLDER%solr\bin\solr stop -p %SOLR_PORT%
@rem Windows does not support Or in the If soo...

netstat -o -n -a | findstr  "0.0.0.0:%MONGODB_PORT%"
IF %ERRORLEVEL% equ 0 set start_mongo=true
IF EXIST %PROFILE_WAR_PATH% set start_mongo=true
IF /i "%FORCE_MONGO%"=="forceMongo" set start_mongo=true

IF /i "%start_mongo%"=="true" (
  taskkill /IM mongod.exe
)
@rem Windows keeps vars live until cmd window die.
set start_mongo=false
call %CATALINA_HOME%\bin\shutdown.bat
SLEEP 5
netstat -o -n -a | findstr  "0.0.0.0:%MARIADB_PORT%"
IF %ERRORLEVEL% equ 0 (
  taskkill /IM mysqld.exe
)

call %DEPLOYER_HOME%\%DEPLOYER_SHUTDOWN%
taskkill /FI "WINDOWTITLE eq \"Solr-%SOLR_PORT%\"
goto cleanOnExit


:cleanOnExit
cd %CRAFTER_BIN_FOLDER%
exit

:cleanOnExitKeepTermAlive
cd %CRAFTER_BIN_FOLDER%
exit /b