@echo off
IF NOT DEFINED CRAFTER_HOME (SET CRAFTER_HOME=%cd%)
IF NOT DEFINED DEPLOYER_PID_FILE (SET DEPLOYER_PID_FILE=%CRAFTER_HOME%\crafter-deployer.pid)

title=%DEPLOYER_WIN_TITLE%
echo "Starting Crafter Deployer"

IF /i "%1%"=="--start" goto init
IF /i "%1%"=="-s" goto init

IF /i "%1%"=="--stop" goto skill
IF /i "%1%"=="-k" goto skill

IF /i "%1%"=="--debug" goto debug
IF /i "%1%"=="-d" goto debug

goto shelp

::Starts
:shelp
echo "Crater Deployer usage"
echo "-s --start, Start crafter deployer"
echo "-k --stop, Stop crafter deployer"
echo "-d --debug, Implieds start, Start crafter deployer in debug mode"
exit /b 0

:init
java -jar %DEPLOYER_JAVA_OPTS% crafter-deployer.jar
exit /b 0

:skill
@echo on
IF exist DEPLOYER_PID_FILE goto stopById
goto stopByTitleName
exit /b 0

:stopByTitleName
for /f "tokens=2 USEBACKQ" %%f IN (`tasklist /NH /FI "WINDOWTITLE eq %DEPLOYER_WIN_TITLE%"`) Do taskkill /PID %%f
exit /b 0

:stopById
taskkill /F %DEPLOYER_PID_FILE%
exit /b 0

:debug
set DEPLOYER_JAVA_OPTS=%DEPLOYER_JAVA_OPTS% -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005
cd crafter-deployer
java -jar %DEPLOYER_JAVA_OPTS% crafter-deployer.jar
