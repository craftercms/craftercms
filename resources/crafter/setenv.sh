#!/usr/bin/env bash

# Tomcat variables
export CATALINA_HOME="$CRAFTER_HOME/apache-tomcat"
export CATALINA_PID=$CATALINA_HOME/tomcat.pid
export CATALINA_LOGS_DIR=$CRAFTER_ROOT/logs/tomcat
export CATALINA_OUT=$CATALINA_LOGS_DIR/catalina.out
export CATALINA_OPTS="-Dcatalina.logs=$CATALINA_LOGS_DIR -server -Xss1024K -Xms1G -Xmx4G"
# Solr variables
export SOLR_PORT=@SOLR_PORT@
export SOLR_INDEXES_DIR=$CRAFTER_ROOT/data/indexes
export SOLR_LOGS_DIR=$CRAFTER_ROOT/logs/solr
export SOLR_JAVA_OPTS="-server -Xss1024K -Xmx1G"
# Deployer variables
export DEPLOYER_PORT=@DEPLOYER_PORT@
export DEPLOYER_DATA_DIR=$CRAFTER_ROOT/data/deployer
export DEPLOYER_LOGS_DIR=$CRAFTER_ROOT/logs/deployer
export DEPLOYER_DEPLOYMENTS_DIR=$CRAFTER_ROOT/@DEPLOYMENT_DIR@
export DEPLOYER_SDOUT=$DEPLOYER_LOGS_DIR/crafter-deployer.out
export DEPLOYER_JAVA_OPTS="-server -Xss1024K -Xmx1G"
# MongoDB variables
export MONGO_DB_HOME="$CRAFTER_HOME/mongodb"
export MONGO_PID="$CRAFTER_ROOT/data/mongodb/mongod.lock"
export MONGO_DB_LOGS_DIR=$CRAFTER_ROOT/logs/mongodb
