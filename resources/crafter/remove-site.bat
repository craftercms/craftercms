@echo off
REM Script to remove a site from a delivery environment.

REM pre flight check.
IF /i "%1"=="" goto shelp

SET SITE=%1

SET DELIVERY_HOME=%~dp0
call %DELIVERY_HOME%\crafter-setenv.bat

SET REPO=%DELIVERY_HOME%\..\data\repos\sites\%SITE%


IF NOT EXIST "%REPO%" (
  echo "Repository path %REPO% for site \"%SITE%\" does not exist or cannot be read"
  exit /b 2
)

SET /P CONTINUE="This operation can not be undone, delete all files and configuration for site '%SITE%'? (Y/N)"
IF /I "%CONTINUE%" NEQ "Y" EXIT /b 0

echo "Removing Solr Core"
java -jar %DELIVERY_HOME%craftercms-utils.jar post "http://localhost:%TOMCAT_HTTP_PORT%/crafter-search/api/2/admin/index/delete/%SITE%" "{""delete_mode"":""ALL_DATA_AND_CONFIG""}" > nul
echo "Removing Deployer Target"
java -jar %DELIVERY_HOME%craftercms-utils.jar post "http://localhost:%DEPLOYER_PORT%/api/1/target/delete/default/%SITE%" "" > nul
echo "Removing Git Repository"
rd /s /q %REPO%
echo Done
exit /b 0

:shelp
echo "%0%"
echo "Arguments:"
echo "SITENAME name of the site to be removed."
echo "Examples:"
echo "%0% newSite"
exit /b 1
