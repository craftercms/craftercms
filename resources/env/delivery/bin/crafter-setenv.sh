#!/bin/bash

# Copyright (C) 2007-2019 Crafter Software Corporation. All Rights Reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# -------------------- Locations variables --------------------
export CRAFTER_LOGS_DIR=${CRAFTER_LOGS_DIR:="$CRAFTER_HOME/logs"}
export CRAFTER_DATA_DIR=${CRAFTER_DATA_DIR:="$CRAFTER_HOME/data"}
export CRAFTER_TEMP_DIR=${CRAFTER_TEMP_DIR:="$CRAFTER_HOME/temp"}

# -------------------- Hosts and ports --------------------
export MAIL_HOST=${MAIL_HOST:="localhost"}
export MAIL_PORT=${MAIL_PORT:="@SMTP_PORT@"}
export SOLR_HOST=${SOLR_HOST:="localhost"}
export SOLR_PORT=${SOLR_PORT:="@SOLR_PORT@"}
export ES_HOST=${ES_HOST:="localhost"}
export ES_PORT=${ES_PORT:="@ES_PORT@"}
export DEPLOYER_HOST=${DEPLOYER_HOST:="localhost"}
export DEPLOYER_PORT=${DEPLOYER_PORT:="@DEPLOYER_PORT@"}
export MONGODB_HOST=${MONGODB_HOST:="localhost"}
export MONGODB_PORT=${MONGODB_PORT:="@MONGODB_PORT@"}
export TOMCAT_HOST=${TOMCAT_HOST:="localhost"}
export TOMCAT_HTTP_PORT=${TOMCAT_HTTP_PORT:="@TOMCAT_HTTP_PORT@"}
export TOMCAT_HTTPS_PORT=${TOMCAT_HTTPS_PORT:="@TOMCAT_HTTPS_PORT@"}
export TOMCAT_AJP_PORT=${TOMCAT_AJP_PORT:="@TOMCAT_AJP_PORT@"}
export TOMCAT_SHUTDOWN_PORT=${TOMCAT_SHUTDOWN_PORT:="@TOMCAT_SHUTDOWN_PORT@"}

# -------------------- URLs --------------------
export SOLR_URL=${SOLR_URL:="http://$SOLR_HOST:$SOLR_PORT/solr"}
export ES_URL=${ES_URL:="http://$ES_HOST:$ES_PORT"}
export DEPLOYER_URL=${DEPLOYER_URL:="http://$DEPLOYER_HOST:$DEPLOYER_PORT"}
export ENGINE_URL=${ENGINE_URL:="http://$TOMCAT_HOST:$TOMCAT_HTTP_PORT"}
export SEARCH_URL=${SEARCH_URL:="http://$TOMCAT_HOST:$TOMCAT_HTTP_PORT/crafter-search"}
export PROFILE_URL=${PROFILE_URL:="http://$TOMCAT_HOST:$TOMCAT_HTTP_PORT/crafter-profile"}
export SOCIAL_URL=${SOCIAL_URL:="http://$TOMCAT_HOST:$TOMCAT_HTTP_PORT/crafter-social"}

# -------------------- Java opts --------------------
export SOLR_JAVA_OPTS=${SOLR_JAVA_OPTS:="-server -Xss1024K -Xmx1G"}
export ES_JAVA_OPTS=${ES_JAVA_OPTS:="-server -Xss1024K -Xmx1G"}
export DEPLOYER_JAVA_OPTS=${DEPLOYER_JAVA_OPTS:="-server -Xss1024K -Xmx1G"}
export CATALINA_OPTS=${CATALINA_OPTS:="-server -Xss1024K -Xms1G -Xmx2G"}

# -------------------- Solr variables --------------------
export SOLR_HOME=$CRAFTER_BIN_DIR/solr/server/solr
export SOLR_INDEXES_DIR=$CRAFTER_DATA_DIR/indexes
export SOLR_LOGS_DIR="$CRAFTER_LOGS_DIR/solr"
export SOLR_PID=$SOLR_INDEXES_DIR/solr.pid

# -------------------- Elasticsearch variables --------------------
export ES_HOME=$CRAFTER_BIN_DIR/elasticsearch/bin
export ES_INDEXES_DIR=$CRAFTER_DATA_DIR/indexes-es
export ES_LOGS_DIR="$CRAFTER_LOGS_DIR/elasticsearch"
export ES_PID=$ES_HOME/elasticsearch.pid

# -------------------- Deployer variables --------------------
export DEPLOYER_HOME=$CRAFTER_BIN_DIR/crafter-deployer
export DEPLOYER_DATA_DIR=$CRAFTER_DATA_DIR/deployer
export DEPLOYER_LOGS_DIR=$CRAFTER_LOGS_DIR/deployer
export DEPLOYER_DEPLOYMENTS_DIR=$CRAFTER_DATA_DIR/repos/sites
export DEPLOYER_SDOUT=$DEPLOYER_LOGS_DIR/crafter-deployer.out
export DEPLOYER_PID=$DEPLOYER_HOME/crafter-deployer.pid

# -------------------- MongoDB variables --------------------
export MONGODB_HOME="$CRAFTER_BIN_DIR/mongodb"
export MONGODB_PID="$CRAFTER_DATA_DIR/mongodb/mongod.lock"
export MONGODB_DATA_DIR="$CRAFTER_DATA_DIR/mongodb"
export MONGODB_LOGS_DIR="$CRAFTER_LOGS_DIR/mongodb"

# -------------------- Tomcat variables --------------------
export CATALINA_HOME=$CRAFTER_BIN_DIR/apache-tomcat
export CATALINA_PID=$CATALINA_HOME/tomcat.pid
export CATALINA_LOGS_DIR="$CRAFTER_LOGS_DIR/tomcat"
export CATALINA_OUT=$CATALINA_LOGS_DIR/catalina.out
export CATALINA_TMPDIR=$CRAFTER_TEMP_DIR/tomcat

# Profile variables
export PROFILE_DEPLOY_WAR_PATH="$CATALINA_HOME/webapps/crafter-profile"
export PROFILE_WAR_PATH="$CATALINA_HOME/webapps/crafter-profile.war"

# Git variables
export GIT_CONFIG_NOSYSTEM=true
