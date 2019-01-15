#!/bin/bash

export MIGRATION_TOOL_HOME=${MIGRATION_TOOL_HOME:=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )}
export CRAFTER_BIN_DIR=${CRAFTER_BIN_DIR:=$( cd "$MIGRATION_TOOL_HOME/.." && pwd )}
export CRAFTER_HOME=${CRAFTER_HOME:=$( cd "$CRAFTER_BIN_DIR/.." && pwd )}

. "$MIGRATION_TOOL_HOME/setenv.sh"

SCRIPT_NAME=$(basename "$0")

function help(){
	echo "$SCRIPT_NAME"
	echo "Arguments:"
	echo -e "\t TARGET_SITE_NAME the name of the site."
	echo "Example:"
	echo -e "\t $SCRIPT_NAME mysite"
}

if [ -z "$1" ] || [ "$1" == "-help" ]; then
	help
	exit 1
fi

if [ $# -eq 1 ]; then
	export TARGET_SITE_NAME=$1
	export MIGRATION_REPO_DIR=$WORK_DIR/$TARGET_SITE_NAME
	export IMPORT_LOG_PATH=$LOGS_DIR/$TARGET_SITE_NAME-import.log
else
	echo -e "\e[31mWrong number of arguments\e[0m"
	echo
	help
	exit 1
fi

if [ ! -d "$MIGRATION_REPO_DIR" ]; then
	echo -e "\e[31mMigration repo $MIGRATION_REPO_DIR doesn't exist. Please make sure you run the migrate.sh script before running this script\e[0m"
	exit 1
fi

echo "------------------------------------------------------------"
echo "Importing migrated config and content to Studio"
echo "------------------------------------------------------------"

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
echo -e "\e[34mRunning import in background and tailing ($IMPORT_LOG_PATH)\e[0m"
echo

if [ ! -d "$LOGS_DIR" ]; then
	mkdir -p $LOGS_DIR
fi

rm -f $IMPORT_LOG_PATH

nohup $MIGRATION_TOOL_HOME/import-bg.sh > $IMPORT_LOG_PATH 2>&1 &
tail -f $IMPORT_LOG_PATH
