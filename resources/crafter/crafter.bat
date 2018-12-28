@echo off

Rem Dont bother do anything if OS is not 64
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OSARCH=32BIT || set OSARCH=64BIT
if %OSARCH%==32BIT (
  echo "CrafterCMS is not support 32bit OS"
  pause
  exit 4
)

rem Make sure this variable is clean.
SET CRAFTER_HOME=
SET CRAFTER_ROOT=
SET CATALINA_OPTS=
rem Reinit variables
SET CRAFTER_HOME=%~dp0.
for %%i in ("%CRAFTER_HOME%\..") do set CRAFTER_ROOT=%%~fi

call "%CRAFTER_HOME%\crafter-setenv.bat" %2

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
 mkdir "%CRAFTER_HOME%\mongodb"
 cd "%CRAFTER_HOME%\mongodb"
 java -jar "%CRAFTER_HOME%\craftercms-utils.jar" download mongodbmsi
 msiexec.exe /i mongodb.msi /passive INSTALLLOCATION="%CRAFTER_HOME%\mongodb\" /l*v "%CRAFTER_HOME%\mongodb\mongodb.log" /norestart
 SET MONGODB_BIN_DIR= "%CRAFTER_HOME%\mongodb\bin\mongod.exe"
 IF NOT EXIST "%MONGODB_BIN_DIR%" (
     echo "Mongodb bin path not found trying download the zip %MONGODB_BIN_DIR%"
     java -jar "%CRAFTER_HOME%\craftercms-utils.jar" download mongodb
     java -jar  "%CRAFTER_HOME%\craftercms-utils.jar" unzip mongodb.zip "%CRAFTER_HOME%\mongodb\bin" true
 )
 cd "%CRAFTER_HOME%"
goto :init

:initWithOutExit
@rem Windows does not support Or in the If soo...
netstat -o -n -a | findstr  "0.0.0.0:%MARIADB_PORT%"
IF %ERRORLEVEL% equ 0 (
 echo Crafter CMS Database Port: %MARIADB_PORT% is in use.
 echo This might be because of a prior unsuccessful or incomplete shut down.
 echo Please terminate that process before attempting to start Crafter CMS.
 pause
 exit /b 2
)

IF EXIST "%PROFILE_WAR_PATH%" set start_mongo=true
IF /i "%FORCE_MONGO%"=="true" set start_mongo=true

IF /i "%start_mongo%"=="true" (
  set mongoDir=%CRAFTER_HOME%\mongodb
  IF NOT EXIST "%mongoDir%" goto installMongo
  IF NOT EXIST "%MONGODB_DATA_DIR%" mkdir "%MONGODB_DATA_DIR%"
  IF NOT EXIST "%MONGODB_DATA_DIR%" mkdir "%MONGODB_DATA_DIR%"
  IF NOT EXIST "%MONGODB_LOGS_DIR%" mkdir "%MONGODB_LOGS_DIR%"
  start "" "%mongoDir%\bin\mongod" --dbpath="%MONGODB_DATA_DIR%" --directoryperdb --journal --logpath="%MONGODB_LOGS_DIR%\mongod.log" --port %MONGODB_PORT%
)

IF NOT EXIST "%DEPLOYER_LOGS_DIR%" mkdir "%DEPLOYER_LOGS_DIR%"
start "" "%DEPLOYER_HOME%\%DEPLOYER_STARTUP%"

IF "%WITH_SOLR%"=="true" (
  IF NOT EXIST "%SOLR_INDEXES_DIR%" mkdir "%SOLR_INDEXES_DIR%"
  IF NOT EXIST "%SOLR_LOGS_DIR%" mkdir "%SOLR_LOGS_DIR%"
  call "%CRAFTER_HOME%\solr\bin\solr" start -p %SOLR_PORT% -s "%SOLR_HOME%" -Dcrafter.solr.index="%SOLR_INDEXES_DIR%"
)

IF NOT "%SKIP_ELASTICSEARCH%"=="true" (
  IF NOT EXIST "%ES_INDEXES_DIR%" mkdir "%ES_INDEXES_DIR%"
  start "ElasticSearch" cmd /c call "%CRAFTER_HOME%\elasticsearch\bin\elasticsearch" -d
)

IF NOT EXIST "%CATALINA_LOGS_DIR%" mkdir "%CATALINA_LOGS_DIR%"
IF NOT EXIST "%CATALINA_TMPDIR%" mkdir "%CATALINA_TMPDIR%"
call "%CATALINA_HOME%\bin\catalina.bat" start
@rem Windows keep variables live until terminal dies.
set start_mongo=false
goto :eof

:init
call :initWithOutExit
goto cleanOnExitKeepTermAlive

:debug
@rem Windows does not support Or in the If soo...

IF EXIST "%PROFILE_WAR_PATH%" set start_mongo=true
IF /i "%FORCE_MONGO%"=="forceMongo" set start_mongo=true

IF /i "%start_mongo%"=="true" (
  set mongoDir=%CRAFTER_HOME%\mongodb
  IF NOT EXIST "%mongoDir%" goto installMongo
  IF NOT EXIST "%MONGODB_DATA_DIR%" mkdir "%MONGODB_DATA_DIR%"
  IF NOT EXIST "%MONGODB_DATA_DIR%" mkdir "%MONGODB_DATA_DIR%"
  IF NOT EXIST "%MONGODB_LOGS_DIR%" mkdir "%MONGODB_LOGS_DIR%"
  start "" "%mongoDir%\bin\mongod" --dbpath="%MONGODB_DATA_DIR%" --directoryperdb --journal --logpath="%MONGODB_LOGS_DIR%\mongod.log" --port %MONGODB_PORT%
)

IF NOT EXIST "%DEPLOYER_LOGS_DIR%" mkdir "%DEPLOYER_LOGS_DIR%"
start "" "%DEPLOYER_HOME%\%DEPLOYER_DEBUG%"

IF NOT EXIST "%SOLR_INDEXES_DIR%" mkdir "%SOLR_INDEXES_DIR%"
IF NOT EXIST "%SOLR_LOGS_DIR%" mkdir "%SOLR_LOGS_DIR%"
call "%CRAFTER_HOME%\solr\bin\solr" start -p %SOLR_PORT% -s "%SOLR_HOME%" -Dcrafter.solr.index="%CRAFTER_DATA_DIR%\indexes" -a "-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=%SOLR_DEBUG_PORT%

IF NOT EXIST "%CATALINA_LOGS_DIR%" mkdir "%CATALINA_LOGS_DIR%"
IF NOT EXIST "%CATALINA_TMPDIR%" mkdir "%CATALINA_TMPDIR%"
call "%CATALINA_HOME%\bin\catalina.bat" jpda start

@rem Windows keep variables live until terminal dies.
set start_mongo=false
goto cleanOnExit

:backup
SET TARGET_NAME=%2
IF NOT DEFINED TARGET_NAME (
  IF EXIST "%CRAFTER_HOME%\dbms\bin\mysqldump.exe" (
    SET TARGET_NAME=crafter-authoring-backup
  ) ELSE (
    SET TARGET_NAME=crafter-delivery-backup
  )
)
FOR /F "tokens=2-4 delims=/ " %%a IN ("%DATE%") DO (SET CDATE=%%c-%%a-%%b)
FOR /F "tokens=1-3 delims=:. " %%a IN ("%TIME%") DO (SET CTIME=%%a-%%b-%%c)
SET TARGET_FILE="%CRAFTER_ROOT%\backups\%TARGET_NAME%-%CDATE%-%CTIME%.zip"
IF EXIST "%TARGET_FILE%" (
  DEL /Q "%TARGET_FILE%"
)
SET TEMP_FOLDER="%CRAFTER_ROOT%\temp\backup"

echo "Starting backup into %TARGET_FILE%"
md "%TEMP_FOLDER%"
md "%CRAFTER_ROOT%\backups"

REM MySQL Dump
IF EXIST "%MYSQL_DATA%" (
  IF EXIST "%CRAFTER_HOME%\dbms\bin\mysqldump.exe" (
    echo "Adding MySQL dump"
    start /w "MySQL Dump" "%CRAFTER_HOME%\dbms\bin\mysqldump.exe" --databases crafter --port=%MARIADB_PORT% --protocol=tcp --user=root --result-file="%TEMP_FOLDER%\crafter.sql"
    echo SET GLOBAL innodb_large_prefix = TRUE ; SET GLOBAL innodb_file_format = 'BARRACUDA' ; SET GLOBAL innodb_file_format_max = 'BARRACUDA' ; SET GLOBAL innodb_file_per_table = TRUE ; > "%TEMP_FOLDER%\temp.txt"
    type "%TEMP_FOLDER%\crafter.sql" >> "%TEMP_FOLDER%\temp.txt"
    move /y "%TEMP_FOLDER%\temp.txt" "%TEMP_FOLDER%\crafter.sql"
  )
)

REM MongoDB Dump
IF EXIST %MONGODB_DATA_DIR% (
  IF EXIST "%CRAFTER_HOME%\mongodb\bin\mongodump" (
    echo "Adding mongodb dump"
    "%CRAFTER_HOME%\mongodb\bin\mongodump" --port %MONGODB_PORT% --out "%TEMP_FOLDER%\mongodb" --quiet
    cd "%TEMP_FOLDER%\mongodb"
    java -jar "%CRAFTER_HOME%\craftercms-utils.jar zip" . "%TEMP_FOLDER%\mongodb.zip"
    cd "%CRAFTER_HOME%"
    rd /Q /S "%TEMP_FOLDER%\mongodb"
  )
)

REM ZIP git repos
echo "Adding git repos"
cd "%CRAFTER_DATA_DIR%\repos"
java -jar "%CRAFTER_HOME%\craftercms-utils.jar" zip . "%TEMP_FOLDER%\repos.zip"

REM ZIP solr indexes
IF EXIST "%SOLR_INDEXES_DIR%" (
  echo "Adding solr indexes"
  cd "%SOLR_INDEXES_DIR%"
  java -jar "%CRAFTER_HOME%\craftercms-utils.jar" zip . "%TEMP_FOLDER%\indexes.zip"
)

REM ZIP elasticsearch indexes
IF EXIST "%ES_INDEXES_DIR%" (
  echo "Adding elasticsearch indexes"
  cd "%ES_INDEXES_DIR%"
  java -jar "%CRAFTER_HOME%\craftercms-utils.jar" zip . "%TEMP_FOLDER%\indexes-es.zip"
)

REM ZIP deployer data
echo "Adding deployer data"
cd "%DEPLOYER_DATA_DIR%"
java -jar "%CRAFTER_HOME%\craftercms-utils.jar" zip . "%TEMP_FOLDER%\deployer.zip"
REM ZIP everything (without compression)
cd "%TEMP_FOLDER%"
java -jar "%CRAFTER_HOME%\craftercms-utils.jar" zip . "%TARGET_FILE%" true

cd "%CRAFTER_ROOT%"
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
rd /q /s "%CRAFTER_DATA_DIR%"

SET TEMP_FOLDER="%CRAFTER_ROOT%\temp\backup"
echo "Starting restore from %SOURCE_FILE%"
md "%TEMP_FOLDER%"

REM UNZIP everything
java -jar "%CRAFTER_HOME%\craftercms-utils.jar" unzip "%SOURCE_FILE%" "%TEMP_FOLDER%"

REM MongoDB Dump
IF NOT EXIST "%TEMP_FOLDER%\mongodb.zip" ( goto skipMongo )
echo "Restoring MongoDB"
IF NOT EXIST "%MONGODB_DATA_DIR%" mkdir "%MONGODB_DATA_DIR%"
IF NOT EXIST "%MONGODB_LOGS_DIR%" mkdir "%MONGODB_LOGS_DIR%"
start "MongoDB" "%CRAFTER_HOME%\mongodb\bin\mongod" --dbpath="%MONGODB_DATA_DIR%" --directoryperdb --journal --logpath="%MONGODB_LOGS_DIR%\mongod.log" --port %MONGODB_PORT%
java -jar "%CRAFTER_HOME%\craftercms-utils.jar" unzip "%TEMP_FOLDER%\mongodb.zip" "%TEMP_FOLDER%\mongodb"
start "MongoDB Restore" /W "%CRAFTER_HOME%\mongodb\bin\mongorestore" --port %MONGODB_PORT% "%TEMP_FOLDER%\mongodb"
taskkill /IM mongod.exe
:skipMongo

REM UNZIP git repos
IF NOT EXIST "%TEMP_FOLDER%\repos.zip" ( goto skipRepos )
echo "Restoring git repos"
java -jar "%CRAFTER_HOME%\craftercms-utils.jar" unzip "%TEMP_FOLDER%\repos.zip" "%CRAFTER_DATA_DIR%\repos"
:skipRepos

REM UNZIP solr indexes
IF NOT EXIST "%TEMP_FOLDER%\indexes.zip" ( goto skipSolr )
echo "Restoring solr indexes"
java -jar "%CRAFTER_HOME%\craftercms-utils.jar" unzip "%TEMP_FOLDER%\indexes.zip" "%SOLR_INDEXES_DIR%"
:skipSolr

REM UNZIP elasticsearch indexes
IF NOT EXIST "%TEMP_FOLDER%\indexes-es.zip" ( goto skipElasticSearch )
echo "Restoring elasticsearch indexes"
java -jar "%CRAFTER_HOME%\craftercms-utils.jar" unzip "%TEMP_FOLDER%\indexes-es.zip" "%ES_INDEXES_DIR%"
:skipElasticSearch

REM UNZIP deployer data
IF NOT EXIST "%TEMP_FOLDER%\deployer.zip" ( goto skipDeployer )
echo "Restoring deployer data"
java -jar "%CRAFTER_HOME%\craftercms-utils.jar" unzip "%TEMP_FOLDER%\deployer.zip" "%DEPLOYER_DATA_DIR%"
:skipDeployer

REM If it is an authoring env then sync the repos
IF NOT EXIST "%TEMP_FOLDER%\crafter.sql" ( goto skipAuth )
echo "Restoring Authoring Data"
md "%MYSQL_DATA%"
REM Start DB
echo "Starting DB"
start java -jar -DmariaDB4j.port=%MARIADB_PORT% -DmariaDB4j.baseDir="%CRAFTER_ROOT%\dbms" -DmariaDB4j.dataDir="%MYSQL_DATA%" "%CRAFTER_HOME%\mariaDB4j-app.jar"
timeout /nobreak /t 30
REM Import
echo "Restoring DB"
start /B /W "" "%CRAFTER_HOME%\dbms\bin\mysql.exe" --user=root --port=%MARIADB_PORT% --protocol=TCP -e "source %TEMP_FOLDER%\crafter.sql"
timeout /nobreak /t 5
REM Stop DB
echo "Stopping DB"
set /p pid=<mariadb4j.pid
taskkill /pid %pid% /t /f
timeout /nobreak /t 5
:skipAuth

rd /S /Q "%TEMP_FOLDER%"
echo "Restore complete, you may now start the system"
goto cleanOnExitKeepTermAlive


:skill
IF "%WITH_SOLR%"=="true" (
  call "%CRAFTER_HOME%\solr\bin\solr" stop -p %SOLR_PORT%
)

IF NOT "%SKIP_ELASTICSEARCH%"=="true" (
  taskkill /fi "WINDOWTITLE eq ElasticSearch"
)

@rem Windows does not support Or in the If soo...

netstat -o -n -a | findstr  "0.0.0.0:%MONGODB_PORT%"
IF %ERRORLEVEL% equ 0 set start_mongo=true
IF EXIST "%PROFILE_WAR_PATH%" set start_mongo=true
IF /i "%FORCE_MONGO%"=="forceMongo" set start_mongo=true

IF /i "%start_mongo%"=="true" (
  taskkill /IM mongod.exe
)
@rem Windows keeps vars live until cmd window die.
set start_mongo=false
call "%CATALINA_HOME%\bin\shutdown.bat"
SLEEP %TIME_BEFORE_KILL%
netstat -o -n -a | findstr  "0.0.0.0:%MARIADB_PORT%"
IF %ERRORLEVEL% equ 0 (
  taskkill /IM mysqld.exe
)

call "%DEPLOYER_HOME%\%DEPLOYER_SHUTDOWN%"
taskkill /FI "WINDOWTITLE eq \"Solr-%SOLR_PORT%\"
goto cleanOnExit


:cleanOnExit
cd "%CRAFTER_HOME%"
exit

:cleanOnExitKeepTermAlive
cd "%CRAFTER_HOME%"
exit /b
