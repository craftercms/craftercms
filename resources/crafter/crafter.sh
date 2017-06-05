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
  echo -e "\033[34;5;196m"
  echo "To follow the logs, please tail this log files in: $CRAFTER_ROOT/logs/"
  echo -e "\033[0m"
}

function startDeployer() {
  cd $DEPLOYER_HOME
  echo "------------------------------------------------------------"
  echo "Starting Deployer"
  echo "------------------------------------------------------------"
  if [ ! -d $DEPLOYER_LOGS_DIR ]; then
    mkdir -p $DEPLOYER_LOGS_DIR;
  fi
  $DEPLOYER_HOME/deployer.sh start;
}

function debugDeployer() {
  cd $DEPLOYER_HOME
  echo "------------------------------------------------------------"
  echo "Starting Deployer"
  echo "------------------------------------------------------------"
  if [ ! -d $DEPLOYER_LOGS_DIR ]; then
    mkdir -p $DEPLOYER_LOGS_DIR;
  fi
  $DEPLOYER_HOME/deployer.sh debug;
}

function stopDeployer() {
  cd $DEPLOYER_HOME
  echo "------------------------------------------------------------"
  echo "Stopping Deployer"
  echo "------------------------------------------------------------"
  $DEPLOYER_HOME/deployer.sh stop;
}

function startSolr() {
  cd $CRAFTER_HOME
  echo "------------------------------------------------------------"
  echo "Starting Solr"
  echo "------------------------------------------------------------"
  if [ ! -d $SOLR_LOGS_DIR ]; then
    mkdir -p $SOLR_LOGS_DIR;
  fi
  $CRAFTER_HOME/solr/bin/solr start -p $SOLR_PORT -Dcrafter.solr.index=$SOLR_INDEXES_DIR -a "$SOLR_JAVA_OPTS"
}

function debugSolr() {
  cd $CRAFTER_HOME
  echo "------------------------------------------------------------"
  echo "Starting Solr"
  echo "------------------------------------------------------------"
  if [ ! -d $SOLR_LOGS_DIR ]; then
    mkdir -p $SOLR_LOGS_DIR;
  fi
  $CRAFTER_HOME/solr/bin/solr start -p $SOLR_PORT -Dcrafter.solr.index=$SOLR_INDEXES_DIR -a "$SOLR_JAVA_OPTS -Xdebug
  -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=1044"
}

function stopSolr() {
  cd $CRAFTER_HOME
  echo "------------------------------------------------------------"
  echo "Stopping Solr"
  echo "------------------------------------------------------------"
  $CRAFTER_HOME/solr/bin/solr stop
}

function startTomcat() {
  cd $CRAFTER_HOME
  echo "------------------------------------------------------------"
  echo "Starting Tomcat"
  echo "------------------------------------------------------------"
  if [ ! -d $CATALINA_LOGS_DIR ]; then
    mkdir -p $CATALINA_LOGS_DIR;
  fi
  $CRAFTER_HOME/apache-tomcat/bin/startup.sh
}

function debugTomcat() {
  cd $CRAFTER_HOME
  echo "------------------------------------------------------------"
  echo "Starting Tomcat"
  echo "------------------------------------------------------------"
  if [ ! -d $CATALINA_LOGS_DIR ]; then
    mkdir -p $CATALINA_LOGS_DIR;
  fi
  $CRAFTER_HOME/apache-tomcat/bin/catalina.sh jpda start;
}

function stopTomcat() {
  cd $CRAFTER_HOME
  echo "------------------------------------------------------------"
  echo "Stopping Tomcat"
  echo "------------------------------------------------------------"
  $CRAFTER_HOME/apache-tomcat/bin/shutdown.sh -force
}

function startMongoDB(){
  echo "------------------------------------------------------------"
  echo "Starting MongoDB"
  echo "------------------------------------------------------------"
  if [ ! -s "$MONGODB_PID" ]; then

    if [ ! -d "$MONGODB_DATA_DIR" ]; then
        echo "Creating : ${MONGODB_DATA_DIR}"
        mkdir -p "$MONGODB_DATA_DIR"
    fi

    if [ ! -d $MONGODB_LOGS_DIR ]; then
         echo "Creating : ${MONGODB_LOGS_DIR}"
      mkdir -p $MONGODB_LOGS_DIR;
    fi

    if [ ! -d "$MONGODB_HOME" ]; then
      cd $CRAFTER_HOME
      mkdir $MONGODB_HOME
      cd $MONGODB_HOME
      echo "MongoDB not found"
      java -jar $CRAFTER_HOME/craftercms-utils.jar download mongodb
      tar xvf mongodb.tgz --strip 1
      rm mongodb.tgz
    fi

    $MONGODB_HOME/bin/mongod --dbpath=$CRAFTER_ROOT/data/mongodb --directoryperdb --journal --fork --logpath=$MONGODB_LOGS_DIR/mongod.log --port $MONGODB_PORT
  else
    echo "MongoDB already started"
  fi
}

function stopMongoDB(){
  echo "------------------------------------------------------------"
  echo "Stopping MongoDB"
  echo "------------------------------------------------------------"
  if [ -s "$MONGODB_PID" ]; then
    $MONGODB_HOME/bin/mongod --shutdown --dbpath=$CRAFTER_ROOT/data/mongodb --logpath=$MONGODB_LOGS_DIR/mongod.log --port $MONGODB_PORT
    if [ $? -eq 0 ]; then
      rm $MONGODB_PID
    fi
  else
    echo "MongoDB already shutdown or pid $MONGODB_PID file not found";
  fi
}

function solrStatus(){
   echo "------------------------------------------------------------"
   echo "SOLR status                                                 "
   echo "------------------------------------------------------------"
   solrStatusOut=$(curl --silent  -f -y "http://localhost:$SOLR_PORT/solr/admin/info/system?wt=json")
   if [ $? -eq 0 ]; then
    echo -e "PID\t"
    echo `cat "$CRAFTER_ROOT/bin/solr/bin/solr-$SOLR_PORT.pid"`
    echo -e  "uptime (in minutes):\t"
    echo "$solrStatusOut" | grep -Po '(?<=upTimeMS":)[^}]+' | awk '{print ($1/1000)/60}'| bc
    echo -e  "Solr Version:\t"
    echo "$solrStatusOut" | grep -Po '(?<=solr-spec-version":")[^"]+'
   else
      echo -e "\033[38;5;196m"
      echo "Solr is not running or is unreachable on port $SOLR_PORT"
      echo -e "\033[0m"
    fi
}

function deployerStatus(){
   echo "------------------------------------------------------------"
   echo "Crafter Deployer status                                                 "
   echo "------------------------------------------------------------"
   deployerStatusOut=$(curl --silent  -f -y "http://localhost:$DEPLOYER_PORT/api/1/monitor/status")
   if [ $? -eq 0 ]; then
    echo -e "PID\t"
    echo `cat "$CRAFTER_ROOT/bin/crafter-deployer/crafter-deployer.pid"`
    echo -e  "uptime:\t"
    echo "$deployerStatusOut" | grep -Po '(?<=uptime":")[^"]+'
    echo -e  "Status:\t"
    echo "$deployerStatusOut" | grep -Po '(?<=status":")[^"]+'
   else
      echo -e "\033[38;5;196m"
      echo "Crafter Deployer is not running or is unreachable on port $DEPLOYER_PORT"
      echo -e "\033[0m"
    fi
}

function studioStatus(){
   echo "------------------------------------------------------------"
   echo "Crafter Studio status                                       "
   echo "------------------------------------------------------------"
   studioStatusOut=$(curl --silent  -f -y\
   "http://localhost:$TOMCAT_HTTP_PORT/studio/api/1/services/api/1/monitor/status.json")
   if [ $? -eq 0 ]; then
    echo -e "PID\t"
    echo `cat "$CATALINA_PID"`
    echo -e  "uptime:\t"
    echo "$studioStatusOut" | grep -Po '(?<=uptime":")[^"]+'
    echo -e  "Status:\t"
    echo "$studioStatusOut" | grep -Po '(?<=status":")[^"]+'
    echo -e "MySQL sub-process:\t"
    echo -e "PID \t"
    echo ` cat "$MYSQL_DATA/$HOSTNAME.pid"`
   else
      echo -e "\033[38;5;196m"
      echo "Crafter Studio is not running or is unreachable on port $TOMCAT_HTTP_PORT"
      echo -e "\033[0m"
    fi
}

function mongoDbStatus(){
    if [ -e "$MONGODB_PID" ]; then
        echo -e "MongoDB PID"
        echo $(cat $MONGODB_PID)
    else
        echo -e "\033[38;5;196m"
        echo " MongoDB is not running"
        echo -e "\033[0m"
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

function status(){
  solrStatus
  deployerStatus
  studioStatus
  mongoDbStatus
}

function logo() {
  echo -e "\033[38;5;196m"
  echo " ██████╗ ██████╗   █████╗  ███████╗ ████████╗ ███████╗ ██████╗      ██████╗ ███╗   ███╗ ███████╗"
  echo "██╔════╝ ██╔══██╗ ██╔══██╗ ██╔════╝ ╚══██╔══╝ ██╔════╝ ██╔══██╗    ██╔════╝ ████╗ ████║ ██╔════╝"
  echo "██║      ██████╔╝ ███████║ █████╗      ██║    █████╗   ██████╔╝    ██║      ██╔████╔██║ ███████╗"
  echo "██║      ██╔══██╗ ██╔══██║ ██╔══╝      ██║    ██╔══╝   ██╔══██╗    ██║      ██║╚██╔╝██║ ╚════██║"
  echo "╚██████╗ ██║  ██║ ██║  ██║ ██║         ██║    ███████╗ ██║  ██║    ╚██████╗ ██║ ╚═╝ ██║ ███████║"
  echo " ╚═════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚═╝         ╚═╝    ╚══════╝ ╚═╝  ╚═╝     ╚═════╝ ╚═╝     ╚═╝ ╚══════╝"
  echo -e "\033[0m"
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
  status)
     status
  ;;
  *)
    help
  ;;
esac
