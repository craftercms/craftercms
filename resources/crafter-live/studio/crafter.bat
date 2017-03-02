@echo off
IF NOT DEFINED DEPLOYER_JAVA_OPTS (SET DEPLOYER_JAVA_OPTS=)
IF NOT DEFINED CRAFTER_HOME (SET CRAFTER_HOME=%cd%)
IF NOT DEFINED DEPLOYER_STARTUP (SET DEPLOYER_STARTUP=%CRAFTER_HOME%\crafter-deployer\startup.bat)
IF NOT DEFINED DEPLOYER_SHUTDOWN (SET DEPLOYER_SHUTDOWN=%CRAFTER_HOME%\crafter-deployer\shutdown.bat)
IF NOT DEFINED DEPLOYER_DEBUG (SET DEPLOYER_DEBUG=%CRAFTER_HOME%\crafter-deployer\debug.bat)
IF NOT DEFINED DEPLOYER_WIN_TITLE (SET DEPLOYER_WIN_TITLE=Crafter Deployer)
IF NOT DEFINED CATALINA_HOME (SET CATALINA_HOME=%CRAFTER_HOME%\apache-tomcat)

IF /i "%1%"=="--start" goto init
IF /i "%1%"=="-s" goto init

IF /i "%1%"=="--stop" goto skill
IF /i "%1%"=="-k" goto skill

IF /i "%1%"=="--debug" goto debug
IF /i "%1%"=="-d" goto debug

goto shelp
exit 0;

::Starts
:shelp
echo "Crafter Bat script"
echo "-s --start, Start crafter deployer"
echo "-k --stop, Stop crafter deployer"
echo "-d --debug, Implieds start, Start crafter deployer in debug mode"
exit /b 0

:init
cd crafter-deployer
start %DEPLOYER_STARTUP%
cd ..
call "apache-tomcat/bin/startup.bat"
exit /b 0

:skill
call "apache-tomcat/bin/shutdown.bat"
cd crafter-deployer
call %DEPLOYER_SHUTDOWN%
cd ..
exit /b 0


:debug
cd crafter-deployer
start %DEPLOYER_DEBUG%
cd ..
call "apache-tomcat/bin/catalina.bat" jpda start
exit /b 0
