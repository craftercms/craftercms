#!/usr/bin/env bash
export CRAFTER_HOME=${CRAFTER_HOME:=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )}
export CRAFTER_ROOT=${CRAFTER_ROOT:=$( cd "$CRAFTER_HOME/.." && pwd )}
export DEPLOYER_HOME=${DEPLOYER_HOME:=$CRAFTER_HOME/crafter-deployer}
export MONGO_DB_HOME="$CRAFTER_HOME/mongodb"

. "$CRAFTER_HOME/setenv.sh"

function help() {
  echo $(basename $BASH_SOURCE)
  echo "    start, Starts Tomcat, Deployer and Solr"
  echo "    stop, Stops Tomcat, Deployer and Solr"
  echo "    debug, Starts Tomcat, Deployer and Solr in debug mode"
  echo "    start_deployer, Starts Deployer"
  echo "    stop_deployer, Stops Deployer"
  echo "    debug_deployer, Starts Deployer in debug mode"
  echo "    start_solr, Starts Solr"
  echo "    stop_solr, Stops Solr"
  echo "    debug_solr, Starts Solr in debug mode"
  echo "    start_tomcat, Starts Tomcat"
  echo "    stop_tomcat, Stops Tomcat"
  echo "    debug_tomcat, Starts Tomcat in debug mode"
  exit 0;
}

function startDeployer() {
  cd $DEPLOYER_HOME
  echo "------------------------------------------------------------"
  echo "Starting Deployer"
  echo "------------------------------------------------------------"
  if [ ! -d $DEPLOYER_LOGS_DIR ]; then
    mkdir -p $DEPLOYER_LOGS_DIR;
  fi
  ./deployer.sh start;
}

function debugDeployer() {
  cd $DEPLOYER_HOME
  echo "------------------------------------------------------------"
  echo "Starting Deployer"
  echo "------------------------------------------------------------"
  if [ ! -d $DEPLOYER_LOGS_DIR ]; then
    mkdir -p $DEPLOYER_LOGS_DIR;
  fi
  ./deployer.sh debug;
}

function stopDeployer() {
  cd $DEPLOYER_HOME
  echo "------------------------------------------------------------"
  echo "Stopping Deployer"
  echo "------------------------------------------------------------"
  ./deployer.sh stop;
}

function startSolr() {
  cd $CRAFTER_HOME
  echo "------------------------------------------------------------"
  echo "Starting Solr"
  echo "------------------------------------------------------------"
  if [ ! -d $SOLR_LOGS_DIR ]; then
    mkdir -p $SOLR_LOGS_DIR;
  fi
  ./solr/bin/solr start -p $SOLR_PORT -Dcrafter.solr.index=$SOLR_INDEXES_DIR -a "$SOLR_JAVA_OPTS"
}

function debugSolr() {
  cd $CRAFTER_HOME
  echo "------------------------------------------------------------"
  echo "Starting Solr"
  echo "------------------------------------------------------------"
  if [ ! -d $SOLR_LOGS_DIR ]; then
    mkdir -p $SOLR_LOGS_DIR;
  fi
  ./solr/bin/solr start -p $SOLR_PORT -Dcrafter.solr.index=$SOLR_INDEXES_DIR -a "$SOLR_JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=1044"
}

function stopSolr() {
  cd $CRAFTER_HOME
  echo "------------------------------------------------------------"
  echo "Stopping Solr"
  echo "------------------------------------------------------------"
  ./solr/bin/solr stop
}

function startTomcat() {
  cd $CRAFTER_HOME
  echo "------------------------------------------------------------"
  echo "Starting Tomcat"
  echo "------------------------------------------------------------"
  if [ ! -d $CATALINA_LOGS_DIR ]; then
    mkdir -p $CATALINA_LOGS_DIR;
  fi
  ./apache-tomcat/bin/startup.sh
}

function debugTomcat() {
  cd $CRAFTER_HOME
  echo "------------------------------------------------------------"
  echo "Starting Tomcat"
  echo "------------------------------------------------------------"
  if [ ! -d $CATALINA_LOGS_DIR ]; then
    mkdir -p $CATALINA_LOGS_DIR;
  fi
  ./apache-tomcat/bin/catalina.sh jpda start;
}

function stopTomcat() {
  cd $CRAFTER_HOME
  echo "------------------------------------------------------------"
  echo "Stopping Tomcat"
  echo "------------------------------------------------------------"
  ./apache-tomcat/bin/shutdown.sh -force
}

function startMongoDB(){
    if [ -d "$MONGO_DB_HOME" ]; then
        cd $MONGO_DB_HOME
        echo "OK"
        cd $CRAFTER_HOME
     else
       cd $CRAFTER_HOME
       mkdir $MONGO_DB_HOME
       cd $MONGO_DB_HOME
       echo "MongoDB not found"
       java -jar $CRAFTER_HOME/craftercms-utils.jar download mongodb
       tar xvf mongodb.tgz --strip 1
       rm mongodb.tgz
    fi
    echo "------------------------------------------------------------"
    echo "Starting MongoDB"
    echo "------------------------------------------------------------"
    if [ ! -d $MONGO_DB_LOGS_DIR ]; then
      mkdir -p $MONGO_DB_LOGS_DIR;
    fi
    $CRAFTER_HOME/$MONGO_DB_HOME/bin/mongod --dbpath=$CRAFTER_ROOT/data/mongodb --directoryperdb --journal --fork --logpath=$CRAFTER_ROOT/logs/mongodb/mongod.log --port @MONGODB_PORT@

}

function stopMongoDB(){
  ##TODO
  echo "OK"
}

function start() {
  startSolr
  startMongoDB
  startTomcat
  startDeployer
}

function debug() {
  debugSolr
  startMongoDB
  debugTomcat
  debugDeployer
}

function stop() {
  stopDeployer
  stopMongoDB
  stopTomcat
  stopSolr
}

function logo() {
  echo -e "\e[38;5;196m"
  echo " ██████╗ ██████╗   █████╗  ███████╗ ████████╗ ███████╗ ██████╗      ██████╗ ███╗   ███╗ ███████╗"
  echo "██╔════╝ ██╔══██╗ ██╔══██╗ ██╔════╝ ╚══██╔══╝ ██╔════╝ ██╔══██╗    ██╔════╝ ████╗ ████║ ██╔════╝"
  echo "██║      ██████╔╝ ███████║ █████╗      ██║    █████╗   ██████╔╝    ██║      ██╔████╔██║ ███████╗"
  echo "██║      ██╔══██╗ ██╔══██║ ██╔══╝      ██║    ██╔══╝   ██╔══██╗    ██║      ██║╚██╔╝██║ ╚════██║"
  echo "╚██████╗ ██║  ██║ ██║  ██║ ██║         ██║    ███████╗ ██║  ██║    ╚██████╗ ██║ ╚═╝ ██║ ███████║"
  echo " ╚═════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚═╝         ╚═╝    ╚══════╝ ╚═╝  ╚═╝     ╚═════╝ ╚═╝     ╚═╝ ╚══════╝"
  echo -e "\e[0m"
}

case $1 in
  debug)
    logo
    debug
  ;;
  start)
    logo
    start
  ;;
  stop)
    logo
    stop
  ;;
  debug_deployer)
    logo
    debugDeployer
  ;;
  start_deployer)
    logo
    startDeployer
  ;;
  stop_deployer)
    logo
    stopDeployer
  ;;
  debug_solr)
    logo
    debugSolr
  ;;
  start_solr)
    logo
    startSolr
  ;;
  stop_solr)
    logo
    stopSolr
  ;;
  debug_tomcat)
    logo
    debugTomcat
  ;;
  start_tomcat)
    logo
    startTomcat
  ;;
  stop_tomcat)
    logo
    stopTomcat
  ;;
  start_mongodb)
    logo
    startMongoDB
  ;;
  stop_mongodb)
    logo
    stopMongoDB
  ;;
  *)
    help
  ;;
esac
