#!/usr/bin/env bash

# Script to remove a site from a delivery environment.

if [ "$(whoami)" == "root" ]; then
	echo -e "\033[38;5;196m"
	echo -e "Crafter CMS cowardly refuses to run as root."
	echo -e "Running as root is dangerous and is not supported."
	echo -e "\033[0m"
	exit 1
fi

SCRIPT_NAME=$(basename "$0")

function help(){
	echo "$SCRIPT_NAME"
	echo "Arguments:"
	echo -e "\t SITENAME name of the site to be removed."
	echo "Examples:"
	echo -e "\t $SCRIPT_NAME newSite"
}

# pre flight check.
if [ -z "$1" ] || [ "$1" == "-help" ]; then
	help
	exit 2
fi

DELIVERY_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "$DELIVERY_HOME/crafter-setenv.sh"

if [ $# -eq 1 ]; then
	SITE=$1
	DELIVERY_ROOT=$( cd "$DELIVERY_HOME/.." && pwd )
	REPO=$DELIVERY_ROOT/data/repos/sites/$SITE
else
	echo "Usage: remove-site.sh <site name>"
	exit 1
fi

if [ ! -d "$REPO" ]; then
	echo -e "\033[38;5;196m"
	echo -e "Repository path $REPO for site \"$SITE\" does not exist or cannot be read"
	echo -e "\033[0m"
	exit 4
fi

read -p "This operation can not be undone, delete all files and configuration for site '$SITE'? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo "Removing Solr Core"
  curl -s -X POST -H "Content-Type: application/json" \
        -d '{"delete_mode":"ALL_DATA_AND_CONFIG"}' \
        "http://localhost:$TOMCAT_HTTP_PORT/crafter-search/api/2/admin/index/delete/$SITE"
  echo ""

  echo "Removing Deployer Target"
  curl -s -X POST -H "Content-Type: application/json" "http://localhost:$DEPLOYER_PORT/api/1/target/delete/default/$SITE"
  echo ""

  echo "Removing Git Repository"
  rm -rf "$REPO"
  echo ""

  echo "Done"
fi
