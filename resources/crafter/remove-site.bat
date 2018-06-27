@echo off
REM Script to remove a site from a delivery environment.

SET DELIVERY_HOME=%~dp0

call %DELIVERY_HOME%\crafter-setenv.bat

REM Execute Groovy script
%DELIVERY_HOME%\groovy\bin\groovy -cp %DELIVERY_HOME% -Dgrape.root=%DELIVERY_HOME% %DELIVERY_HOME%\remove-site.groovy %*
