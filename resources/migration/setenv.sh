#!/bin/bash

export MIGRATION_TOOL_HOME=${MIGRATION_TOOL_HOME:=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )}
export CRAFTER_HOME=${CRAFTER_HOME:=$( cd "$MIGRATION_TOOL_HOME/.." && pwd )}
export CRAFTER_ROOT=${CRAFTER_ROOT:=$( cd "$CRAFTER_HOME/.." && pwd )}
export RESOURCES_DIR=${RESOURCES_DIR:=$MIGRATION_TOOL_HOME/resources}
export WORK_DIR=${WORK_DIR:=$CRAFTER_ROOT/data/migration}
export LOGS_DIR=${LOGS_DIR:=$CRAFTER_ROOT/logs/migration}
export CURRENT_DIR=$(pwd)
export COMMIT_EVERY=20
export STUDIO_PORT=${STUDIO_PORT:=@TOMCAT_HTTP_PORT}
export STUDIO_URL=${STUDIO_URL:="http://localhost:$STUDIO_PORT/studio"}
export GET_CSRF_TOKEN_URL=$STUDIO_URL/api/1/services/api/1/server/get-available-languages.json
export LOGIN_URL=$STUDIO_URL/api/1/services/api/1/security/login.json
export CREATE_SITE_URL=$STUDIO_URL/api/1/services/api/1/site/create.json
export COOKIE_JAR=$WORK_DIR/cookies.txt
