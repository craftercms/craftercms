@echo off
IF NOT DEFINED DEPLOYER_JAVA_OPTS (SET DEPLOYER_JAVA_OPTS=)
IF NOT DEFINED CRAFTER_HOME (SET CRAFTER_HOME=%~dp0)
IF NOT DEFINED DEPLOYER_HOME (SET DEPLOYER_HOME=%CRAFTER_HOME%\crafter-deployer)
IF NOT DEFINED DEPLOYER_STARTUP (SET DEPLOYER_STARTUP=startup.bat)
IF NOT DEFINED DEPLOYER_SHUTDOWN (SET DEPLOYER_SHUTDOWN=shutdown.bat)
IF NOT DEFINED DEPLOYER_DEBUG (SET DEPLOYER_DEBUG=debug.bat)
IF NOT DEFINED DEPLOYER_WIN_TITLE (SET DEPLOYER_WIN_TITLE=Crafter Deployer)
IF NOT DEFINED CATALINA_HOME (SET CATALINA_HOME=%CRAFTER_HOME%\apache-tomcat)
chcp 65001
echo ██████╗ ██████╗   █████╗  ███████╗ ████████╗ ███████╗ ██████╗      ██████╗ ███╗   ███╗ ███████╗
echo ██╔════╝ ██╔══██╗ ██╔══██╗ ██╔════╝ ╚══██╔══╝ ██╔════╝ ██╔══██╗    ██╔════╝ ████╗ ████║ ██╔════╝
echo ██║      ██████╔╝ ███████║ █████╗      ██║    █████╗   ██████╔╝    ██║      ██╔████╔██║ ███████╗
echo ██║      ██╔══██╗ ██╔══██║ ██╔══╝      ██║    ██╔══╝   ██╔══██╗    ██║      ██║╚██╔╝██║ ╚════██║
echo ╚██████╗ ██║  ██║ ██║  ██║ ██║         ██║    ███████╗ ██║  ██║    ╚██████╗ ██║ ╚═╝ ██║ ███████║
echo ╚═════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚═╝         ╚═╝    ╚══════╝ ╚═╝  ╚═╝     ╚═════╝ ╚═╝     ╚═╝ ╚══════╝

IF /i "%1%"=="start" goto init
IF /i "%1%"=="-s" goto init

IF /i "%1%"=="stop" goto skill
IF /i "%1%"=="-k" goto skill

IF /i "%1%"=="debug" goto debug
IF /i "%1%"=="-d" goto debug

goto shelp
exit 0;

::Starts
:shelp
echo "Crafter Bat script"
echo "-s --start, Start crafter deployer"
echo "-k --stop, Stop crafter deployer"
echo "-d --debug, Impli  eds start, Start crafter deployer in debug mode"
exit /b 0

:init
cd %DEPLOYER_HOME%
start %DEPLOYER_STARTUP%
cd %CRAFTER_HOME%
call "apache-tomcat\bin\startup.bat"
start %CRAFTER_HOME%\solr\bin\solr start -f -p 8984
goto cleanOnExit

:skill
start %CRAFTER_HOME%\solr\bin\solr stop -p 8984
start "apache-tomcat/bin/shutdown.bat"
cd %DEPLOYER_HOME%
start %DEPLOYER_SHUTDOWN%
cd %CRAFTER_HOME%
goto cleanOnExit


:debug
call %CRAFTER_HOME%\solr\bin\solr start -f -p 8984 -a "-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=1044"
cd %DEPLOYER_HOME%
call %DEPLOYER_DEBUG%
cd %CRAFTER_HOME%
call "apache-tomcat/bin/catalina.bat" jpda start
goto cleanOnExit

:cleanOnExit
SET DEPLOYER_JAVA_OPTS=
SET CRAFTER_HOME=
SET DEPLOYER_HOME=
SET DEPLOYER_STARTUP=
SET DEPLOYER_SHUTDOWN=
SET DEPLOYER_DEBUG=
SET DEPLOYER_WIN_TITLE=
SET CATALINA_HOME=
exit /b 0

:logo
echo " ██████╗ ██████╗   █████╗  ███████╗ ████████╗ ███████╗ ██████╗      ██████╗ ███╗   ███╗ ███████╗"
echo "██╔════╝ ██╔══██╗ ██╔══██╗ ██╔════╝ ╚══██╔══╝ ██╔════╝ ██╔══██╗    ██╔════╝ ████╗ ████║ ██╔════╝"
echo "██║      ██████╔╝ ███████║ █████╗      ██║    █████╗   ██████╔╝    ██║      ██╔████╔██║ ███████╗"
echo "██║      ██╔══██╗ ██╔══██║ ██╔══╝      ██║    ██╔══╝   ██╔══██╗    ██║      ██║╚██╔╝██║ ╚════██║"
echo "╚██████╗ ██║  ██║ ██║  ██║ ██║         ██║    ███████╗ ██║  ██║    ╚██████╗ ██║ ╚═╝ ██║ ███████║"
echo " ╚═════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚═╝         ╚═╝    ╚══════╝ ╚═╝  ╚═╝     ╚═════╝ ╚═╝     ╚═╝ ╚══════╝"
