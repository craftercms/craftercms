#!/usr/bin/env bash

# Script to create the Solr core & Deployer target for a delivery environment.

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
	echo -e "\t SITENAME name of the site to be created."
	echo -e "\t REPO_PATH (optional) location of the site content."
	echo -e "\t PRIVATE_KEY (optional) location of the SSH private key."
	echo "Examples:"
	echo -e "\t $SCRIPT_NAME newSite"
	echo -e "\t $SCRIPT_NAME newSite /usr/local/data/repos/sites/newSite/published"
	echo -e "\t $SCRIPT_NAME newSite /usr/local/data/repos/sites/newSite/published /home/admin/.ssh/admin4k"
}

# pre flight check.
if [ -z "$1" ] || [ "$1" == "-help" ]; then
	help
	exit 2
fi

if [ $# -eq 1 ]; then
	SITE=$1
	DELIVERY_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
	DELIVERY_ROOT=$( cd "$DELIVERY_HOME/.." && pwd )
	AUTHORING_ROOT=$( cd "$DELIVERY_ROOT/../crafter-authoring" && pwd )
	REPO=$AUTHORING_ROOT/data/repos/sites/$SITE/published
	PRIVATE_KEY=""
elif [ $# -eq 2 ]; then
	SITE=$1
	REPO=$2
	PRIVATE_KEY=""
elif [ $# -eq 3 ]; then
	SITE=$1
	REPO=$2
	PRIVATE_KEY=',"ssh_private_key_path":"'"$3"'"'
else
	echo "Usage: init-site.sh <site name> [site's published repo git url] [ssh private key path]"
	exit 1
fi

if [[ ! "$REPO" =~ ^ssh.* ]] && [ ! -d "$REPO" ]; then
	echo -e "\033[38;5;196m"
	echo -e "Repository path $REPO for site \"$SITE\" does not exist or cannot to read"
	echo -e "\033[0m"
	exit 4
fi

echo "Creating Solr Core"
curl -s -X POST -H "Content-Type: application/json" -d '{"id":"'"$SITE"'"}' "http://localhost:9080/crafter-search/api/2/admin/index/create"
echo ""

echo "Creating Deployer Target"
curl -s -X POST -H "Content-Type: application/json" -d '{"env":"default", "site_name":"'"$SITE"'", "template_name":"remote", "repo_url":"'"$REPO"'", "repo_branch":"live", "engine_url":"http://localhost:9080" '$PRIVATE_KEY' }' "http://localhost:9192/api/1/target/create"
echo ""

echo "Done"
