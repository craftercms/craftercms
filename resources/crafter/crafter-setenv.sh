#!/usr/bin/env bash

# Tomcat variables
export CATALINA_HOME="$CRAFTER_HOME/apache-tomcat"
export CATALINA_PID=$CATALINA_HOME/tomcat.pid
export CATALINA_LOGS_DIR=$CRAFTER_ROOT/logs/tomcat
export CATALINA_OUT=$CATALINA_LOGS_DIR/catalina.out
export CRAFTER_APPLICATION_LOGS=$CATALINA_LOGS_DIR
export CATALINA_OPTS="-Dcatalina.logs=$CATALINA_LOGS_DIR -server -Xss1024K -Xms1G -Xmx4G -Dapplication.logs=$CRAFTER_APPLICATION_LOGS"
export TOMCAT_HTTP_PORT=@TOMCAT_HTTP_PORT@

# Profile variables
export PROFILE_DEPLOY_WAR_PATH="$CATALINA_HOME/webapps/crafter-profile"
export PROFILE_WAR_PATH="$CATALINA_HOME/webapps/crafter-profile.war"

# Solr variables
export SOLR_PORT=@SOLR_PORT@
export SOLR_INDEXES_DIR=$CRAFTER_ROOT/data/indexes
export SOLR_LOGS_DIR=$CRAFTER_ROOT/logs/solr
export SOLR_PID=$SOLR_INDEXES_DIR/solr.pid
export SOLR_JAVA_OPTS="-server -Xss1024K -Xmx1G"
export SOLR_HOME=$CRAFTER_HOME/solr/server/solr

# Deployer variables
export DEPLOYER_PORT=@DEPLOYER_PORT@
export DEPLOYER_DATA_DIR=$CRAFTER_ROOT/data/deployer
export DEPLOYER_LOGS_DIR=$CRAFTER_ROOT/logs/deployer
export DEPLOYER_DEPLOYMENTS_DIR=$CRAFTER_ROOT/@DEPLOYMENT_DIR@
export DEPLOYER_SDOUT=$DEPLOYER_LOGS_DIR/crafter-deployer.out
export DEPLOYER_JAVA_OPTS="-server -Xss1024K -Xmx1G"
export DEPLOYER_PID=$DEPLOYER_DATA_DIR/crafter-deployer.pid

# MongoDB variables
export MONGODB_PORT=@MONGODB_PORT@
export MONGODB_HOME="$CRAFTER_HOME/mongodb"
export MONGODB_PID="$CRAFTER_ROOT/data/mongodb/mongod.lock"
export MONGODB_DATA_DIR="$CRAFTER_ROOT/data/mongodb"
export MONGODB_LOGS_DIR="$CRAFTER_ROOT/logs/mongodb"
export MYSQL_DATA="$CRAFTER_ROOT/data/db"
export MARIADB_PORT=@MARIADB_PORT@

case "$(uname -s)" in
   Darwin)
    export MYSQL_PID_FILE_NAME="$(echo "$HOSTNAME" | awk -F'.' '{print $1}' ).pid"
     ;;
    *)
    export MYSQL_PID_FILE_NAME="$HOSTNAME.pid"
    ;;
esac
