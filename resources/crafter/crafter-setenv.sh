#!/usr/bin/env bash

# Locations variables
export CRAFTER_LOGS_DIR=${CRAFTER_LOGS_DIR:="$CRAFTER_HOME/logs"}
export CRAFTER_DATA_DIR=${CRAFTER_DATA_DIR:="$CRAFTER_HOME/data"}

# Tomcat variables
export CATALINA_HOME="$CRAFTER_BIN_DIR/apache-tomcat"
export CATALINA_PID=$CATALINA_HOME/tomcat.pid
export CATALINA_LOGS_DIR="$CRAFTER_LOGS_DIR/tomcat"
export CATALINA_OUT=$CATALINA_LOGS_DIR/catalina.out
export CATALINA_TMPDIR=$CRAFTER_HOME/temp/tomcat
export CRAFTER_APPLICATION_LOGS=$CATALINA_LOGS_DIR
export CATALINA_OPTS="-Dcrafter.home=$CRAFTER_HOME -Dcrafter.bin.dir=$CRAFTER_BIN_DIR -Dcrafter.data.dir=$CRAFTER_DATA_DIR -Dcrafter.logs.dir=$CRAFTER_LOGS_DIR -Dcatalina.logs=$CATALINA_LOGS_DIR -Djava.net.preferIPv4Stack=true -server -Xss1024K -Xms1G -Xmx4G -Dapplication.logs=$CRAFTER_APPLICATION_LOGS"
export TOMCAT_HTTP_PORT=@TOMCAT_HTTP_PORT@

# Profile variables
export PROFILE_DEPLOY_WAR_PATH="$CATALINA_HOME/webapps/crafter-profile"
export PROFILE_WAR_PATH="$CATALINA_HOME/webapps/crafter-profile.war"

# Solr variables
export SOLR_PORT=@SOLR_PORT@
export SOLR_INDEXES_DIR=$CRAFTER_DATA_DIR/indexes
export SOLR_LOGS_DIR="$CRAFTER_LOGS_DIR/solr"
export SOLR_PID=$SOLR_INDEXES_DIR/solr.pid
export SOLR_JAVA_OPTS="-server -Xss1024K -Xmx1G"
export SOLR_HOME=$CRAFTER_BIN_DIR/solr/server/solr

# Deployer variables
export DEPLOYER_PORT=@DEPLOYER_PORT@
export DEPLOYER_DATA_DIR=$CRAFTER_DATA_DIR/deployer
export DEPLOYER_LOGS_DIR=$CRAFTER_LOGS_DIR/deployer
export DEPLOYER_DEPLOYMENTS_DIR=$CRAFTER_DATA_DIR/repos/sites
export DEPLOYER_SDOUT=$DEPLOYER_LOGS_DIR/crafter-deployer.out
export DEPLOYER_JAVA_OPTS="-server -Xss1024K -Xmx1G"
export DEPLOYER_PID=$DEPLOYER_DATA_DIR/crafter-deployer.pid

# MongoDB variables
export MONGODB_PORT=@MONGODB_PORT@
export MONGODB_HOME="$CRAFTER_BIN_DIR/mongodb"
export MONGODB_PID="$CRAFTER_DATA_DIR/mongodb/mongod.lock"
export MONGODB_DATA_DIR="$CRAFTER_DATA_DIR/mongodb"
export MONGODB_LOGS_DIR="$CRAFTER_LOGS_DIR/mongodb"

# MariaDB variables
export MYSQL_DATA="$CRAFTER_DATA_DIR/db"
export MARIADB_PORT=@MARIADB_PORT@

# Git variables
export GIT_CONFIG_NOSYSTEM=true

case "$(uname -s)" in
   Darwin)
    export MYSQL_PID_FILE_NAME="$(echo "$HOSTNAME" | awk -F'.' '{print $1}' ).pid"
     ;;
    *)
    export MYSQL_PID_FILE_NAME="$HOSTNAME.pid"
    ;;
esac
