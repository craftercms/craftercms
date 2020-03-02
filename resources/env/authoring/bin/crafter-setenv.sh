#!/bin/bash

# Copyright (C) 2007-2020 Crafter Software Corporation. All Rights Reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as published by
# the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# -------------------- Spring Profiles --------------------
# Uncomment to enable an external DB for Studio and stop the embedded DB
# export SPRING_PROFILES_ACTIVE=crafter.studio.externalDb

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
export MARIADB_HOST=${MARIADB_HOST:="127.0.0.1"}
export MARIADB_PORT=${MARIADB_PORT:="@MARIADB_PORT@"}
export TOMCAT_HOST=${TOMCAT_HOST:="localhost"}
export TOMCAT_HTTP_PORT=${TOMCAT_HTTP_PORT:="@TOMCAT_HTTP_PORT@"}
export TOMCAT_HTTPS_PORT=${TOMCAT_HTTPS_PORT:="@TOMCAT_HTTPS_PORT@"}
export TOMCAT_AJP_PORT=${TOMCAT_AJP_PORT:="@TOMCAT_AJP_PORT@"}
export TOMCAT_SHUTDOWN_PORT=${TOMCAT_SHUTDOWN_PORT:="@TOMCAT_SHUTDOWN_PORT@"}

# -------------------- URLs --------------------
export SOLR_URL=${SOLR_URL:="http://$SOLR_HOST:$SOLR_PORT/solr"}
export ES_URL=${ES_URL:="http://$ES_HOST:$ES_PORT"}
export DEPLOYER_URL=${DEPLOYER_URL:="http://$DEPLOYER_HOST:$DEPLOYER_PORT"}
export STUDIO_URL=${STUDIO_URL:="http://$TOMCAT_HOST:$TOMCAT_HTTP_PORT/studio"}
export ENGINE_URL=${ENGINE_URL:="http://$TOMCAT_HOST:$TOMCAT_HTTP_PORT"}
export SEARCH_URL=${SEARCH_URL:="http://$TOMCAT_HOST:$TOMCAT_HTTP_PORT/crafter-search"}
export PROFILE_URL=${PROFILE_URL:="http://$TOMCAT_HOST:$TOMCAT_HTTP_PORT/crafter-profile"}
export SOCIAL_URL=${SOCIAL_URL:="http://$TOMCAT_HOST:$TOMCAT_HTTP_PORT/crafter-social"}

# -------------------- Java opts --------------------
export SOLR_JAVA_OPTS=${SOLR_JAVA_OPTS:="-server -Xss1024K -Xmx1G"}
export ES_JAVA_OPTS=${ES_JAVA_OPTS:="-server -Xss1024K -Xmx1G"}
export DEPLOYER_JAVA_OPTS=${DEPLOYER_JAVA_OPTS:="-server -Xss1024K -Xmx1G"}
export CATALINA_OPTS=${CATALINA_OPTS:="-server -Xss1024K -Xms1G -Xmx4G"}

# -------------------- Solr variables --------------------
export SOLR_HOME=${SOLR_HOME:="$CRAFTER_BIN_DIR/solr/server/solr"}
export SOLR_INDEXES_DIR=${SOLR_INDEXES_DIR:="$CRAFTER_DATA_DIR/indexes"}
export SOLR_LOGS_DIR=${SOLR_LOGS_DIR:="$CRAFTER_LOGS_DIR/solr"}
export SOLR_PID=${SOLR_PID:="$SOLR_HOME/solr.pid"}

# -------------------- Elasticsearch variables --------------------
export ES_HOME=${ES_HOME:="$CRAFTER_BIN_DIR/elasticsearch/bin"}
export ES_INDEXES_DIR=${ES_INDEXES_DIR:="$CRAFTER_DATA_DIR/indexes-es"}
export ES_LOGS_DIR=${ES_LOGS_DIR:="$CRAFTER_LOGS_DIR/elasticsearch"}
export ES_PID=${ES_PID:="$ES_HOME/elasticsearch.pid"}
export ES_USERNAME=${ES_USERNAME:=""}
export ES_PASSWORD=${ES_PASSWORD:=""}

# -------------------- Deployer variables --------------------
export DEPLOYER_HOME=${DEPLOYER_HOME:="$CRAFTER_BIN_DIR/crafter-deployer"}
export DEPLOYER_DATA_DIR=${DEPLOYER_DATA_DIR:="$CRAFTER_DATA_DIR/deployer"}
export DEPLOYER_LOGS_DIR=${DEPLOYER_LOGS_DIR:="$CRAFTER_LOGS_DIR/deployer"}
export DEPLOYER_DEPLOYMENTS_DIR=${DEPLOYER_DEPLOYMENTS_DIR:="$CRAFTER_DATA_DIR/repos/sites"}
export DEPLOYER_SDOUT=${DEPLOYER_SDOUT:="$DEPLOYER_LOGS_DIR/crafter-deployer.out"}
export DEPLOYER_PID=${DEPLOYER_PID:="$DEPLOYER_HOME/crafter-deployer.pid"}

# -------------------- MongoDB variables --------------------
export MONGODB_HOME=${MONGODB_HOME:="$CRAFTER_BIN_DIR/mongodb"}
export MONGODB_DATA_DIR=${MONGODB_DATA_DIR:="$CRAFTER_DATA_DIR/mongodb"}
export MONGODB_LOGS_DIR=${MONGODB_LOGS_DIR:="$CRAFTER_LOGS_DIR/mongodb"}
export MONGODB_PID=${MONGODB_PID:="$MONGODB_HOME/mongod.lock"}

# -------------------- MariaDB variables --------------------
export MARIADB_SCHEMA=${MARIADB_SCHEMA:="crafter"}
export MARIADB_HOME=${MARIADB_HOME:="$CRAFTER_BIN_DIR/dbms"}
export MARIADB_DATA_DIR=${MARIADB_DATA_DIR:="$CRAFTER_DATA_DIR/db"}
export MARIADB_ROOT_USER=${MARIADB_ROOT_USER:="root"}
export MARIADB_ROOT_PASSWD=${MARIADB_ROOT_PASSWD:=""}
export MARIADB_USER=${MARIADB_USER:="crafter"}
export MARIADB_PASSWD=${MARIADB_PASSWD:="crafter"}

case "$(uname -s)" in
  Darwin)
    MARIADB_PID_FILE_NAME="$(echo "$HOSTNAME" | awk -F'.' '{print $1}' ).pid"
  ;;
  *)
    MARIADB_PID_FILE_NAME="$HOSTNAME.pid"
  ;;
esac

export MARIADB_PID=${MARIADB_PID:="$MARIADB_HOME/$MARIADB_PID_FILE_NAME"}

# -------------------- Tomcat variables --------------------
export CATALINA_HOME=${CATALINA_HOME:="$CRAFTER_BIN_DIR/apache-tomcat"}
export CATALINA_PID=${CATALINA_PID:="$CATALINA_HOME/tomcat.pid"}
export CATALINA_LOGS_DIR=${CATALINA_LOGS_DIR:="$CRAFTER_LOGS_DIR/tomcat"}
export CATALINA_OUT=${CATALINA_OUT:="$CATALINA_LOGS_DIR/catalina.out"}
export CATALINA_TMPDIR=${CATALINA_TMPDIR:="$CRAFTER_TEMP_DIR/tomcat"}

# -------------------- Git variables --------------------
export GIT_CONFIG_NOSYSTEM=${GIT_CONFIG_NOSYSTEM:="true"}

# -------------------- Management tokens ----------------
# Please update this per installation and provide these tokens to the status monitors.
export STUDIO_MANAGEMENT_TOKEN=${STUDIO_MANAGEMENT_TOKEN:="defaultManagementToken"}
export ENGINE_MANAGEMENT_TOKEN=${ENGINE_MANAGEMENT_TOKEN:="defaultManagementToken"}
export DEPLOYER_MANAGEMENT_TOKEN=${DEPLOYER_MANAGEMENT_TOKEN:="defaultManagementToken"}
export SEARCH_MANAGEMENT_TOKEN=${SEARCH_MANAGEMENT_TOKEN:="defaultManagementToken"}
export PROFILE_MANAGEMENT_TOKEN=${PROFILE_MANAGEMENT_TOKEN:="defaultManagementToken"}
export SOCIAL_MANAGEMENT_TOKEN=${SOCIAL_MANAGEMENT_TOKEN:="defaultManagementToken"}

# -------------------- Encryption variables --------------------
export CRAFTER_ENCRYPTION_KEY=${CRAFTER_ENCRYPTION_KEY:="default_encryption_key"}
export CRAFTER_ENCRYPTION_SALT=${CRAFTER_ENCRYPTION_SALT:="default_encryption_salt"}

# -------------------- Cluster variables --------------------
export CLUSTER_NODE_ADDRESS=${CLUSTER_NODE_ADDRESS:="127.0.0.1"}
