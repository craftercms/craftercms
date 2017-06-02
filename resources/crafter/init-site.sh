#!/usr/bin/env bash

# Script to create the solr core & deployer target for a delivery environment.

if [ $# -lt 2 ]; then
	echo "Usage: init-site.sh [site name] [git repo path]"
	exit 1
fi

SITE=$1
REPO=$2

echo "Creating Solr Core"
curl -s -X POST -H "Content-Type: application/json" -d '{"id":"'"$SITE"'"}' "http://localhost:@TOMCAT_HTTP_PORT@/crafter-search/api/2/admin/index/create"

echo "Creating Deployer Target"
curl -s -X POST -H "Content-Type: application/json" -d '{"env":"default", "site_name":"'"$SITE"'", "template_name":"remote", "repo_url":"'"$REPO"'", "repo_branch":"live", "engine_url":"http://localhost:@TOMCAT_HTTP_PORT@" }' "http://localhost:@DEPLOYER_PORT@/api/1/target/create"

echo "Done"
