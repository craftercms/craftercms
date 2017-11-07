@echo off
REM Script to create the Solr core & Deployer target for a delivery environment.
rem Make sure this variable is clean.

SET DELIVERY_HOME=
SET DELIVERY_HOME=%~dp0
set SITE=
set REPO=
set PRIVATE_KEY=
for %%i in ("%~dp0..") do set DELIVERY_ROOT=%%~fi\
for %%i in ("%~dp0..\..") do set AUTHORING_ROOT=%%~fi\
SET AUTHORING_SITE_REPOS=%AUTHORING_ROOT%crafter-authoring\data\repos\sites

IF /i "%1%"=="" goto shelp

set SITE=%1
set REPO=%2
set PRIVATE_KEY=%3
IF NOT DEFINED REPO SET REPO=%AUTHORING_SITE_REPOS%\%SITE%\published
IF DEFINED PRIVATE_KEY SET PRIVATE_KEY=, ""ssh_private_key_path"":""%3%""

echo "Creating Solr Core"
java -jar %DELIVERY_HOME%craftercms-utils.jar post "http://localhost:9080/crafter-search/api/2/admin/index/create" "{""id"":""%SITE%""}" > nul
echo "Creating Deployer Target"
java -jar %DELIVERY_HOME%craftercms-utils.jar post "http://localhost:9192/api/1/target/create"  "{""env"":""default"", ""site_name"":""%SITE%"", ""template_name"":""remote"", ""repo_url"":""%REPO%"", ""repo_branch"":""live"", ""engine_url"":""http://localhost:9080"" %PRIVATE_KEY% }" > nul
exit /b 0
:shelp
echo "Usage: init-site.sh <site name> [site's published repo git url] [ssh private key path]"
exit /b 1
