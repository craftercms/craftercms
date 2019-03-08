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

# Locations variables
export CRAFTER_LOGS_DIR=${CRAFTER_LOGS_DIR:="$CRAFTER_HOME/logs"}
export CRAFTER_DATA_DIR=${CRAFTER_DATA_DIR:="$CRAFTER_HOME/data"}

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

# -------------------- Solr variables --------------------
export SOLR_HOME=$CRAFTER_BIN_DIR/solr/server/solr
export SOLR_INDEXES_DIR=$CRAFTER_DATA_DIR/indexes
export SOLR_LOGS_DIR="$CRAFTER_LOGS_DIR/solr"
export SOLR_PID=$SOLR_INDEXES_DIR/solr.pid
export SOLR_JAVA_OPTS="-server -Xss1024K -Xmx1G"

# -------------------- ElasticSearch variables --------------------
export ES_HOME=$CRAFTER_BIN_DIR/elasticsearch/bin
export ES_INDEXES_DIR=$CRAFTER_DATA_DIR/indexes-es
export ES_LOGS_DIR="$CRAFTER_LOGS_DIR/elasticsearch"
export ES_PID=$ES_HOME/elasticsearch.pid
export ES_JAVA_OPTS="-server -Xss1024K -Xmx1G"

# -------------------- Deployer variables --------------------
export DEPLOYER_HOME=$CRAFTER_BIN_DIR/crafter-deployer
export DEPLOYER_DATA_DIR=$CRAFTER_DATA_DIR/deployer
export DEPLOYER_LOGS_DIR=$CRAFTER_LOGS_DIR/deployer
export DEPLOYER_DEPLOYMENTS_DIR=$CRAFTER_DATA_DIR/repos/sites
export DEPLOYER_SDOUT=$DEPLOYER_LOGS_DIR/crafter-deployer.out
export DEPLOYER_JAVA_OPTS="-Dtomcat.host=$TOMCAT_HOST -Dtomcat.http.port=$TOMCAT_HTTP_PORT -Des.host=$ES_HOST \
  -Des.port=$ES_PORT -Dmail.host=$MAIL_HOST -Dmail.port=$MAIL_PORT -server -Xss1024K -Xmx1G"
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
export CATALINA_TMPDIR=$CRAFTER_HOME/temp/tomcat
# Opts used only in Tomcat start
export CATALINA_OPTS="-Dtomcat.host=$TOMCAT_HOST -Dtomcat.http.port=$TOMCAT_HTTP_PORT \
  -Dtomcat.https.port=$TOMCAT_HTTPS_PORT -Dtomcat.ajp.port=$TOMCAT_AJP_PORT -Dsolr.host=$SOLR_HOST \
  -Dsolr.port=$SOLR_PORT -Des.host=$ES_HOST -Des.port=$ES_PORT -Dmongodb.host=$MONGODB_HOST \
  -Dmongodb.port=$MONGODB_PORT -Dmail.host=$MAIL_HOST -Dmail.port=$MAIL_PORT -Dcrafter.home=$CRAFTER_HOME \
  -Dcrafter.bin.dir=$CRAFTER_BIN_DIR -Dcrafter.data.dir=$CRAFTER_DATA_DIR -Dcrafter.logs.dir=$CRAFTER_LOGS_DIR \
  -Dcatalina.logs=$CATALINA_LOGS_DIR -Dapplication.logs=$CATALINA_LOGS_DIR -Djava.net.preferIPv4Stack=true -server \
  -Xss1024K -Xms1G -Xmx4G"

# Profile variables
export PROFILE_DEPLOY_WAR_PATH="$CATALINA_HOME/webapps/crafter-profile"
export PROFILE_WAR_PATH="$CATALINA_HOME/webapps/crafter-profile.war"

# Git variables
export GIT_CONFIG_NOSYSTEM=true
