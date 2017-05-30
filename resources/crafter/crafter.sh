#!/usr/bin/env bash
export CRAFTER_HOME=${CRAFTER_HOME:=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )}
export CRAFTER_ROOT=${CRAFTER_ROOT:=$( cd "$CRAFTER_HOME/.." && pwd )}
export DEPLOYER_HOME=${DEPLOYER_HOME:=$CRAFTER_HOME/crafter-deployer}

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
  echo "    start_mongodb, Starts Mongo DB"
  echo "    stop_mongodb, Stops Mongo DB"  
  echo "    tail,  Tails all Crafter CMS logs"
  exit 0;
}


function printTailInfo(){
  echo -e "\e[34;5;196m"
  echo "To follow the logs, please tail this log files in: $CRAFTER_ROOT/logs/"
  echo -e "\e[0m"
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
  echo "------------------------------------------------------------"
  echo "Starting MongoDB"
  echo "------------------------------------------------------------"
  if [ ! -e "$MONGO_PID" ]; then
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
    if [ ! -d $MONGO_DB_LOGS_DIR ]; then
      mkdir -p $MONGO_DB_LOGS_DIR;
    fi
    $MONGO_DB_HOME/bin/mongod --dbpath=$CRAFTER_ROOT/data/mongodb --directoryperdb --journal --fork --logpath=$MONGO_DB_LOGS_DIR/mongod.log --port 27020
  else
    echo "MongoDB already started"
  fi
}

function stopMongoDB(){
  echo "------------------------------------------------------------"
  echo "Stopping MongoDB"
  echo "------------------------------------------------------------"
  if [ -e "$MONGO_PID" ]; then
    pkill -F $MONGO_PID
    if [ $? -eq 0 ]; then
      rm $MONGO_PID
    fi
    exit 0;
  else
    echo "MongoDB already shutdown or pid $MONGO_PID file not found";
  fi
}

function start() {
  startDeployer
  startSolr
  startMongoDB
  startTomcat
  printTailInfo
}

function debug() {
  debugDeployer
  debugSolr
  startMongoDB
  debugTomcat
  printTailInfo
}

function stop() {
  stopTomcat
  stopMongoDB
  stopSolr
  stopDeployer
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
  tail)
    tail $2
  ;;
  *)
    help
  ;;
esac
