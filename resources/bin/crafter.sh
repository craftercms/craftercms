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

cecho () {
    if [ -z "$CRAFTERCMS_SCRIPT_LOG" ]; then
      echo "$1"
    else
      echo "$1" >> "$CRAFTERCMS_SCRIPT_LOG"
    fi
}

if [ "$(whoami)" == "root" ]; then
  cecho -e "\033[38;5;196m"
  cecho -e "Crafter CMS cowardly refuses to run as root."
  cecho -e "Running as root is dangerous and is not supported."
  cecho -e "\033[0m"
  exit 1
fi

OSARCH=$(getconf LONG_BIT)
if [[ $OSARCH -eq "32" ]]; then
  cecho -e "\033[38;5;196m"
  cecho "CrafterCMS is not supported in a 32bit os"
  cecho -e "\033[0m"
  read -r
  exit 5
fi

export CRAFTER_BIN_DIR=${CRAFTER_BIN_DIR:=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )}
export CRAFTER_HOME=${CRAFTER_HOME:=$( cd "$CRAFTER_BIN_DIR/.." && pwd )}

# Check if OS is macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Remove com.apple.quarantine flag for elasticsearch files
  xattr -rd com.apple.quarantine $CRAFTER_BIN_DIR/elasticsearch
fi

. "$CRAFTER_BIN_DIR/crafter-setenv.sh"

function help() {
  cecho $(basename $BASH_SOURCE)
  cecho "    start [withMongoDB] [withSolr] [skipElasticsearch] [skipMongoDB], Starts Tomcat, Deployer and\
  Elasticsearch. If withMongoDB is specified MongoDB will be started, if withSolr is specified Solr will be started,\
  if skipElasticsearch is specified Elasticsearch will not be started, if skipMongoDB is specified MongoDB will not be\
  started even if the Crafter Profile war is present"
  cecho "    stop, Stops Tomcat, Deployer, Elasticsearch (if started), Solr (if started) and Mongo (if started)"
  cecho "    debug [withMongoDB] [withSolr] [skipElasticsearch] [skipMongoDB], Starts Tomcat, Deployer and\
  Elasticsearch in debug mode. If withMongoDB is specified MongoDB will be started, if withSolr is specified Solr will\
  be started, if skipElasticsearch is specified Elasticsearch will not be started, if skipMongoDB is specified MongoDB\
  will not be started even if the Crafter Profile war is present"
  cecho "    start_deployer, Starts Deployer"
  cecho "    stop_deployer, Stops Deployer"
  cecho "    debug_deployer, Starts Deployer in debug mode"
  cecho "    start_solr, Starts Solr"
  cecho "    stop_solr, Stops Solr"
  cecho "    debug_solr, Starts Solr in debug mode"
  cecho "    start_elasticsearch, Starts Elasticsearch"
  cecho "    stop_elasticsearch, Stops Elasticsearch"
  cecho "    debug_elasticsearch, Starts Elasticsearch in debug mode"
  cecho "    start_tomcat, Starts Tomcat"
  cecho "    stop_tomcat, Stops Tomcat"
  cecho "    debug_tomcat, Starts Tomcat in debug mode"
  cecho "    start_mongodb, Starts Mongo DB"
  cecho "    stop_mongodb, Stops Mongo DB"
  cecho "    status, Status of all CrafterCms subsystems"
  cecho "    status_engine, Status of Crafter Engine"
  cecho "    status_studio, Status of Crafter Studio"
  cecho "    status_profile, Status of Crafter Profile"
  cecho "    status_social, Status of Crafter Social"
  cecho "    status_search, Status of Crafter Search"
  cecho "    status_deployer, Status of Deployer"
  cecho "    status_solr, Status of Solr"
  cecho "    status_elasticsearch, Status of Elasticsearch"
  cecho "    status_mariadb, Status of MariaDB"
  cecho "    status_mongodb, Status of MonoDb"
  cecho "    backup <name>, Perform a backup of all data"
  cecho "    restore <file>, Perform a restore of all data"
  cecho "    upgradedb, Perform database upgrade (mysql_upgrade)"
  cecho ""
  cecho "For more information use '$(basename $BASH_SOURCE) man'"
  exit 2;
}

function version(){
  cecho "Copyright (C) 2007-2020 Crafter Software Corporation. All rights reserved."
  cecho "Version @VERSION@-@GIT_BUILD_ID@"
}

function pidOf(){
  port=$1

  echo $(lsof -iTCP -sTCP:LISTEN -P | grep "$port" | awk '{print $2}' | sort | uniq)
}

function killPID(){
  pkill -15 -F "$1"
  sleep 5 # % mississippis
  if [ -s "$1" ] && pgrep -F "$1" > /dev/null
  then
    pkill -9 -F "$1" # force kill
  fi
}

# Run an external program with logging
function runCmd() {
  # TODO Still needs work to disown forked processes in certain cases
  if [ -z "$CRAFTERCMS_SCRIPT_LOG" ]; then
    bash -c "$@"
  else
    bash -c "$@" 2>&1 >> "$CRAFTERCMS_SCRIPT_LOG"
  fi
}

function checkPortForRunning(){
  result=1
  pidForOpenPort=$(pidOf $1)
  if ! [ "$pidForOpenPort"=="$2" ]; then
    cecho -e "\033[38;5;196m"
    cecho " Port $1 is taken by PID $pidForOpenPort"
    cecho " Please shutdown process with PID $pidForOpenPort"
    cecho -e "\033[0m"
  else
    result=0
  fi
  return $result
}

function printTailInfo(){
  cecho -e "\033[38;5;196m"
  cecho "Log files live here: \"$CRAFTER_LOGS_DIR\". "
  cecho "To follow the main tomcat log, you can \"tail -f $CRAFTER_LOGS_DIR/tomcat/catalina.out\""
  cecho -e "\033[0m"
}

function startDeployer() {
  cd $DEPLOYER_HOME
  cecho "------------------------------------------------------------------------"
  cecho "Starting Deployer"
  cecho "------------------------------------------------------------------------"
  if [ ! -d $DEPLOYER_LOGS_DIR ]; then
    mkdir -p $DEPLOYER_LOGS_DIR;
  fi
  $DEPLOYER_HOME/deployer.sh start;
}

function debugDeployer() {
  cd $DEPLOYER_HOME
  cecho "------------------------------------------------------------------------"
  cecho "Starting Deployer"
  cecho "------------------------------------------------------------------------"
  if [ ! -d $DEPLOYER_LOGS_DIR ]; then
    mkdir -p $DEPLOYER_LOGS_DIR;
  fi
  $DEPLOYER_HOME/deployer.sh debug;
}

function stopDeployer() {
  cd $DEPLOYER_HOME
  cecho "------------------------------------------------------------------------"
  cecho "Stopping Deployer"
  cecho "------------------------------------------------------------------------"
  $DEPLOYER_HOME/deployer.sh stop;
}

function startSolr() {
  cd $CRAFTER_BIN_DIR
  cecho "------------------------------------------------------------------------"
  cecho "Starting Solr"
  cecho "------------------------------------------------------------------------"
  if [ ! -d $SOLR_INDEXES_DIR ]; then
    mkdir -p $SOLR_INDEXES_DIR;
  fi
  if [ ! -d $SOLR_LOGS_DIR ]; then
    mkdir -p $SOLR_LOGS_DIR;
  fi

  if [ ! -s "$SOLR_PID" ]; then
    ## Before run check if the port is available.
    possiblePID=$(pidOf $SOLR_PORT)
    if  [ -z "$possiblePID" ];  then
      $CRAFTER_BIN_DIR/solr/bin/solr start -p $SOLR_PORT -s $SOLR_HOME -Dcrafter.solr.index=$SOLR_INDEXES_DIR -a "$SOLR_JAVA_OPTS"
      echo $(pidOf $SOLR_PORT) > $SOLR_PID
    else
      echo $possiblePID > $SOLR_PID
      cecho "Process PID $possiblePID is listening port $SOLR_PORT"
      cecho "Hijacking PID and saving into $SOLR_PID"
      exit 0
    fi
  else
    # IS it really up ?
    if ! checkPortForRunning $SOLR_PORT $(cat "$SOLR_PID");then
      exit 6
    fi
    if ! pgrep -u `whoami` -F "$SOLR_PID" >/dev/null
    then
      cecho "Solr Pid file is not ok, forcing startup"
      rm "$SOLR_PID"
      startSolr
    fi
    cecho "Solr already started"
  fi
}

function debugSolr() {
  cd $CRAFTER_BIN_DIR
  cecho "------------------------------------------------------------------------"
  cecho "Starting Solr"
  cecho "------------------------------------------------------------------------"
  if [ ! -d $SOLR_INDEXES_DIR ]; then
    mkdir -p $SOLR_INDEXES_DIR;
  fi
  if [ ! -d $SOLR_LOGS_DIR ]; then
    mkdir -p $SOLR_LOGS_DIR;
  fi

  if [ ! -s "$SOLR_PID" ]; then
    ## Before run check if the port is available.
    possiblePID=$(pidOf $SOLR_PORT)
    if  [ -z "$possiblePID" ];  then
      $CRAFTER_BIN_DIR/solr/bin/solr start -p $SOLR_PORT -s $SOLR_HOME -Dcrafter.solr.index=$SOLR_INDEXES_DIR \
      -a "$SOLR_JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=1044"
      echo $(pidOf $SOLR_PORT) > $SOLR_PID
    else
      echo $possiblePID > $SOLR_PID
      cecho "Process PID $possiblePID is listening port $SOLR_PORT"
      cecho "Hijacking PID and saving into $SOLR_PID"
      exit
    fi
  else
    # IS it really up ?
    if ! checkPortForRunning $SOLR_PORT $(cat "$SOLR_PID");then
      exit 6
    fi
    if ! pgrep -u `whoami` -F "$SOLR_PID" >/dev/null
    then
      cecho "Solr Pid file is not ok, forcing startup"
      rm "$SOLR_PID"
      debugSolr
    fi
    cecho "Solr already started"
  fi
}

function stopSolr() {
  cd $CRAFTER_BIN_DIR
  cecho "------------------------------------------------------------------------"
  cecho "Stopping Solr"
  cecho "------------------------------------------------------------------------"
  if [ -s "$SOLR_PID" ]; then
    $CRAFTER_BIN_DIR/solr/bin/solr stop
    if pgrep -F "$SOLR_PID" > /dev/null
    then
      killPID $SOLR_PID
    fi
    if [ $? -eq 0 ]; then
      rm $SOLR_PID
    fi
  else
    pid=$(pidOf $SOLR_PORT)
    if ! [ -z $pid ]; then
      echo "$pid" > $SOLR_PID
      # No pid file but we found the process
      killPID $SOLR_PID
    fi
    cecho "Solr already shutdown or pid $SOLR_PID file not found";
  fi
}

function startElasticsearch() {
  cd $CRAFTER_BIN_DIR
  cecho "------------------------------------------------------------------------"
  cecho "Starting Elasticsearch"
  cecho "------------------------------------------------------------------------"
  if [ ! -d $ES_INDEXES_DIR ]; then
    mkdir -p $ES_INDEXES_DIR;
  fi
  if [ ! -d $ES_LOGS_DIR ]; then
    mkdir -p $ES_LOGS_DIR;
  fi

  if [ ! -s "$ES_PID" ]; then
    ## Before run check if the port is available.
    possiblePID=$(pidOf $ES_PORT)
    if  [ -z "$possiblePID" ];  then
      $ES_HOME/elasticsearch -d -p $ES_PID
    else
      echo $possiblePID > $ES_PID
      cecho "Process PID $possiblePID is listening port $ES_PORT"
      cecho "Hijacking PID and saving into $ES_PID"
      exit 0
    fi
  else
    # IS it really up ?
    if ! checkPortForRunning $ES_PORT $(cat "$ES_PID");then
      exit 6
    fi
    if ! pgrep -u `whoami` -F "$ES_PID" >/dev/null
    then
      cecho "Elasticsearch Pid file is not ok, forcing startup"
      rm "$ES_PID"
      startElasticsearch
    fi
    cecho "Elasticsearch already started"
  fi
}

function debugElasticsearch() {
  cd $CRAFTER_BIN_DIR
  cecho "------------------------------------------------------------------------"
  cecho "Starting Elasticsearch"
  cecho "------------------------------------------------------------------------"
  if [ ! -d $ES_INDEXES_DIR ]; then
    mkdir -p $ES_INDEXES_DIR;
  fi
  if [ ! -d $ES_LOGS_DIR ]; then
    mkdir -p $ES_LOGS_DIR;
  fi

  if [ ! -s "$ES_PID" ]; then
    ## Before run check if the port is available.
    possiblePID=$(pidOf $ES_PORT)
    if  [ -z "$possiblePID" ];  then
      export ES_JAVA_OPTS="$ES_JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=1045"
      $ES_HOME/elasticsearch -d -p $ES_PID
    else
      echo $possiblePID > $ES_PID
      cecho "Process PID $possiblePID is listening port $ES_PORT"
      cecho "Hijacking PID and saving into $ES_PID"
      exit 0
    fi
  else
    # IS it really up ?
    if ! checkPortForRunning $ES_PORT $(cat "$ES_PID");then
      exit 6
    fi
    if ! pgrep -u `whoami` -F "$ES_PID" >/dev/null
    then
      cecho "Elasticsearch Pid file is not ok, forcing startup"
      rm "$ES_PID"
      startElasticsearch
    fi
    cecho "Elasticsearch already started"
  fi
}

function stopElasticsearch() {
  cd $CRAFTER_BIN_DIR
  cecho "------------------------------------------------------------------------"
  cecho "Stopping Elasticsearch"
  cecho "------------------------------------------------------------------------"
  if [ -s "$ES_PID" ]; then
    if pgrep -F "$ES_PID" > /dev/null
    then
      killPID $ES_PID
    fi
  else
    pid=$(pidOf $ES_PORT)
    if [ ! -z $pid ]; then
      echo "$pid" > $ES_PID
      # No pid file but we found the process
      killPID $ES_PID
    fi
    cecho "Elasticsearch already shutdown or pid $ES_PID file not found";
  fi
}

function elasticsearchStatus(){
  cecho "------------------------------------------------------------------------"
  cecho "Elasticsearch status"
  cecho "------------------------------------------------------------------------"

  esStatusOut=$(curl --silent  -f "http://localhost:$ES_PORT/_cat/nodes?h=uptime,version")
  if [ $? -eq 0 ]; then
    cecho -e "PID\t"
    cecho `cat "$ES_PID"`
    cecho -e  "uptime:\t"
    echo "$esStatusOut" | awk '{print $1}'
    cecho -e  "Elasticsearch Version:\t"
    echo "$esStatusOut" | awk '{print $2}'
  else
    cecho -e "\033[38;5;196m"
    cecho "Elasticsearch is not running or is unreachable on port $ES_PORT"
    cecho -e "\033[0m"
  fi
}

function startTomcat() {
  cd $CRAFTER_BIN_DIR
  if [[ ! -d "$CRAFTER_BIN_DIR/dbms" ]] || [[ -z $(pidOf "$MARIADB_PORT") ]] || [[ $SPRING_PROFILES_ACTIVE = *crafter.studio.externalDb* ]] ;then
    cecho "------------------------------------------------------------------------"
    cecho "Starting Tomcat"
    cecho "------------------------------------------------------------------------"
    if [ ! -d $CATALINA_LOGS_DIR ]; then
      mkdir -p $CATALINA_LOGS_DIR;
    fi
    if [ ! -d $CATALINA_TMPDIR ]; then
      mkdir -p $CATALINA_TMPDIR;
    fi
    # Step 1, does the CATALINA_PID exist and is valid
    if [ ! -s "$CATALINA_PID" ]; then
      ## Before run check if the port is available.
      possiblePID=$(pidOf $TOMCAT_HTTP_PORT)

      if  [ -z "$possiblePID" ];  then
        $CRAFTER_BIN_DIR/apache-tomcat/bin/catalina.sh start
      else
        echo $possiblePID > $CATALINA_PID
        cecho "Process PID $possiblePID is listening port $TOMCAT_HTTP_PORT"
        cecho "Hijacking PID and saving into $CATALINA_PID"
        exit
      fi
    else
      # Is it really up?
      if ! checkPortForRunning $TOMCAT_HTTP_PORT $(cat "$CATALINA_PID");then
        exit 4
      fi
      if ! pgrep -u `whoami` -F "$CATALINA_PID" >/dev/null
      then
        cecho "Tomcat Pid file is not ok, forcing startup"
        rm "$CATALINA_PID"
        startTomcat
      fi
      cecho "Tomcat already started"
    fi
  else
    cecho ""
    cecho "Crafter CMS Database Port: $MARIADB_PORT is in use by process id $(pidOf "$MARIADB_PORT")."
    cecho "This might be because of a prior unsuccessful or incomplete shut down."
    cecho "Please terminate that process before attempting to start Crafter CMS."
    read -t 10 #Time out for the read, (if gradle start)
    exit -7
  fi
}

function debugTomcat() {
  cd $CRAFTER_BIN_DIR
  if [[ ! -d "$CRAFTER_BIN_DIR/dbms" ]] || [[ -z $(pidOf "$MARIADB_PORT") ]] ;then
    cecho "------------------------------------------------------------------------"
    cecho "Starting Tomcat"
    cecho "------------------------------------------------------------------------"
    if [ ! -d $CATALINA_LOGS_DIR ]; then
      mkdir -p $CATALINA_LOGS_DIR;
    fi
    if [ ! -d $CATALINA_TMPDIR ]; then
      mkdir -p $CATALINA_TMPDIR;
    fi
    # Step 1, does the CATALINA_PID exist and is valid
    if [ ! -s "$CATALINA_PID" ]; then
      ## Before run check if the port is available.
      possiblePID=$(pidOf $TOMCAT_HTTP_PORT)

      if  [ -z "$possiblePID" ];  then
        $CRAFTER_BIN_DIR/apache-tomcat/bin/catalina.sh jpda start
      else
        echo $possiblePID > $CATALINA_PID
        cecho "Process PID $possiblePID is listening port $TOMCAT_HTTP_PORT"
        cecho "Hijacking PID and saving into $CATALINA_PID"
        exit
      fi
    else
      # Is it really up?
      if ! checkPortForRunning $TOMCAT_HTTP_PORT $(cat "$CATALINA_PID");then
        exit 4
      fi
      if ! pgrep -u `whoami` -F "$CATALINA_PID" >/dev/null
      then
        cecho "Tomcat Pid file is not ok, forcing startup"
        rm "$CATALINA_PID"
        startTomcat
      fi
      cecho "Tomcat already started"
    fi
  else
    cecho ""
    cecho "Crafter CMS Database Port: $MARIADB_PORT is in use by process id $(pidOf "$MARIADB_PORT")."
    cecho "This might be because of a prior unsuccessful or incomplete shut down."
    cecho "Please terminate that process before attempting to start Crafter CMS."
    read -t 10 #Time out for the read, (if gradle start)
    exit -7
  fi
}

function stopTomcat() {
  cd $CRAFTER_BIN_DIR
  cecho "------------------------------------------------------------------------"
  cecho "Stopping Tomcat"
  cecho "------------------------------------------------------------------------"
  if [ -s "$CATALINA_PID" ]; then
    $CRAFTER_BIN_DIR/apache-tomcat/bin/shutdown.sh 10 -force
    if [ -e "$CATALINA_PID" ]; then
      if pgrep -F "$CATALINA_PID" > /dev/null
      then
        killPID $CATALINA_PID
      fi
      if [ $? -eq 0 ]; then
        rm $CATALINA_PID
      fi
    fi
  else
    pid=$(pidOf $TOMCAT_HTTP_PORT)
    if ! [ -z $pid ]; then
      # No pid file but we found the process
      echo "$pid" > $CATALINA_PID
      killPID $CATALINA_PID
    fi
    cecho "Tomcat already shutdown or pid $CATALINA_PID file not found";
  fi
}


function startMongoDB(){
  cecho "------------------------------------------------------------------------"
  cecho "Starting MongoDB"
  cecho "------------------------------------------------------------------------"
  if [ ! -s "$MONGODB_PID" ]; then
    if [ ! -d "$MONGODB_DATA_DIR" ]; then
      cecho "Creating : ${MONGODB_DATA_DIR}"
      mkdir -p "$MONGODB_DATA_DIR"
    fi

    if [ ! -d $MONGODB_LOGS_DIR ]; then
      cecho "Creating : ${MONGODB_LOGS_DIR}"
      mkdir -p $MONGODB_LOGS_DIR;
    fi

    if [ ! -d "$MONGODB_HOME" ]; then
      cd $CRAFTER_BIN_DIR
      mkdir $MONGODB_HOME
      cd $MONGODB_HOME
      cecho "MongoDB not found"
      java -jar $CRAFTER_BIN_DIR/craftercms-utils.jar download mongodb
      tar xvf mongodb.tgz --strip 1
      rm mongodb.tgz
    fi

    # Before run check if the port is available.
    possiblePID=$(pidOf $MONGODB_PORT)
    if  [ -z $possiblePID ];  then
      $MONGODB_HOME/bin/mongod --dbpath=$CRAFTER_DATA_DIR/mongodb --directoryperdb --journal --fork --logpath=$MONGODB_LOGS_DIR/mongod.log --port $MONGODB_PORT
    else
      echo $possiblePID > $MONGODB_PID
      cecho "Process PID $possiblePID is listening port $MONGODB_PORT"
      cecho "Hijacking PID and saving into $MONGODB_PID"
    fi
  else
    # Is it really up?
    if ! checkPortForRunning $MONGODB_PORT $(cat "$MONGODB_PID");then
      exit 7
    fi

    if ! pgrep -u `whoami` -F "$MONGODB_PID" >/dev/null
    then
      cecho "Mongo Pid file is not ok, forcing startup"
      rm "$MONGODB_PID"
      startMongoDB
    else
      cecho "MongoDB already started"
    fi
  fi
}

function isMongoNeeded() {
  for o in "$@"; do
    if [ $o = "skipMongo" ] || [ $o = "skipMongoDB" ]; then
      return 1
    fi
  done
  for o in "$@"; do
    if [ $o = "withMongo" ] || [ $o = "withMongoDB" ]; then
      return 0
    fi
  done
  test -s "$CATALINA_HOME/webapps/crafter-profile.war" || test -d "$CATALINA_HOME/webapps/crafter-profile"
}

function stopMongoDB(){
  cecho "------------------------------------------------------------------------"
  cecho "Stopping MongoDB"
  cecho "------------------------------------------------------------------------"
  if [ -s "$MONGODB_PID" ]; then
    case "$(uname -s)" in
      Linux)
      $MONGODB_HOME/bin/mongod --shutdown --dbpath=$CRAFTER_DATA_DIR/mongodb --logpath=$MONGODB_LOGS_DIR/mongod.log --port $MONGODB_PORT
      ;;
      *)
      pkill -3 -F "$MONGODB_PID"
      sleep 5 # % mississippis
      if pgrep -F "$MONGODB_PID" > /dev/null
      then
        pkill -9 -F "$MONGODB_PID" # force kill
      fi
      ;;
    esac
    if [ $? -eq 0 ]; then
      rm $MONGODB_PID
    fi
  else
    pid=$(pidOf $MONGODB_PORT)
    if ! [ -z $pid ]; then
      # No pid file but we found the process
      echo "$pid" > $MONGODB_PID
      killPID $MONGODB_PID
    else
      cecho "MongoDB already shutdown or pid $MONGODB_PID file not found";
    fi
  fi
}

function skipElasticsearch() {
  for o in "$@"; do
    if [ $o = "skipElasticsearch" ]; then
      return 0
    fi
  done
  return 1
}

function isSolrNeeded() {
  for o in "$@"; do
    if [ $o = "withSolr" ]; then
      return 0
    fi
  done
  return 1
}

function getStatus() {
  cecho "------------------------------------------------------------------------"
  cecho "$1 status"
  cecho "------------------------------------------------------------------------"
  statusOut=$(curl --silent  -f  "http://localhost:$2$3/api/$4/monitoring/status?token=$6")
  if [ $? -eq 0 ]; then
    cecho -e "PID\t"
    cecho `cat "$5"`
    cecho -e  "Uptime (in seconds):\t"
    echo "$statusOut"  |  grep -Eo '"uptime":\d+' | awk -F ":" '{print $2}'
    versionOut=$(curl --silent  -f  "http://localhost:$2$3/api/$4/monitoring/version?token=$6")
    if [ $? -eq 0 ]; then
      cecho -e "Version:\t"
      cecho -n $(cecho "$versionOut"  |  egrep -Eo '"packageVersion":"[^"]+"' | awk -F ":" '{print $2}')
      cecho -n " "
      echo "$versionOut"|  grep -Eo '"packageBuild":"[^"]+"' | awk -F ":" '{print $2}'
    fi
  else
    cecho -e "\033[38;5;196m"
    cecho "$1 is not running or is unreachable on port $2"
    cecho -e "\033[0m"
  fi
}

function solrStatus(){
  cecho "------------------------------------------------------------------------"
  cecho "Solr status"
  cecho "------------------------------------------------------------------------"

  solrStatusOut=$(curl --silent  -f "http://localhost:$SOLR_PORT/solr/admin/info/system?wt=json")
  if [ $? -eq 0 ]; then
    cecho -e "PID\t"
    cecho `cat "$CRAFTER_HOME/bin/solr/bin/solr-$SOLR_PORT.pid"`
    cecho -e  "Uptime (in minutes):\t"
    echo "$solrStatusOut"  |  grep -Eo '"upTimeMS":\d+' | awk -F ":" '{print ($2/1000)/60}' | bc
    cecho -e  "Solr Version:\t"
    echo "$solrStatusOut"  |  grep -Eo '"solr-spec-version":"[^"]+"' | awk -F ":" '{print $2}'
  else
    cecho -e "\033[38;5;196m"
    cecho "Solr is not running or is unreachable on port $SOLR_PORT"
    cecho -e "\033[0m"
  fi
}

function deployerStatus(){
  getStatus "Crafter Deployer" $DEPLOYER_PORT "" "1" $DEPLOYER_PID $DEPLOYER_MANAGEMENT_TOKEN
}

function searchStatus(){
  getStatus "Crafter Search" $TOMCAT_HTTP_PORT "/crafter-search" "1" $CATALINA_PID $SEARCH_MANAGEMENT_TOKEN
}

function engineStatus(){
  getStatus "Crafter Engine" $TOMCAT_HTTP_PORT "" "1" $CATALINA_PID $ENGINE_MANAGEMENT_TOKEN
}

function studioStatus(){
  getStatus "Crafter Studio" $TOMCAT_HTTP_PORT "/studio" "2" $CATALINA_PID $STUDIO_MANAGEMENT_TOKEN
}

function profileStatus(){
  getStatus "Crafter Profile" $TOMCAT_HTTP_PORT "/crafter-profile" "1" $CATALINA_PID $PROFILE_MANAGEMENT_TOKEN
}

function socialStatus(){
  getStatus "Crafter Social" $TOMCAT_HTTP_PORT "/crafter-social" "3" $CATALINA_PID $SOCIAL_MANAGEMENT_TOKEN
}


function mariadbStatus(){
  cecho "------------------------------------------------------------------------"
  cecho "MariaDB status"
  cecho "------------------------------------------------------------------------"
  if [ -s "$MARIADB_PID" ]; then
    cecho -e "PID \t"
    cecho $(cat "$MARIADB_PID")
  else
    cecho "MariaDB is not running."
  fi
}

function mongoDbStatus(){
  cecho "------------------------------------------------------------------------"
  cecho "MongoDB status"
  cecho "------------------------------------------------------------------------"
 if $(isMongoNeeded "$@") || [ ! -z $(pidOf $MONGODB_PORT) ]; then
    if [ -e "$MONGODB_PID" ]; then
      cecho -e "MongoDB PID"
      cecho $(cat $MONGODB_PID)
    else
      cecho -e "\033[38;5;196m"
      cecho " MongoDB is not running"
      cecho -e "\033[0m"
    fi
 elif [ ! -d "$MONGODB_HOME" ]; then
    cecho "MongoDB is not installed."
  else
    cecho "MongoDB is not running"
  fi
}

function start() {
  startDeployer
  if ! skipElasticsearch "$@"; then
    startElasticsearch
  fi
  if isSolrNeeded "$@"; then
    startSolr
  fi
  if isMongoNeeded "$@"; then
    startMongoDB
  fi
  startTomcat
  printTailInfo
}

function debug() {
  debugDeployer
  if ! skipElasticsearch "$@"; then
    debugElasticsearch
  fi
  if isSolrNeeded "$@"; then
    debugSolr
  fi
  if isMongoNeeded "$@"; then
    startMongoDB
  fi
  debugTomcat
  printTailInfo
}

function stop() {
  stopTomcat
  if [ ! -z $(pidOf $MONGODB_PORT) ]; then
     stopMongoDB
  fi
  stopDeployer
  if [ ! -z $(pidOf $ES_PORT) ]; then
    stopElasticsearch
  fi
  if [ ! -z $(pidOf $SOLR_PORT) ]; then
    stopSolr
  fi
}

function status(){
  elasticsearchStatus
  solrStatus
  deployerStatus
  engineStatus
  searchStatus
  if [ -f "$CRAFTER_BIN_DIR/apache-tomcat/webapps/studio.war" ]; then
    studioStatus
    mariadbStatus
  fi
  if [ -f "$CRAFTER_BIN_DIR/apache-tomcat/webapps/crafter-profile.war" ]; then
    mongoDbStatus
    profileStatus
    if [ -f "$CRAFTER_BIN_DIR/apache-tomcat/webapps/crafter-social.war" ]; then
      socialStatus
    fi
  fi

}

function doBackup() {
  local targetName=$1
  if [ -z "$targetName" ]; then
    if [ -f "$CRAFTER_BIN_DIR/apache-tomcat/webapps/studio.war" ]; then
      targetName="crafter-authoring-backup"
    else
      targetName="crafter-delivery-backup"
    fi
  fi

  local currentDate=$(date +'%Y-%m-%d-%H-%M-%S')
  local targetFolder="$CRAFTER_BACKUPS_DIR"
  local targetFile="$targetFolder/$targetName.$currentDate.tar.gz"
  local tempFolder="$CRAFTER_BACKUPS_DIR/temp"

  cecho "------------------------------------------------------------------------"
  cecho "Starting backup"
  cecho "------------------------------------------------------------------------"

  if [ -d "$tempFolder" ]; then
    rm -r "$tempFolder"
  fi

  mkdir -p "$tempFolder"
  mkdir -p "$targetFolder"

  if [ -f "$targetFile" ]; then
    rm "$targetFile"
  fi

  # MySQL Dump
  if [[ $SPRING_PROFILES_ACTIVE = *crafter.studio.externalDb* ]]; then
    cecho "------------------------------------------------------------------------"
    cecho "Backing up external DB"
    cecho "------------------------------------------------------------------------"

    # Check that the mysqldump is in the path
    if type "mysqldump" >/dev/null 2>&1; then
      export MYSQL_PWD=$MARIADB_PASSWD
      mysqldump --databases crafter --user=$MARIADB_USER --host=$MARIADB_HOST --port=$MARIADB_PORT --protocol=tcp --routines > "$tempFolder/crafter.sql"
      mysqldump --user=$MARIADB_ROOT_USER --password=$MARIADB_ROOT_PASSWD --host=$MARIADB_HOST --port=$MARIADB_PORT --protocol=tcp --skip-add-drop-table --no-create-info --insert-ignore --complete-insert mysql user db global_priv -r $tempFolder/users.sql
      abortOnError
    else
      cecho "External DB backup failed, unable to find mysqldump in the PATH. Please make sure you have a proper MariaDB/MySQL client installed"
      exit 1
    fi
  elif [ -d "$MARIADB_DATA_DIR" ]; then
    # Start DB if necessary
    DB_STARTED=false
    if [ -z $(pidOf "$MARIADB_PORT") ]; then
      mkdir -p "$CRAFTER_BIN_DIR/dbms"
      cecho "------------------------------------------------------------------------"
      cecho "Starting DB"
      cecho "------------------------------------------------------------------------"
      java -jar -DmariaDB4j.port=$MARIADB_PORT -DmariaDB4j.baseDir="$CRAFTER_BIN_DIR/dbms" -DmariaDB4j.dataDir="$MARIADB_DATA_DIR" $CRAFTER_BIN_DIR/mariaDB4j-app.jar &
      $CRAFTER_BIN_DIR/wait-for-it.sh -h "$MARIADB_HOST" -p "$MARIADB_PORT" -t $MARIADB_TCP_TIMEOUT
      DB_STARTED=true
    fi

    #Do dump
    cecho "------------------------------------------------------------------------"
    cecho "Backing up embedded DB"
    cecho "------------------------------------------------------------------------"
    export MYSQL_PWD=$MARIADB_ROOT_PASSWD
    $CRAFTER_BIN_DIR/dbms/bin/mysqldump --databases crafter --user=$MARIADB_ROOT_USER --host=$MARIADB_HOST --port=$MARIADB_PORT --protocol=tcp --routines > "$tempFolder/crafter.sql"
    $CRAFTER_BIN_DIR/dbms/bin/mysqldump --user=$MARIADB_ROOT_USER --password=$MARIADB_ROOT_PASSWD --host=$MARIADB_HOST --port=$MARIADB_PORT --protocol=tcp --skip-add-drop-table --no-create-info --insert-ignore --complete-insert mysql user db global_priv -r $tempFolder/users.sql
    abortOnError

    if [ "$DB_STARTED" = true ]; then
      # Stop DB
      cecho "------------------------------------------------------------------------"
      cecho "Stopping DB"
      cecho "------------------------------------------------------------------------"
      kill $(cat mariadb4j.pid)
      sleep 10
    fi
  fi

  # MongoDB Dump
  if [ -d "$MONGODB_DATA_DIR" ]; then
    # Start MongoDB if necessary
    MONGODB_STARTED=false
    if [ -z $(pidOf "$MONGODB_PORT") ]; then
      startMongoDB
      sleep 15
      MONGODB_STARTED=true
    fi

    cecho "------------------------------------------------------------------------"
    cecho "Backing up mongodb"
    cecho "------------------------------------------------------------------------"

    $MONGODB_HOME/bin/mongodump --port $MONGODB_PORT --out "$tempFolder/mongodb"
    abortOnError

    CURRENT_DIR=$(pwd)

    cd "$tempFolder/mongodb"
    runCmd "tar cvf \"$tempFolder/mongodb.tar\" ."
    abortOnError

    cd $CURRENT_DIR
    rm -r "$tempFolder/mongodb"

    if [ "$MONGODB_STARTED" = true ]; then
      # Stop MongoDB
      stopMongoDB
    fi
  fi

  # ZIP git repos
  if [ -d "$CRAFTER_DATA_DIR/repos" ]; then
    cecho "------------------------------------------------------------------------"
    cecho "Backing up git repos"
    cecho "------------------------------------------------------------------------"
    cd "$CRAFTER_DATA_DIR/repos"
    runCmd "tar cvf \"$tempFolder/repos.tar\" ."
    abortOnError
  fi

  # ZIP solr indexes
  cecho "------------------------------------------------------------------------"
  cecho "Backing up solr indexes"
  cecho "------------------------------------------------------------------------"
  if [ -d "$SOLR_INDEXES_DIR" ]; then
    cecho "Adding solr indexes"
    cd "$SOLR_INDEXES_DIR"
    runCmd "tar cvf \"$tempFolder/indexes.tar\" ."
    abortOnError
  fi

  # ZIP elasticsearch indexes
  cecho "------------------------------------------------------------------------"
  cecho "Backing up elasticsearch indexes"
  cecho "------------------------------------------------------------------------"
  if [ -d "$ES_INDEXES_DIR" ]; then
    cecho "Adding elasticsearch indexes"
    cd "$ES_INDEXES_DIR"
    runCmd "tar cvf \"$tempFolder/indexes-es.tar\" ."
    abortOnError
  fi

  # ZIP deployer data
  if [ -d "$DEPLOYER_DATA_DIR" ]; then
   cecho "------------------------------------------------------------------------"
   cecho "Backing up deployer data"
   cecho "------------------------------------------------------------------------"
   cd "$DEPLOYER_DATA_DIR"
   runCmd "tar cvf \"$tempFolder/deployer.tar\" ."
   abortOnError
  fi

  # ZIP everything (without compression)
  cecho "------------------------------------------------------------------------"
  cecho "Packaging everything"
  cecho "------------------------------------------------------------------------"
  cd "$tempFolder"
  runCmd "tar czvf \"$targetFile\" ."
  abortOnError

  rmDirContents "$tempFolder"
  rmdir "$tempFolder"

  cecho "------------------------------------------------------------------------"
  cecho "> Backup completed and saved to $targetFile"
}

function doRestore() {
  local pid=$(pidOf $TOMCAT_HTTP_PORT)
  if ! [ -z $pid ]; then
    cecho "Please stop the system before starting the restore process."
    exit 1
  fi

  local sourceFile=$1
  if [ ! -f "$sourceFile" ]; then
    cecho "The source file $sourceFile does not exist"
    help
    exit 1
  fi

  local tempFolder="$CRAFTER_BACKUPS_DIR/temp"
  local packageExt=""

  read -p "Warning, you're about to restore CrafterCMS from a backup, which will wipe the\
  existing sites and associated database and replace everything with the restored data. If you\
  care about the existing state of the system then stop this process, backup the system, and then\
  attempt the restore. Are you sure you want to proceed? (yes/no) "
  if [ "$REPLY" != "yes" ] && [ "$REPLY" != "y" ]; then
    cecho "Canceling restore"
    exit 0
  fi

  cecho "------------------------------------------------------------------------"
  cecho "Clearing all existing data"
  cecho "------------------------------------------------------------------------"
  rmDirContents "$MONGODB_DATA_DIR"
  rmDirContents "$CRAFTER_DATA_DIR/repos"
  rmDirContents "$SOLR_INDEXES_DIR"
  rmDirContents "$ES_INDEXES_DIR"
  rmDirContents "$DEPLOYER_DATA_DIR"
  rmDirContents "$MARIADB_DATA_DIR"

  cecho "------------------------------------------------------------------------"
  cecho "Starting restore from $sourceFile"
  cecho "------------------------------------------------------------------------"
  mkdir -p "$tempFolder"

  # UNZIP everything
  if [[ "$sourceFile" == *.tar.gz ]]; then
    runCmd "tar xzvf \"$sourceFile\" -C \"$tempFolder\""
    abortOnError

    packageExt="tar"
  else
    java -jar $CRAFTER_BIN_DIR/craftercms-utils.jar unzip "$sourceFile" "$tempFolder"
    abortOnError

    packageExt="zip"
  fi

  # MongoDB Dump
  if [ -f "$tempFolder/mongodb.$packageExt" ]; then
    mkdir -p "$tempFolder/mongodb"

    startMongoDB
    sleep 15

    cecho "------------------------------------------------------------------------"
    cecho "Restoring MongoDB"
    cecho "------------------------------------------------------------------------"

    if [ "$packageExt" == "tar" ]; then
      runCmd "tar xvf \"$tempFolder/mongodb.tar\" -C \"$tempFolder/mongodb\""
      abortOnError
    else
      runCmd "java -jar $CRAFTER_BIN_DIR/craftercms-utils.jar unzip \"$tempFolder/mongodb.zip\" \"$tempFolder/mongodb\""
      abortOnError
    fi

    runCmd "$CRAFTER_BIN_DIR/mongodb/bin/mongorestore --port $MONGODB_PORT \"$tempFolder/mongodb\""
    abortOnError

    stopMongoDB
  fi

  # UNZIP git repos
  if [ -f "$tempFolder/repos.$packageExt" ]; then
    mkdir -p "$CRAFTER_DATA_DIR/repos"

    cecho "------------------------------------------------------------------------"
    cecho "Restoring git repos"
    cecho "------------------------------------------------------------------------"

    if [ "$packageExt" == "tar" ]; then
      runCmd "tar xvf \"$tempFolder/repos.tar\" -C \"$CRAFTER_DATA_DIR/repos\""
      abortOnError
    else
      runCmd "java -jar $CRAFTER_BIN_DIR/craftercms-utils.jar unzip \"$tempFolder/repos.zip\" \"$CRAFTER_DATA_DIR/repos\""
      abortOnError
    fi
  fi

  # UNZIP solr indexes
  if [ -f "$tempFolder/indexes.$packageExt" ]; then
    mkdir -p "$SOLR_INDEXES_DIR"

    cecho "------------------------------------------------------------------------"
    cecho "Restoring solr indexes"
    cecho "------------------------------------------------------------------------"

    if [ "$packageExt" == "tar" ]; then
      runCmd "tar xvf \"$tempFolder/indexes.tar\" -C \"$SOLR_INDEXES_DIR\""
      abortOnError
    else
      runCmd "java -jar $CRAFTER_BIN_DIR/craftercms-utils.jar unzip \"$tempFolder/indexes.zip\" \"$SOLR_INDEXES_DIR\""
      abortOnError
    fi
  fi

  # UNZIP elasticsearch indexes
  if [ -f "$tempFolder/indexes-es.$packageExt" ]; then
    mkdir -p "$ES_INDEXES_DIR"

    cecho "------------------------------------------------------------------------"
    cecho "Restoring elasticsearch indexes"
    cecho "------------------------------------------------------------------------"

    if [ "$packageExt" == "tar" ]; then
      runCmd "tar xvf \"$tempFolder/indexes-es.tar\" -C \"$ES_INDEXES_DIR\""
      abortOnError
    else
      runCmd "java -jar $CRAFTER_BIN_DIR/craftercms-utils.jar unzip \"$tempFolder/indexes-es.zip\" \"$ES_INDEXES_DIR\""
      abortOnError
    fi
  fi

  # UNZIP deployer data
  if [ -f "$tempFolder/deployer.$packageExt" ]; then
    mkdir -p "$DEPLOYER_DATA_DIR"

    cecho "------------------------------------------------------------------------"
    cecho "Restoring deployer data"
    cecho "------------------------------------------------------------------------"

    if [ "$packageExt" == "tar" ]; then
      runCmd "tar xvf \"$tempFolder/deployer.tar\" -C \"$DEPLOYER_DATA_DIR\""
      abortOnError
    else
      runCmd "java -jar $CRAFTER_BIN_DIR/craftercms-utils.jar unzip \"$tempFolder/deployer.zip\" \"$DEPLOYER_DATA_DIR\""
      abortOnError
    fi
  fi

  # Restore DB
  if [ -f "$tempFolder/crafter.sql" ]; then
    if [[ $SPRING_PROFILES_ACTIVE = *crafter.studio.externalDb* ]]; then
      cecho "------------------------------------------------------------------------"
      cecho "Restoring external DB"
      cecho "------------------------------------------------------------------------"

      # Check that the mysql is in the path
      if type "mysql" >/dev/null 2>&1; then
        export MYSQL_PWD=$MARIADB_PASSWD
        mysql --user=$MARIADB_USER --host=$MARIADB_HOST --port=$MARIADB_PORT --protocol=tcp --binary-mode < "$tempFolder/crafter.sql"
        if [ -f "$tempFolder/users.sql" ]; then
          mysql --user=$MARIADB_USER --host=$MARIADB_HOST --port=$MARIADB_PORT --protocol=tcp --binary-mode mysql < "$tempFolder/users.sql"
        else
          cecho "Users backup does not exists. Skipping restore users"
        fi
        abortOnError
      else
        cecho "External DB restore failed, unable to find mysql in the PATH. Please make sure you have a proper MariaDB/MySQL client installed"
        exit 1
      fi
    else
      mkdir -p "$MARIADB_DATA_DIR"
      #Start DB
      cecho "------------------------------------------------------------------------"
      cecho "Starting DB"
      cecho "------------------------------------------------------------------------"
      java -jar -DmariaDB4j.port=$MARIADB_PORT -DmariaDB4j.baseDir="$CRAFTER_BIN_DIR/dbms" -DmariaDB4j.dataDir="$MARIADB_DATA_DIR" $CRAFTER_BIN_DIR/mariaDB4j-app.jar &
      $CRAFTER_BIN_DIR/wait-for-it.sh -h "$MARIADB_HOST" -p "$MARIADB_PORT" -t $MARIADB_TCP_TIMEOUT

      # Import
      cecho "------------------------------------------------------------------------"
      cecho "Restoring embedded DB"
      cecho "------------------------------------------------------------------------"
      export MYSQL_PWD=$MARIADB_ROOT_PASSWD
      $CRAFTER_BIN_DIR/dbms/bin/mysql --user=$MARIADB_ROOT_USER --host=$MARIADB_HOST --port=$MARIADB_PORT --protocol=tcp --binary-mode < "$tempFolder/crafter.sql"
      if [ -f "$tempFolder/users.sql" ]; then
        $CRAFTER_BIN_DIR/dbms/bin/mysql --user=$MARIADB_ROOT_USER --host=$MARIADB_HOST --port=$MARIADB_PORT --protocol=tcp --binary-mode mysql < "$tempFolder/users.sql"
      else
        cecho "Users backup does not exists. Skipping restore users"
      fi
      abortOnError

      # Stop DB
      cecho "------------------------------------------------------------------------"
      cecho "Stopping DB"
      cecho "------------------------------------------------------------------------"
      kill $(cat mariadb4j.pid)
      sleep 10
    fi
  fi

  rm -r "$tempFolder"
  cecho "------------------------------------------------------------------------"
  cecho "> Restore complete, you may now start the system"
}

function doUpgradeDB() {
  cecho "------------------------------------------------------------------------"
  cecho "Starting upgrade of embedded database $MARIADB_DATA_DIR"
  cecho "------------------------------------------------------------------------"

  # Upgrade database
  if [ -d "$MARIADB_DATA_DIR" ]; then
    # Start DB if necessary
    DB_STARTED=false
    if [ -z $(pidOf "$MARIADB_PORT") ]; then
      mkdir -p "$CRAFTER_BIN_DIR/dbms"
      cecho "------------------------------------------------------------------------"
      cecho "Starting DB"
      cecho "------------------------------------------------------------------------"
      java -jar -DmariaDB4j.port=$MARIADB_PORT -DmariaDB4j.baseDir="$CRAFTER_BIN_DIR/dbms" -DmariaDB4j.dataDir="$MARIADB_DATA_DIR" $CRAFTER_BIN_DIR/mariaDB4j-app.jar &
      sleep 30
      DB_STARTED=true
    fi

    # Do upgrade
    cecho "------------------------------------------------------------------------"
    cecho "Upgrading embedded DB"
    cecho "------------------------------------------------------------------------"
    export MYSQL_PWD=$MARIADB_ROOT_PASSWD
    $CRAFTER_BIN_DIR/dbms/bin/mysql_upgrade --user=$MARIADB_ROOT_USER --host=$MARIADB_HOST --port=$MARIADB_PORT --protocol=tcp
    abortOnError

    if [ "$DB_STARTED" = true ]; then
      # Stop DB
      cecho "------------------------------------------------------------------------"
      cecho "Stopping DB"
      cecho "------------------------------------------------------------------------"
      kill $(cat mariadb4j.pid)
      sleep 10
    fi

    cecho "------------------------------------------------------------------------"
    cecho "> Upgrade database completed"
  else
    cecho 'No embedded DB found, skipping upgrade'
  fi
}

function rmDirContents() {
  DIR=$1
  if [ ! -z "$DIR" ] && [ -d "$DIR" ]; then
    # 2>/dev/null removes the warnings about refusing to remove '.' or '..'
    rm -rf "$DIR"/* "$DIR"/.* 2>/dev/null
  fi
}

function abortOnError() {
  EXIT_CODE=$?
  if [ $EXIT_CODE != 0 ]; then
    cecho "Unable to continue, an error occurred or the script was forcefully stopped"
    exit 1
  fi
}

function logo() {
  cecho -e "\033[38;5;196m"
  cecho " ██████╗ ██████╗   █████╗  ███████╗ ████████╗ ███████╗ ██████╗      ██████╗ ███╗   ███╗ ███████╗"
  cecho "██╔════╝ ██╔══██╗ ██╔══██╗ ██╔════╝ ╚══██╔══╝ ██╔════╝ ██╔══██╗    ██╔════╝ ████╗ ████║ ██╔════╝"
  cecho "██║      ██████╔╝ ███████║ █████╗      ██║    █████╗   ██████╔╝    ██║      ██╔████╔██║ ███████╗"
  cecho "██║      ██╔══██╗ ██╔══██║ ██╔══╝      ██║    ██╔══╝   ██╔══██╗    ██║      ██║╚██╔╝██║ ╚════██║"
  cecho "╚██████╗ ██║  ██║ ██║  ██║ ██║         ██║    ███████╗ ██║  ██║    ╚██████╗ ██║ ╚═╝ ██║ ███████║"
  cecho " ╚═════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚═╝         ╚═╝    ╚══════╝ ╚═╝  ╚═╝     ╚═════╝ ╚═╝     ╚═╝ ╚══════╝"
  cecho -e "\033[0m"
}

case $1 in
  debug)
    logo
    debug "$@"
  ;;
  start)
    logo
    start "$@"
  ;;
  stop)
    logo
    stop $2
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
  start_elasticsearch)
    logo
    startElasticsearch
  ;;
  debug_elasticsearch)
    logo
    debugElasticsearch
  ;;
  stop_elasticsearch)
    logo
    stopElasticsearch
  ;;
  debug_tomcat)
    logo
    debugTomcat
  ;;
  start_tomcat)
    logo
    startTomcat start
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
  status)
    status
  ;;
  backup)
    doBackup $2
  ;;
  restore)
    doRestore $2
  ;;
  upgradedb)
    doUpgradeDB $2
  ;;
  status_engine)
    engineStatus
  ;;
  status_studio)
    studioStatus
  ;;
  status_profile)
    profileStatus
  ;;
  status_social)
    socialStatus
  ;;
  status_search)
    searchStatus
  ;;
  status_deployer)
    deployerStatus
  ;;
  status_elasticsearch)
    elasticsearchStatus
  ;;
  status_solr)
    solrStatus
  ;;
  status_mongodb)
    mongoDbStatus
  ;;
  status_mariadb)
    mariadbStatus
  ;;
  --v | --version)
    version
  ;;
  *)
    help
  ;;
esac
