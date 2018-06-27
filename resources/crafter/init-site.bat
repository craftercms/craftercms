@echo off
REM Script to create the Solr core & Deployer target for a delivery environment.

SET DELIVERY_HOME=%~dp0

call %DELIVERY_HOME%\crafter-setenv.bat

REM Execute Groovy script
%DELIVERY_HOME%\groovy\bin\groovy -cp %DELIVERY_HOME% -Dgrape.root=%DELIVERY_HOME% %DELIVERY_HOME%\init-site.groovy %*
