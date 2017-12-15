@echo off
REM Script to create the Solr core & Deployer target for a delivery environment.

REM pre flight check.
IF /i "%1"=="" goto shelp

SET SITE=%1

SET DELIVERY_HOME=%~dp0
call %DELIVERY_HOME%\crafter-setenv.bat

IF /i "%2"=="" (
  for %%i in ("%~dp0..") do set DELIVERY_ROOT=%%~fi\
  for %%i in ("%~dp0..\..") do set AUTHORING_ROOT=%%~fi\
  SET AUTHORING_SITE_REPOS=%AUTHORING_ROOT%crafter-authoring\data\repos\sites
  SET REPO=%AUTHORING_SITE_REPOS%\%SITE%\published
) ELSE (
  SET REPO=%2
)

IF NOT "%REPO:~0,3%" equ "ssh" (
  IF NOT EXIST "%REPO%" (
    echo "Repository path %REPO% for site \"%SITE%\" does not exist or cannot to read"
    exit /b 2
  )
)

IF /i "%3"=="" (
  SET PRIVATE_KEY=
) ELSE (
  SET PRIVATE_KEY=, ""ssh_private_key_path"":""%3%""
)

echo "Creating Solr Core"
java -jar %DELIVERY_HOME%craftercms-utils.jar post "http://localhost:%TOMCAT_HTTP_PORT%/crafter-search/api/2/admin/index/create" "{""id"":""%SITE%""}" > nul
echo "Creating Deployer Target"
java -jar %DELIVERY_HOME%craftercms-utils.jar post "http://localhost:%DEPLOYER_PORT%/api/1/target/create"  "{""env"":""default"", ""site_name"":""%SITE%"", ""template_name"":""remote"", ""repo_url"":""%REPO%"", ""repo_branch"":""live"", ""engine_url"":""http://localhost:%TOMCAT_HTTP_PORT%"" %PRIVATE_KEY% }" > nul
echo Done
exit /b 0

:shelp
echo "%0%"
echo "Arguments:"
echo "SITENAME name of the site to be created."
echo "REPO_PATH (optional) location of the site content."
echo "PRIVATE_KEY (optional) location of the SSH private key."
echo "Examples:"
echo "%0% newSite"
echo "%0% newSite /usr/local/data/repos/sites/newSite/published"
echo "%0% newSite /usr/local/data/repos/sites/newSite/published /home/admin/.ssh/admin4k"
exit /b 1
