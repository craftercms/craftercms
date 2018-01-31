#!/usr/bin/env bash

MIGRATION_TOOL_HOME=${MIGRATION_TOOL_HOME:=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )}
CRAFTER_HOME=${CRAFTER_HOME:=$( cd "$MIGRATION_TOOL_HOME/.." && pwd )}
CRAFTER_ROOT=${CRAFTER_ROOT:=$( cd "$CRAFTER_HOME/.." && pwd )}
RESOURCES_DIR=${RESOURCES_DIR:=$MIGRATION_TOOL_HOME/resources}
WORK_DIR=${WORK_DIR:=$CRAFTER_ROOT/data/migration}
SCRIPT_NAME=$(basename "$0")
CURRENT_DIR=$(pwd)
STUDIO_PORT=${STUDIO_PORT:=@TOMCAT_HTTP_PORT@}
STUDIO_URL=${STUDIO_URL:="http://localhost:$STUDIO_PORT/studio"}
GET_CSRF_TOKEN_URL=$STUDIO_URL/api/1/services/api/1/server/get-available-languages.json
LOGIN_URL=$STUDIO_URL/api/1/services/api/1/security/login.json
CREATE_SITE_URL=$STUDIO_URL/api/1/services/api/1/site/create.json
COOKIE_JAR=$WORK_DIR/cookies.txt

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
	TARGET_SITE_NAME=$1
	SRC_STUDIO_CONFIG_DIR=$2
	SRC_CONTENT_DIR=$3
	MIGRATE_REPO_DIR=$WORK_DIR/$TARGET_SITE_NAME
else
	echo -e "\e[31mWrong number of arguments\e[0m"
	echo
	help
	exit 1
fi

function setupMigrateRepo() {
	if [ -d "$MIGRATE_REPO_DIR" ]; then
		rm -rf $MIGRATE_REPO_DIR
	fi

	echo "Setting up temporary migrate repository $MIGRATE_REPO_DIR"

	mkdir -p $MIGRATE_REPO_DIR
	# Creating new site with site-template
	cp -r $RESOURCES_DIR/site-template/* $MIGRATE_REPO_DIR
	# Changing {siteName} in files with the actual site name
	find $MIGRATE_REPO_DIR -type f -exec sed -i "s/{siteName}/$TARGET_SITE_NAME/g" {} \;

	cd $MIGRATE_REPO_DIR
	git init
	git add .
	git commit -m "Migrate repo created"
	cd $CURRENT_DIR
}

function importSingleContentType() {
	srcDir=$1
	targetDir=$2
	contentType=$3
	replaceOldControllers=$4

	cp -r $srcDir/$contentType $targetDir

	case $replaceOldControllers in
		[Yy]*)
			rm -f $targetDir/$contentType/controller.js
			rm -f $targetDir/$contentType/extract.js
			rm -f $targetDir/$contentType/controller.groovy
			rm -f $targetDir/$contentType/extract.groovy
			cp $RESOURCES_DIR/content-types/controller.groovy  $targetDir/$contentType
			;;
	esac
}

function importContentTypeCollection() {
	srcDir=$1
	targetDir=$2
	replaceOldControllers=$3
	contentTypes=($(ls "$srcDir"))

	echo "Copying content types from $srcDir..."

	for contentType in "${contentTypes[@]}"
	do
		importSingleContentType $srcDir $targetDir $contentType $replaceOldControllers
	done
}

function importContentTypes() {
	srcContentTypesDir=$SRC_STUDIO_CONFIG_DIR/content-types
	srcComponentContentTypesDir=$srcContentTypesDir/component
	srcPageContentTypesDir=$srcContentTypesDir/page
	targetContentTypesDir=$MIGRATE_REPO_DIR/config/studio/content-types
	targetComponentContentTypesDir=$targetContentTypesDir/component
	targetPageContentTypesDir=$targetContentTypesDir/page

	echo -e "\e[34m------------------------------------------------------------\e[0m"
	echo -e "\e[34mImporting content types"
	echo -e "\e[34m------------------------------------------------------------\e[0m"

	read -p "Replace old controllers (controller.js, extract.js, extract.groovy and controller.groovy) with latest controllers (not recommended if you have custom code in the controllers)? [y/n]: " replaceOldControllers

	importContentTypeCollection $srcComponentContentTypesDir $targetComponentContentTypesDir $replaceOldControllers
	importContentTypeCollection $srcPageContentTypesDir $targetPageContentTypesDir $replaceOldControllers

	cd $MIGRATE_REPO_DIR
	git add .
	git commit -m "Imported content types"
	cd $CURRENT_DIR
}

function importConfiguredLists() {
	if [ -d "$SRC_STUDIO_CONFIG_DIR/form-control-config/configured-lists" ]; then
		echo -e "\e[34m------------------------------------------------------------\e[0m"
		echo -e "\e[34mImporting configured lists"
		echo -e "\e[34m------------------------------------------------------------\e[0m"

		echo "Copying configured lists from $SRC_STUDIO_CONFIG_DIR/form-control-config/configured-lists"

		if [ ! -d "$MIGRATE_REPO_DIR/config/studio/form-control-config/configured-lists" ]; then
			mkdir -p $MIGRATE_REPO_DIR/config/studio/form-control-config/configured-lists
		fi

		cp -r $SRC_STUDIO_CONFIG_DIR/form-control-config/configured-lists $MIGRATE_REPO_DIR/config/studio/form-control-config/configured-lists

		cd $MIGRATE_REPO_DIR
		git add .
		git commit -m "Imported configured lists"
		cd $MIGRATE_REPO_DIR
	fi
}

function importContent() {
	echo -e "\e[34m------------------------------------------------------------\e[0m"
	echo -e "\e[34mImporting content"
	echo -e "\e[34m------------------------------------------------------------\e[0m"

	srcContentFolders=($(ls "$SRC_CONTENT_DIR"))

	for folder in "${srcContentFolders[@]}"
	do
		if [ $folder != "config" ] && [ $folder != "classes" ];
		then
			folderPath=$SRC_CONTENT_DIR/$folder

			echo "Copying $folderPath folder to $MIGRATE_REPO_DIR/$folder..."
			cp -r $folderPath $MIGRATE_REPO_DIR
		fi
	done

	if [ -d "$SRC_CONTENT_DIR/classes/groovy" ]; then
		echo "Copying $SRC_CONTENT_DIR/classes/groovy to $MIGRATE_REPO_DIR/scripts/classes..."

		if [ ! -d "$MIGRATE_REPO_DIR/scripts" ]; then
			mkdir -p $MIGRATE_REPO_DIR/scripts
		fi

		cp -r $SRC_CONTENT_DIR/classes/groovy $MIGRATE_REPO_DIR/scripts/classes
	fi

	if [ -f "$SRC_CONTENT_DIR/config/site.xml" ]; then
		echo "Copying $SRC_CONTENT_DIR/config/site.xml to $MIGRATE_REPO_DIR/config/engine/site-config.xml..."

		if [ ! -d "$MIGRATE_REPO_DIR/config/engine" ]; then
			mkdir -p $MIGRATE_REPO_DIR/config/engine
		fi

		cp $SRC_CONTENT_DIR/config/site.xml $MIGRATE_REPO_DIR/config/engine/site-config.xml
	fi

	if [ -f "$SRC_CONTENT_DIR/config/spring/application-context.xml" ]; then
		echo "Copying $SRC_CONTENT_DIR/config/spring/application-context.xml to $MIGRATE_REPO_DIR/config/engine/application-context.xml..."

		if [ ! -d "$MIGRATE_REPO_DIR/config/engine" ]; then
			mkdir -p $MIGRATE_REPO_DIR/config/engine
		fi

		cp $SRC_CONTENT_DIR/config/spring/application-context.xml $MIGRATE_REPO_DIR/config/engine/application-context.xml
	fi

	cd $MIGRATE_REPO_DIR
	git add .
	git commit -m "Imported content"
	cd $CURRENT_DIR
}

function updateDateFormat() {
	echo -e "\e[34m------------------------------------------------------------\e[0m"
	echo -e "\e[34mUpdating date format"
	echo -e "\e[34m------------------------------------------------------------\e[0m"

	echo "NOTE: This process only changes the format of stored dates in XML descriptors. If you're referencing _dt variables in Freemarker and Groovy be sure "
	echo "to follow the Upgrade to Crafter CMS 3.0.x from 2.5.x guide for how to update the code."

	find $MIGRATE_REPO_DIR/site -type f -name '*.xml' -exec sed -i -E 's/([0-9]+)\/([0-9]+)\/([0-9]{4}) ([0-9]+:[0-9]+:[0-9]+)/\3-\1-\2T\4.000Z/g' {} \;

	cd $MIGRATE_REPO_DIR
	git add .
	git commit -m "Updated date format of XML descriptors"
	cd $CURRENT_DIR
}

function createSite() {
	echo -e "\e[34m------------------------------------------------------------\e[0m"
	echo -e "\e[34mCreating site"
	echo -e "\e[34m------------------------------------------------------------\e[0m"

	echo "NOTE: This final part involves the site creation in Studio. We recommend you to tail the Studio log to see when the creation process has finished "
	echo "and to catch any possible errors."

	read -p "Enter Studio username: " username

	if [ -z "$username" ]; then
		echo -e "\e[31mUsername can't be empty\e[0m"
		exit 1
	fi

	read -s -p "Enter Studio password: " password

	if [ -z "$password" ]; then
		echo -e "\e[31mPassword can't be empty\e[0m"
		exit 1
	fi

	rm -f $COOKIE_JAR

	echo
	echo -n "Getting CSRF token... "
	status=$(curl -s -o /dev/null -w "%{http_code}" --cookie-jar "$COOKIE_JAR" "$GET_CSRF_TOKEN_URL")
	echo "Response status: $status"

	if [ "$status" != "200" ]; then
		echo "HTTP call failed. Unable to continue"
		exit 1
	fi

	csrfToken=$(grep XSRF-TOKEN $COOKIE_JAR | sed 's/^.*XSRF-TOKEN\s*//')
	requestBody="{\"username\":\"admin\",\"password\":\"admin\"}"

	echo -n "Login to Studio... "
	status=$(curl -s -o /dev/null -w "%{http_code}" -d "$requestBody" --cookie "$COOKIE_JAR" --cookie-jar "$COOKIE_JAR" --header "X-XSRF-TOKEN:$csrfToken" --header "Content-Type: application/json" -X POST "$LOGIN_URL")
	echo "Response status: $status"

	if [ "$status" != "200" ]; then
		echo "HTTP call failed. Unable to continue"
		exit 1
	fi

	remoteUrl=$(cd "$MIGRATE_REPO_DIR" && pwd)
	requestBody="{\"site_id\":\"$TARGET_SITE_NAME\",\"description\":\"$TARGET_SITE_NAME\",\"use_remote\":true,\"remote_url\":\"$remoteUrl\",\"remote_name\":\"origin\",\"create_option\":\"clone\"}"

	echo -n "Creating site... "
	status=$(curl -s -o /dev/null -w "%{http_code}" -d "$requestBody" --cookie "$COOKIE_JAR" --cookie-jar "$COOKIE_JAR" --header "X-XSRF-TOKEN:$csrfToken" --header "Content-Type: application/json" -X POST "$CREATE_SITE_URL")
	echo "Response status: $status"
}

setupMigrateRepo
importContentTypes
importConfiguredLists
importContent
updateDateFormat
createSite
