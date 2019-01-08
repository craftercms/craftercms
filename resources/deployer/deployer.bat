@echo off


IF NOT DEFINED CRAFTER_HOME (for %%i in ("%~dp0..\..") do set "CRAFTER_HOME=%%~fi\")
IF NOT DEFINED DEPLOYER_PORT (SET DEPLOYER_PORT=@DEPLOYER_PORT@)
IF NOT DEFINED DEPLOYER_DEBUG_PORT (SET DEPLOYER_DEBUG_PORT=@DEPLOYER_D_PORT@)
IF NOT DEFINED DEPLOYER_DATA_DIR (SET DEPLOYER_DATA_DIR=%CRAFTER_DATA_DIR%\deployer)
IF NOT DEFINED DEPLOYER_HOME (SET DEPLOYER_HOME=%CRAFTER_HOME%\bin\crafter-deployer)
IF NOT DEFINED DEPLOYER_LOGS_DIR (SET DEPLOYER_LOGS_DIR=%CRAFTER_LOGS_DIR%\deployer)
IF NOT DEFINED DEPLOYER_DEPLOYMENTS_DIR (SET DEPLOYER_DEPLOYMENTS_DIR=%CRAFTER_DATA_DIR%\repos\sites)
IF NOT DEFINED DEPLOYER_TARGET_DIR (SET DEPLOYER_TARGET_DIR=%DEPLOYER_DATA_DIR%\targets)
IF NOT DEFINED DEPLOYER_PRODCESSED_COMMITS_DIR (SET DEPLOYER_PRODCESSED_COMMITS_DIR=%DEPLOYER_DATA_DIR%\processed-commits)
IF NOT DEFINED DEPLOYER_WIN_TITLE (SET DEPLOYER_WIN_TITLE="Crafter Deployer @ENV@")

SET DEPLOYER_PID_FILE=%CRAFTER_HOME%\crafter-deployer.pid

SET DEPLOYER_JAVA_OPTS=-Dserver.port=%DEPLOYER_PORT% -Dlogging.config="%DEPLOYER_HOME%\logback-spring.xml" -Dlogs.dir="%DEPLOYER_LOGS_DIR%" -Ddeployments.dir="%DEPLOYER_DEPLOYMENTS_DIR%" -Dtargets.dir="%DEPLOYER_TARGET_DIR%" -DprocessedCommits.dir="%DEPLOYER_PRODCESSED_COMMITS_DIR%" -Dloader.path="%DEPLOYER_HOME%\lib"

title=%DEPLOYER_WIN_TITLE%
echo "Starting Crafter Deployer"

IF /i "%1%"=="start" goto init
IF /i "%1%"=="-s" goto init

IF /i "%1%"=="stop" goto skill
IF /i "%1%"=="-k" goto skill

IF /i "%1%"=="debug" goto debug
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
cd "%DEPLOYER_HOME%"
java -jar %DEPLOYER_JAVA_OPTS% crafter-deployer.jar
cd "%CRAFTER_HOME%\bin"
exit /b 0

:skill
@echo on
IF exist "%DEPLOYER_PID_FILE%" goto stopById
goto stopByTitleName
exit /b 0

:stopByTitleName
for /f "tokens=2 delims=," %%a in ('
    tasklist /fi "imagename eq cmd.exe" /v /fo:csv /nh
    ^| findstr /r /c:".*%DEPLOYER_WIN_TITLE%[^,]*$"
    ') do taskkill /pid %%a
exit /b 0

:stopById
taskkill /F "%DEPLOYER_PID_FILE%"
exit /b 0

:debug
set DEPLOYER_JAVA_OPTS=%DEPLOYER_JAVA_OPTS% -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=%DEPLOYER_DEBUG_PORT%
cd crafter-deployer
java -jar %DEPLOYER_JAVA_OPTS% "%DEPLOYER_HOME%\crafter-deployer.jar"
