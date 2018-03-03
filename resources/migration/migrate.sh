#!/bin/bash

export MIGRATION_TOOL_HOME=${MIGRATION_TOOL_HOME:=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )}
export CRAFTER_HOME=${CRAFTER_HOME:=$( cd "$MIGRATION_TOOL_HOME/.." && pwd )}
export CRAFTER_ROOT=${CRAFTER_ROOT:=$( cd "$CRAFTER_HOME/.." && pwd )}
export RESOURCES_DIR=${RESOURCES_DIR:=$MIGRATION_TOOL_HOME/resources}
export WORK_DIR=${WORK_DIR:=$CRAFTER_ROOT/data/migration}
export LOGS_DIR=${LOGS_DIR:=$CRAFTER_ROOT/logs/migration}
export SCRIPT_NAME=$(basename "$0")
export CURRENT_DIR=$(pwd)
export STUDIO_PORT=${STUDIO_PORT:=@TOMCAT_HTTP_PORT}
export STUDIO_URL=${STUDIO_URL:="http://localhost:$STUDIO_PORT/studio"}
export GET_CSRF_TOKEN_URL=$STUDIO_URL/api/1/services/api/1/server/get-available-languages.json
export LOGIN_URL=$STUDIO_URL/api/1/services/api/1/security/login.json
export CREATE_SITE_URL=$STUDIO_URL/api/1/services/api/1/site/create.json
export COOKIE_JAR=$WORK_DIR/cookies.txt
export COMMIT_EVERY=1000

function help(){
	echo "$SCRIPT_NAME"
	echo "Arguments:"
	echo -e "\t TARGET_SITE_NAME the name of the new 3.0 site where the original site will be migrated."
	echo -e "\t SRC_STUDIO_CONFIG_DIR location of the 2.5 Studio configuration (where the content-types reside)."
	echo -e "\t SRC_CONTENT_DIR root of the 2.5 site (where the site, scripts, static-assets and template folders reside)."
	echo "Example:"
	echo -e "\t $SCRIPT_NAME mysite ~/crafter/crafter-2.5.x/authoring/data/repo/cstudio/config/mysite ~/crafter/crafter-2.5.x/authoring/data/repo/wem-projects/mysite/mysite/work-area"
}

if [ -z "$1" ] || [ "$1" == "-help" ]; then
	help
	exit 1
fi

if [ $# -eq 3 ]; then
	export TARGET_SITE_NAME=$1
	export SRC_STUDIO_CONFIG_DIR=$2
	export SRC_CONTENT_DIR=$3
	export MIGRATE_REPO_DIR=$WORK_DIR/$TARGET_SITE_NAME
	export MIGRATION_LOG_PATH=$LOGS_DIR/$TARGET_SITE_NAME.log
	export DATE_FORMAT_SEARCH_RESULTS_PATH=$LOGS_DIR/$TARGET_SITE_NAME-date-format.txt
else
	echo -e "\e[31mWrong number of arguments\e[0m"
	echo
	help
	exit 1
fi

read -p "Replace old content type controllers (controller.js, extract.js, extract.groovy and controller.groovy) with latest controllers (not recommended if you have custom code in the controllers)? [y/n]: " REPLACE_OLD_CONTROLLERS
export REPLACE_OLD_CONTROLLERS

read -p "Enter Studio username: " STUDIO_USERNAME
if [ -z "$STUDIO_USERNAME" ]; then
	echo -e "\e[31mUsername can't be empty\e[0m"
	exit 1
else
	export STUDIO_USERNAME
fi

read -s -p "Enter Studio password: " STUDIO_PASSWORD
if [ -z "$STUDIO_PASSWORD" ]; then
	echo -e "\e[31mPassword can't be empty\e[0m"
	exit 1
else
	export STUDIO_PASSWORD
fi

echo
echo
echo -e "\e[34mRunning migration in background and tailing ($MIGRATION_LOG_PATH). Check also $DATE_FORMAT_SEARCH_RESULTS_PATH after the migration is complete\e[0m"
echo

if [ ! -d "$LOGS_DIR" ]; then
	mkdir -p $LOGS_DIR
fi

rm -f $MIGRATION_LOG_PATH
rm -f $DATE_FORMAT_SEARCH_RESULTS_PATH

nohup $MIGRATION_TOOL_HOME/migrate-bg.sh > $MIGRATION_LOG_PATH 2>&1 &
tail -f $MIGRATION_LOG_PATH
