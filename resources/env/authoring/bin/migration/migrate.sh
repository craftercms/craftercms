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
	export MIGRATION_REPO_DIR=$WORK_DIR/$TARGET_SITE_NAME
	export MIGRATION_LOG_PATH=$LOGS_DIR/$TARGET_SITE_NAME-migration.log
else
	echo -e "\e[31mWrong number of arguments\e[0m"
	echo
	help
	exit 1
fi

echo "--------------------------------------------------------------------"
echo "Migrating Studio 2.5 config and content to 3.0 compatible repository"
echo "--------------------------------------------------------------------"

read -p "Replace old content type controllers (controller.js, extract.js, extract.groovy and controller.groovy) with latest controllers (not recommended if you have custom code in the controllers)? [y/n]: " REPLACE_OLD_CONTROLLERS
export REPLACE_OLD_CONTROLLERS

echo
echo -e "\e[34mRunning migration in background and tailing ($MIGRATION_LOG_PATH)\e[0m"
echo

if [ ! -d "$LOGS_DIR" ]; then
	mkdir -p $LOGS_DIR
fi

rm -f $MIGRATION_LOG_PATH

nohup $MIGRATION_TOOL_HOME/migrate-bg.sh > $MIGRATION_LOG_PATH 2>&1 &
tail -f $MIGRATION_LOG_PATH
