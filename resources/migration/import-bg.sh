#!/bin/bash

function importSite() {
	echo "------------------------------------------------------------"
	echo "Importing site into Studio"
	echo "------------------------------------------------------------"

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

	remoteUrl=$(cd "$MIGRATION_REPO_DIR" && pwd)
	requestBody="{\"site_id\":\"$TARGET_SITE_NAME\",\"description\":\"$TARGET_SITE_NAME\",\"use_remote\":true,\"remote_url\":\"$remoteUrl\",\"remote_name\":\"origin\",\"create_option\":\"clone\"}"

	echo -n "Creating site... "
	status=$(curl -s -o /dev/null -w "%{http_code}" -d "$requestBody" --cookie "$COOKIE_JAR" --cookie-jar "$COOKIE_JAR" --header "X-XSRF-TOKEN:$csrfToken" --header "Content-Type: application/json" -X POST "$CREATE_SITE_URL")
	echo "Response status: $status"
}

startTime=$SECONDS

importSite

duration=$((SECONDS - startTime))

echo "Import completed in $duration seconds"
