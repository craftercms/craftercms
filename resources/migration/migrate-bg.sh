#!/bin/bash

if [ "$(uname -s)" == "Darwin" ]; then
  GNU=0
else
  GNU=1
fi

function createMigrationRepo() {
	echo "------------------------------------------------------------"
	echo "Creating migration directory"
	echo "------------------------------------------------------------"

	if [ -d "$MIGRATION_REPO_DIR" ]; then
		rm -rf $MIGRATION_REPO_DIR
	fi

	mkdir -p $MIGRATION_REPO_DIR
	# Creating new site with site-template
	cp -r $RESOURCES_DIR/site-template/* $MIGRATION_REPO_DIR
	# Changing {siteName} in files with the actual site name
  if [ $GNU -eq 1 ]; then
    find $MIGRATION_REPO_DIR -type f -exec sed -i "s/{siteName}/$TARGET_SITE_NAME/g" {} \;
  else
    find $MIGRATION_REPO_DIR -type f -exec sed -i '' "s/{siteName}/$TARGET_SITE_NAME/g" {} \;
  fi
}

function copySingleContentType() {
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

function copyContentTypeCollection() {
	srcDir=$1
	targetDir=$2
	contentTypes=($(ls "$srcDir"))

	echo "Copying content types from $srcDir..."

	for contentType in "${contentTypes[@]}"
	do
		copySingleContentType $srcDir $targetDir $contentType $REPLACE_OLD_CONTROLLERS
	done
}

function copyContentTypes() {
	srcContentTypesDir=$SRC_STUDIO_CONFIG_DIR/content-types
	srcComponentContentTypesDir=$srcContentTypesDir/component
	srcPageContentTypesDir=$srcContentTypesDir/page
	targetContentTypesDir=$MIGRATION_REPO_DIR/config/studio/content-types
	targetComponentContentTypesDir=$targetContentTypesDir/component
	targetPageContentTypesDir=$targetContentTypesDir/page

	mkdir -p $targetContentTypesDir/component
	mkdir -p $targetContentTypesDir/page

	echo "------------------------------------------------------------"
	echo "Copying content types"
	echo "------------------------------------------------------------"

	copyContentTypeCollection $srcComponentContentTypesDir $targetComponentContentTypesDir
	copyContentTypeCollection $srcPageContentTypesDir $targetPageContentTypesDir
}

function copyConfiguredLists() {
	if [ -d "$SRC_STUDIO_CONFIG_DIR/form-control-config/configured-lists" ]; then
		echo "------------------------------------------------------------"
		echo "Copying configured lists"
		echo "------------------------------------------------------------"

		echo "Copying configured lists from $SRC_STUDIO_CONFIG_DIR/form-control-config/configured-lists"

		if [ ! -d "$MIGRATION_REPO_DIR/config/studio/form-control-config/configured-lists" ]; then
			mkdir -p $MIGRATION_REPO_DIR/config/studio/form-control-config/configured-lists
		fi

		cp -r $SRC_STUDIO_CONFIG_DIR/form-control-config/configured-lists $MIGRATION_REPO_DIR/config/studio/form-control-config
	fi
}

function copyContent() {
	echo "------------------------------------------------------------"
	echo "Copying content"
	echo "------------------------------------------------------------"

	ls "$SRC_CONTENT_DIR" | while read folder
	do
		if [ $folder != "config" ] && [ $folder != "classes" ];
		then
			folderPath=$SRC_CONTENT_DIR/$folder

			echo "Copying $folderPath folder to $MIGRATION_REPO_DIR/$folder..."
			cp -r $folderPath $MIGRATION_REPO_DIR
		fi
	done

	if [ -d "$SRC_CONTENT_DIR/classes/groovy" ]; then
		echo "Copying $SRC_CONTENT_DIR/classes/groovy to $MIGRATION_REPO_DIR/scripts/classes..."

		if [ ! -d "$MIGRATION_REPO_DIR/scripts" ]; then
			mkdir -p $MIGRATION_REPO_DIR/scripts
		fi

		cp -r $SRC_CONTENT_DIR/classes/groovy $MIGRATION_REPO_DIR/scripts/classes
	fi

	if [ -f "$SRC_CONTENT_DIR/config/site.xml" ]; then
		echo "Copying $SRC_CONTENT_DIR/config/site.xml to $MIGRATION_REPO_DIR/config/engine/site-config.xml..."

		if [ ! -d "$MIGRATION_REPO_DIR/config/engine" ]; then
			mkdir -p $MIGRATION_REPO_DIR/config/engine
		fi

		cp $SRC_CONTENT_DIR/config/site.xml $MIGRATION_REPO_DIR/config/engine/site-config.xml
	fi

	if [ -f "$SRC_CONTENT_DIR/config/spring/application-context.xml" ]; then
		echo "Copying $SRC_CONTENT_DIR/config/spring/application-context.xml to $MIGRATION_REPO_DIR/config/engine/application-context.xml..."

		if [ ! -d "$MIGRATION_REPO_DIR/config/engine" ]; then
			mkdir -p $MIGRATION_REPO_DIR/config/engine
		fi

		cp $SRC_CONTENT_DIR/config/spring/application-context.xml $MIGRATION_REPO_DIR/config/engine/application-context.xml
	fi
}

function updateEngineConfig() {
	if [ -f "$SRC_CONTENT_DIR/config/site.xml" ] && [ -f "$MIGRATION_REPO_DIR/config/engine/site-config.xml" ]; then
		echo "------------------------------------------------------------"
		echo "Updating config/engine/site-config.xml"
		echo "------------------------------------------------------------"

		echo "Updating <targeting> configuration..."

    if [ $GNU -eq 1 ]; then
      defaultLocale=$(sed -rn 's/\s*<defaultLocale>([^<>]+)<\/defaultLocale>\s*/\1/p' $MIGRATION_REPO_DIR/config/engine/site-config.xml)
    else
      defaultLocale=$(sed -En 's/\s*<defaultLocale>([^<>]+)<\/defaultLocale>\s*/\1/p' $MIGRATION_REPO_DIR/config/engine/site-config.xml)
    fi

		# Update config fields
    if [ $GNU -eq 1 ]; then
      sed -i 's/i10n/targeting/g' $MIGRATION_REPO_DIR/config/engine/site-config.xml
      sed -i 's/localizedPaths/rootFolders/g' $MIGRATION_REPO_DIR/config/engine/site-config.xml
      sed -i 's/forceCurrentLocale/redirectToTargetedUrl/g' $MIGRATION_REPO_DIR/config/engine/site-config.xml
      sed -i 's/defaultLocale/fallbackTargetId/g' $MIGRATION_REPO_DIR/config/engine/site-config.xml
      # Add default locale
      sed -i "s/<site>/<site>\n\n\t<defaultLocale>$defaultLocale<\/defaultLocale>/g" $MIGRATION_REPO_DIR/config/engine/site-config.xml
    else
      sed -i '' 's/i10n/targeting/g' $MIGRATION_REPO_DIR/config/engine/site-config.xml
      sed -i '' 's/localizedPaths/rootFolders/g' $MIGRATION_REPO_DIR/config/engine/site-config.xml
      sed -i '' 's/forceCurrentLocale/redirectToTargetedUrl/g' $MIGRATION_REPO_DIR/config/engine/site-config.xml
      sed -i '' 's/defaultLocale/fallbackTargetId/g' $MIGRATION_REPO_DIR/config/engine/site-config.xml
      # Add default locale
      sed -i '' "s/<site>/<site>\n\n\t<defaultLocale>$defaultLocale<\/defaultLocale>/g" $MIGRATION_REPO_DIR/config/engine/site-config.xml
    fi

		echo "Disabling full content model type conversion for compatibility with 2.5..."

		# Up to and including version 2:
		# Crafter Engine, in the FreeMarker host only, converts model elements based on a suffix type hint, but only for the first level in
		# the model, and not for _dt. For example, for contentModel.myvalue_i Integer is returned, but for contentModel.repeater.myvalue_i
		# and contentModel.date_dt a String is returned. In the Groovy host no type of conversion was performed.
		#
		# In version 3 onwards, Crafter Engine converts elements with any suffix type hints (including _dt) at at any level in the content
		# model and for both Freemarker and Groovy hosts.
    if [ $GNU -eq 1 ]; then
      sed -i "s/<site>/<site>\n\n\t<compatibility>\n\t\t<disableFullModelTypeConversion>true<\/disableFullModelTypeConversion>\n\t<\/compatibility>/g" $MIGRATION_REPO_DIR/config/engine/site-config.xml
    else
      sed -i '' "s/<site>/<site>\n\n\t<compatibility>\n\t\t<disableFullModelTypeConversion>true<\/disableFullModelTypeConversion>\n\t<\/compatibility>/g" $MIGRATION_REPO_DIR/config/engine/site-config.xml
    fi
	fi
}

function updateDatesInDescriptors() {
	echo "------------------------------------------------------------"
	echo "Updating dates in XML descriptors"
	echo "------------------------------------------------------------"

	echo "Updating dates in XML descriptors..."
  if [ $GNU -eq 1 ]; then
    find $MIGRATION_REPO_DIR/site -type f -name '*.xml' -exec sed -i -r 's/([0-9]{1,2})\/([0-9]{1,2})\/([0-9]{4}) ([0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2})/\3-\1-\2T\4.000Z/g' {} \;
  else
    find $MIGRATION_REPO_DIR/site -type f -name '*.xml' -exec sed -i '' -E 's/([0-9]{1,2})\/([0-9]{1,2})\/([0-9]{4}) ([0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2})/\3-\1-\2T\4.000Z/g' {} \;
  fi
}

function commitFiles() {
	echo "------------------------------------------------------------"
	echo "Setting up migrate directory as Git repo"
	echo "------------------------------------------------------------"

	cd $MIGRATION_REPO_DIR

	echo "Initializing Git repo..."
	git init

	git config core.bigFileThreshold 20m
	git config core.compression 0
	git config core.fileMode false
	git update-index

	count=0

	echo -n "Committing files..."

	git ls-files --others --exclude-standard | {
		while read file
		do
			git add "$file"

			((count++))

			if ! ((count % COMMIT_EVERY)); then
				git commit -m "Committing migrated files" --quiet
				echo -n "$count..."
			fi
		done

		# Commit remaining files
		git commit -m "Committing migrated files" --quiet

		echo
		echo "Total files committed: $count"
	}

	cd $CURRENT_DIR
}

function checkDateFormatInCode() {
	echo "------------------------------------------------------------"
	echo "Checking date formats in code"
	echo "------------------------------------------------------------"

	echo "NOTE: If you're parsing dates from the content model in Freemarker or Groovy you need to change the pattern from the old date pattern "
	echo "MM/dd/yyyy HH:mm:ss to the new one, yyyy-MM-dd'T'HH:mm:ss.SSSX. The following are the files found with the old date pattern. Be sure "
	echo "that you're not changing a date pattern that is used to format a date that is displayed in the view."
	echo

	if [ -d "$MIGRATION_REPO_DIR/templates" ]; then
		grep -rn "MM/dd/yyyy HH:mm:ss" $MIGRATION_REPO_DIR/templates
	fi

	if [ -d "$MIGRATION_REPO_DIR/scripts" ]; then
		grep -rn "MM/dd/yyyy HH:mm:ss" $MIGRATION_REPO_DIR/scripts
	fi

}

function checkWorkingCopies() {
	echo "------------------------------------------------------------"
	echo "Checking working copies in content"
	echo "------------------------------------------------------------"
	
	echo "NOTE: If there are any 'working copy' files you will need to decide whether to discard them or replace the"
	echo "original files and commit the changes before importing the migrated site."
	echo
	
	if [ -d "$MIGRATION_REPO_DIR/site" ]; then
		find "$MIGRATION_REPO_DIR" -name '*(Working Copy)*'
	fi
}

startTime=$SECONDS

createMigrationRepo
copyContentTypes
copyConfiguredLists
copyContent
updateEngineConfig
updateDatesInDescriptors
commitFiles
checkDateFormatInCode
checkWorkingCopies

duration=$((SECONDS - startTime))

echo "Migration completed in $duration seconds"
