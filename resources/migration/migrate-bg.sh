#!/bin/bash

function createdMigrateRepo() {
	echo -e "------------------------------------------------------------"
	echo -e "Create migrate directory"
	echo -e "------------------------------------------------------------"

	if [ -d "$MIGRATE_REPO_DIR" ]; then
		rm -rf $MIGRATE_REPO_DIR
	fi

	mkdir -p $MIGRATE_REPO_DIR
	# Creating new site with site-template
	cp -r $RESOURCES_DIR/site-template/* $MIGRATE_REPO_DIR
	# Changing {siteName} in files with the actual site name
	find $MIGRATE_REPO_DIR -type f -exec sed -i "s/{siteName}/$TARGET_SITE_NAME/g" {} \;
}

function importSingleContentType() {
	srcDir=$1
	targetDir=$2
	contentType=$3

	cp -r $srcDir/$contentType $targetDir

	case $REPLACE_OLD_CONTROLLERS in
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
	contentTypes=($(ls "$srcDir"))

	echo "Copying content types from $srcDir..."

	for contentType in "${contentTypes[@]}"
	do
		importSingleContentType $srcDir $targetDir $contentType $REPLACE_OLD_CONTROLLERS
	done
}

function importContentTypes() {
	srcContentTypesDir=$SRC_STUDIO_CONFIG_DIR/content-types
	srcComponentContentTypesDir=$srcContentTypesDir/component
	srcPageContentTypesDir=$srcContentTypesDir/page
	targetContentTypesDir=$MIGRATE_REPO_DIR/config/studio/content-types
	targetComponentContentTypesDir=$targetContentTypesDir/component
	targetPageContentTypesDir=$targetContentTypesDir/page

	mkdir -p $targetContentTypesDir/component
	mkdir -p $targetContentTypesDir/page

	echo -e "------------------------------------------------------------"
	echo -e "Importing content types"
	echo -e "------------------------------------------------------------"

	importContentTypeCollection $srcComponentContentTypesDir $targetComponentContentTypesDir
	importContentTypeCollection $srcPageContentTypesDir $targetPageContentTypesDir
}

function importConfiguredLists() {
	if [ -d "$SRC_STUDIO_CONFIG_DIR/form-control-config/configured-lists" ]; then
		echo -e "------------------------------------------------------------"
		echo -e "Importing configured lists"
		echo -e "------------------------------------------------------------"

		echo "Copying configured lists from $SRC_STUDIO_CONFIG_DIR/form-control-config/configured-lists"

		if [ ! -d "$MIGRATE_REPO_DIR/config/studio/form-control-config/configured-lists" ]; then
			mkdir -p $MIGRATE_REPO_DIR/config/studio/form-control-config/configured-lists
		fi

		cp -r $SRC_STUDIO_CONFIG_DIR/form-control-config/configured-lists $MIGRATE_REPO_DIR/config/studio/form-control-config
	fi
}

function importContent() {
	echo -e "------------------------------------------------------------"
	echo -e "Importing content"
	echo -e "------------------------------------------------------------"

	ls "$SRC_CONTENT_DIR" | while read folder
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
}

function updateEngineConfig() {
	if [ -f "$SRC_CONTENT_DIR/config/site.xml" ] && [ -f "$MIGRATE_REPO_DIR/config/engine/site-config.xml" ]; then
		echo -e "------------------------------------------------------------"
		echo -e "Updating config/engine/site-config.xml"
		echo -e "------------------------------------------------------------"

		echo "Updating <targeting> configuration..."

		defaultLocale=$(sed -rn 's/\s*<defaultLocale>([^<>]+)<\/defaultLocale>\s*/\1/p' $MIGRATE_REPO_DIR/config/engine/site-config.xml)

		# Update config fields
		sed -i 's/i10n/targeting/g' $MIGRATE_REPO_DIR/config/engine/site-config.xml
		sed -i 's/localizedPaths/rootFolders/g' $MIGRATE_REPO_DIR/config/engine/site-config.xml
		sed -i 's/forceCurrentLocale/redirectToTargetedUrl/g' $MIGRATE_REPO_DIR/config/engine/site-config.xml
		sed -i 's/defaultLocale/fallbackTargetId/g' $MIGRATE_REPO_DIR/config/engine/site-config.xml
		# Add default locale
		sed -i "s/<site>/<site>\n\n\t<defaultLocale>$defaultLocale<\/defaultLocale>/g" $MIGRATE_REPO_DIR/config/engine/site-config.xml

		echo "Disabling full content model type conversion for compatibility with 2.5..."

		# Up to and including version 2:
		# Crafter Engine, in the FreeMarker host only, converts model elements based on a suffix type hint, but only for the first level in
		# the model, and not for _dt. For example, for contentModel.myvalue_i Integer is returned, but for contentModel.repeater.myvalue_i
		# and contentModel.date_dt a String is returned. In the Groovy host no type of conversion was performed.
		#
		# In version 3 onwards, Crafter Engine converts elements with any suffix type hints (including _dt) at at any level in the content
		# model and for both Freemarker and Groovy hosts.
		sed -i "s/<site>/<site>\n\n\t<compatibility>\n\t\t<disableFullModelTypeConversion>true<\/disableFullModelTypeConversion>\n\t<\/compatibility>/g" $MIGRATE_REPO_DIR/config/engine/site-config.xml
	fi
}

function updateDatesInDescriptors() {
	echo -e "------------------------------------------------------------"
	echo -e "Updating dates in XML descriptors"
	echo -e "------------------------------------------------------------"

	echo "Updating dates in XML descriptors..."
	find $MIGRATE_REPO_DIR/site -type f -name '*.xml' -exec sed -i -r 's/([0-9]{1,2})\/([0-9]{1,2})\/([0-9]{4}) ([0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2})/\3-\1-\2T\4.000Z/g' {} \;
}

function commitFiles() {
	echo -e "------------------------------------------------------------"
	echo -e "Setting up migrate directory as Git repo"
	echo -e "------------------------------------------------------------"

	cd $MIGRATE_REPO_DIR

	echo "Initializing Git repo..."
	git init

	count=0

	echo -n "Committing files..."

	git ls-files --others --exclude-standard | while read file
	do
		git add "$file"

		((count++))

		if ! ((count % $COMMIT_EVERY)); then
			git commit -m "Committing migrated files" --quiet
			echo -n "$count..."
		fi
	done

	# Commit remaining files
	git commit -m "Committing migrated files" --quiet

	echo
	echo "Total files committed: $count"

	cd $CURRENT_DIR
}

function createSite() {
	echo -e "------------------------------------------------------------"
	echo -e "Creating site in Studio"
	echo -e "------------------------------------------------------------"

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
	requestBody="{\"username\":\"$STUDIO_USERNAME\",\"password\":\"$STUDIO_PASSWORD\"}"

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

function checkDateFormatInCode() {
	echo -e "------------------------------------------------------------"
	echo -e "Checking date formats in code"
	echo -e "------------------------------------------------------------"

	echo "NOTE: If you're parsing dates from the content model in Freemarker or Groovy you need to change the pattern from the old date pattern "
	echo "MM/dd/yyyy HH:mm:ss to the new one, yyyy-MM-dd'T'HH:mm:ss.SSSX. The following are the files found with the old date pattern. Be sure "
	echo "that you're not changing a date pattern that is used to format a date that is displayed in the view."
	echo

	if [ -d "$MIGRATE_REPO_DIR/templates" ]; then
		grep -rn "MM/dd/yyyy HH:mm:ss" $MIGRATE_REPO_DIR/templates
	fi

	if [ -d "$MIGRATE_REPO_DIR/scripts" ]; then
		grep -rn "MM/dd/yyyy HH:mm:ss" $MIGRATE_REPO_DIR/scripts
	fi

}

createdMigrateRepo
importContentTypes
importConfiguredLists
importContent
updateEngineConfig
updateDatesInDescriptors
commitFiles
createSite
checkDateFormatInCode > $DATE_FORMAT_SEARCH_RESULTS_PATH

echo "Migration completed"
