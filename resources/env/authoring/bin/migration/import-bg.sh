#!/bin/bash

function doCurl() {
	# store the whole response with the status at the end
	command="curl --silent --write-out \"XHTTPSTATUS:%{http_code}\" $1"
	response=$(eval $command)
	exitCode=$?

	if [ $exitCode != 0 ]; then
		echo "Curl failed with exit code: $exitCode"
		exit 1
	fi

	# extract the status
	status=$(echo "$response" | sed 's/^.*XHTTPSTATUS://')
	# extract the body
	body=$(echo "$response" | sed 's/XHTTPSTATUS\:.*$//g')

	#echo "=> $command"
	echo "=> Response status: $status"
	echo "=> Response body: $body"

	if [[ $status != 2* ]] ; then
		echo "Server returned a non-success code. Unable to continue"
		exit 1
	fi
}

function importSite() {
	echo "------------------------------------------------------------"
	echo "Importing site into Studio"
	echo "------------------------------------------------------------"

	rm -f $COOKIE_JAR

	echo
	echo "Getting CSRF token... "
	doCurl "--cookie-jar '$COOKIE_JAR' '$GET_CSRF_TOKEN_URL'"

	csrfToken=$(grep XSRF-TOKEN $COOKIE_JAR | sed 's/^.*XSRF-TOKEN\s*//')
	requestBody="{\"username\":\"$STUDIO_USERNAME\",\"password\":\"$STUDIO_PASSWORD\"}"

	echo "Login to Studio... "
	doCurl "-d '$requestBody' --cookie '$COOKIE_JAR' --cookie-jar '$COOKIE_JAR' --header 'X-XSRF-TOKEN:$csrfToken' --header 'Content-Type: application/json' -X POST '$LOGIN_URL'"

	remoteUrl=$(cd "$MIGRATION_REPO_DIR" && pwd)
	requestBody="{\"site_id\":\"$TARGET_SITE_NAME\",\"description\":\"$TARGET_SITE_NAME\",\"authentication_type\":\"none\",\"use_remote\":true,\"remote_url\":\"$remoteUrl\",\"remote_name\":\"origin\",\"create_option\":\"clone\"}"

	echo "Creating site... "
	doCurl "-d '$requestBody' --cookie '$COOKIE_JAR' --cookie-jar '$COOKIE_JAR' --header 'X-XSRF-TOKEN:$csrfToken' --header 'Content-Type: application/json' -X POST '$CREATE_SITE_URL'"
}

startTime=$SECONDS

importSite

duration=$((SECONDS - startTime))

echo "Import completed in $duration seconds"
