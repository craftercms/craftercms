#!/usr/bin/env bash

if [ "$(whoami)" == "root" ]; then
	echo -e "\033[38;5;196m"
	echo -e "Crafter CMS cowardly refuses to run as root."
    echo -e "Running as root is dangerous and is not supported."
    echo -e "\033[0m"
	exit 1
fi

OSARCH=$(getconf LONG_BIT)
if [[ $OSARCH -eq "32" ]]; then
  echo -e "\033[38;5;196m"
  echo "CrafterCMS is not supported in a 32bit os"
  echo -e "\033[0m"
  read -r
  exit 5
fi

export CRAFTER_HOME=${CRAFTER_HOME:=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )}
export CRAFTER_ROOT=${CRAFTER_ROOT:=$( cd "$CRAFTER_HOME/.." && pwd )}
export DEPLOYER_HOME=${DEPLOYER_HOME:=$CRAFTER_HOME/crafter-deployer}

. "$CRAFTER_HOME/crafter-setenv.sh"

function help() {
  echo $(basename $BASH_SOURCE)
  echo "    start [forceMongo], Starts Tomcat, Deployer and Solr, if forceMongo Mongodb will be run"
  echo "    stop  [forceMongo], Stops Tomcat, Deployer and Solr if forceMongo Mongodb will be run"
  echo "    debug [forceMongo], Starts Tomcat, Deployer and Solr in debug mode if forceMongo Mongodb will be run"
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
  echo "    status, Status of all CrafterCms subsystems"
  echo "    status_tomcat,Status of Tomcat"
  echo "    status_deployer, Status of Deployer"
  echo "    status_solr, Status of Solr"
  echo "    status_mariadb, Status of MariaDB"
  echo "    status_mongodb, Status of MonoDb"
  echo "    backup <name>, Perform a backup of all data"
  echo "    restore <file>, Perform a restore of all data"
  echo ""
  echo "For more information use '$(basename $BASH_SOURCE) man'"
  exit 2;
}


function version(){
 echo "Copyright (C) 2007-2018 Crafter Software Corporation. All rights reserved."
 echo "Version @VERSION@-@GIT_BUILD_ID@"
}

function manPages(){
    man "$CRAFTER_HOME/crafter.sh.1"
}
function pidOf(){
  pid=$(lsof -i :$1 | grep LISTEN | awk '{print $2}' | grep -v PID)
  echo $pid
}

function killPID(){
  pkill -15 -F "$1"
  sleep 5 # % mississippis
  if pgrep -F "$1"
  then
    pkill -9 -F "$1" # force kill
  fi
}

function checkPortForRunning(){
  result=1
  pidForOpenPort=$(pidOf $1)
  if ! [ "$pidForOpenPort"=="$2" ]; then
    echo -e "\033[38;5;196m"
    echo " Port $1 is taken by PID $pidForOpenPort"
    echo " Please shutdown process with PID $pidForOpenPort"
    echo -e "\033[0m"
  else
    result=0
  fi
  return $result
}

function printTailInfo(){
  echo -e "\033[38;5;196m"
  echo "Log files live here: \"$CRAFTER_ROOT/logs/\". "
  echo "To follow the main tomcat log, you can \"tail -f $CRAFTER_ROOT/logs/tomcat/catalina.out\""
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
      $CRAFTER_HOME/solr/bin/solr start -p $SOLR_PORT -s $SOLR_HOME -Dcrafter.solr.index=$SOLR_INDEXES_DIR -a "$SOLR_JAVA_OPTS"
      echo $(pidOf $SOLR_PORT) > $SOLR_PID
    else
      echo $possiblePID > $SOLR_PID
      echo "Process PID $possiblePID is listening port $SOLR_PORT"
      echo "Hijacking PID and saving into $SOLR_PID"
      exit 0
    fi
  else
    # IS it really up ?
    if ! checkPortForRunning $SOLR_PORT $(cat "$SOLR_PID");then
      exit 6
    fi
    if ! pgrep -u `whoami` -F "$SOLR_PID" >/dev/null
    then
      echo "Solr Pid file is not ok, forcing startup"
      rm "$SOLR_PID"
      startSolr
    fi
    echo "Solr already started"
  fi
}

function debugSolr() {
  cd $CRAFTER_HOME
  echo "------------------------------------------------------------"
  echo "Starting Solr"
  echo "------------------------------------------------------------"
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
      $CRAFTER_HOME/solr/bin/solr start -p $SOLR_PORT -s $SOLR_HOME -Dcrafter.solr.index=$SOLR_INDEXES_DIR \
      -a "$SOLR_JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=1044"
      echo $(pidOf $SOLR_PORT) > $SOLR_PID
    else
      echo $possiblePID > $SOLR_PID
      echo "Process PID $possiblePID is listening port $SOLR_PORT"
      echo "Hijacking PID and saving into $SOLR_PID"
      exit
    fi
  else
    # IS it really up ?
    if ! checkPortForRunning $SOLR_PORT $(cat "$SOLR_PID");then
      exit 6
    fi
    if ! pgrep -u `whoami` -F "$SOLR_PID" >/dev/null
    then
      echo "Solr Pid file is not ok, forcing startup"
      rm "$SOLR_PID"
      debugSolr
    fi
    echo "Solr already started"
  fi
}

function stopSolr() {
  cd $CRAFTER_HOME
  echo "------------------------------------------------------------"
  echo "Stopping Solr"
  echo "------------------------------------------------------------"
  if [ -s "$SOLR_PID" ]; then
    $CRAFTER_HOME/solr/bin/solr stop
    if pgrep -F "$SOLR_PID"
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
    echo "Solr already shutdown or pid $SOLR_PID file not found";
  fi
}

function startTomcat() {
  cd $CRAFTER_HOME
  if [[ ! -d "$CRAFTER_HOME/dbms" ]] || [[ -z $(pidOf "$MARIADB_PORT") ]] ;then

      echo "------------------------------------------------------------"
      echo "Starting Tomcat"
      echo "------------------------------------------------------------"
      if [ ! -d $CATALINA_LOGS_DIR ]; then
        mkdir -p $CATALINA_LOGS_DIR;
      fi
      # Step 1, does the CATALINA_PID exist and is valid
      if [ ! -s "$CATALINA_PID" ]; then
        ## Before run check if the port is available.
        possiblePID=$(pidOf $TOMCAT_HTTP_PORT)

        if  [ -z "$possiblePID" ];  then
          export CATALINA_OPTS="$CATALINA_OPTS -Dcrafter.home=$CRAFTER_ROOT"
          $CRAFTER_HOME/apache-tomcat/bin/catalina.sh start -secure
        else
          echo $possiblePID > $CATALINA_PID
          echo "Process PID $possiblePID is listening port $TOMCAT_HTTP_PORT"
          echo "Hijacking PID and saving into $CATALINA_PID"
          exit
        fi
      else
        # Is it really up?
        if ! checkPortForRunning $TOMCAT_HTTP_PORT $(cat "$CATALINA_PID");then
          exit 4
        fi
        if ! pgrep -u `whoami` -F "$CATALINA_PID" >/dev/null
        then
          echo "Tomcat Pid file is not ok, forcing startup"
          rm "$CATALINA_PID"
          startTomcat
        fi
        echo "Tomcat already started"
      fi
      else
       echo ""
       echo "Crafter CMS Database Port: $MARIADB_PORT is in use by process id $(pidOf "$MARIADB_PORT")."
       echo "This might be because of a prior unsuccessful or incomplete shut down."
       echo "Please terminate that process before attempting to start Crafter CMS."
       read -t 10 #Time out for the read, (if gradle start)
       exit -7
  fi
}

function debugTomcat() {
  cd $CRAFTER_HOME
  echo "------------------------------------------------------------"
  echo "Starting Tomcat"
  echo "------------------------------------------------------------"
  if [ ! -d $CATALINA_LOGS_DIR ]; then
    mkdir -p $CATALINA_LOGS_DIR;
  fi
  # Step 1, does the CATALINA_PID exist and is valid
  if [ ! -s "$CATALINA_PID" ]; then
    # Before run check if the port is available.
    possiblePID=$(pidOf $TOMCAT_HTTP_PORT)

    if  [ -z "$possiblePID" ];  then
      $CRAFTER_HOME/apache-tomcat/bin/catalina.sh jpda start;
    else
      echo $possiblePID > $CATALINA_PID
      echo "Process PID $possiblePID is listening port $TOMCAT_HTTP_PORT"
      echo "Hijacking PID and saving into $CATALINA_PID"
      exit
    fi
  else
    # Is it really up?
    if ! checkPortForRunning $TOMCAT_HTTP_PORT $(cat "$CATALINA_PID");then
      exit 4
    fi
    if ! pgrep -u `whoami` -F "$CATALINA_PID" >/dev/null
    then
      echo "Tomcat Pid file is not ok, forcing startup"
      rm "$CATALINA_PID"
      debugTomcat
    fi
    echo "Tomcat already started"
  fi
}

function stopTomcat() {
  cd $CRAFTER_HOME
  echo "------------------------------------------------------------"
  echo "Stopping Tomcat"
  echo "------------------------------------------------------------"
  if [ -s "$CATALINA_PID" ]; then
    $CRAFTER_HOME/apache-tomcat/bin/shutdown.sh -force
    if [ -e "$CATALINA_PID" ]; then
      if pgrep -F "$CATALINA_PID"
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
    echo "Tomcat already shutdown or pid $CATALINA_PID file not found";
  fi
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
    # Before run check if the port is available.
    possiblePID=$(pidOf $MONGODB_PORT)
    if  [ -z $possiblePID ];  then
      $MONGODB_HOME/bin/mongod --dbpath=$CRAFTER_ROOT/data/mongodb --directoryperdb --journal --fork --logpath=$MONGODB_LOGS_DIR/mongod.log --port $MONGODB_PORT
    else
      echo $possiblePID > $MONGODB_PID
      echo "Process PID $possiblePID is listening port $MONGODB_PORT"
      echo "Hijacking PID and saving into $MONGODB_PID"
    fi
  else
    # Is it really up?
    if ! checkPortForRunning $MONGODB_PORT $(cat "$MONGODB_PID");then
      exit 7
    fi

    if ! pgrep -u `whoami` -F "$MONGODB_PID" >/dev/null
    then
      echo "Mongo Pid file is not ok, forcing startup"
      rm "$MONGODB_PID"
      startMongoDB
    else
      echo "MongoDB already started"
    fi
  fi
}


function isMongoNeeded() {
   if [ -z "$1" ]; then
    test -s $PROFILE_WAR_PATH || test -d $PROFILE_DEPLOY_WAR_PATH
   else
      test "$1" = "forceMongo"
   fi
}

function stopMongoDB(){
  echo "------------------------------------------------------------"
  echo "Stopping MongoDB"
  echo "------------------------------------------------------------"
  if [ -s "$MONGODB_PID" ]; then
    case "$(uname -s)" in
      Linux)
      $MONGODB_HOME/bin/mongod --shutdown --dbpath=$CRAFTER_ROOT/data/mongodb --logpath=$MONGODB_LOGS_DIR/mongod.log --port $MONGODB_PORT
      ;;
      *)
      pkill -3 -F "$MONGODB_PID"
      sleep 5 # % mississippis
      if pgrep -F "$MONGODB_PID"
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
      echo "MongoDB already shutdown or pid $MONGODB_PID file not found";
    fi
  fi
}


function solrStatus(){
  echo "------------------------------------------------------------"
  echo "SOLR status                                                 "
  echo "------------------------------------------------------------"

  solrStatusOut=$(curl --silent  -f "http://localhost:$SOLR_PORT/solr/admin/info/system?wt=json")
  if [ $? -eq 0 ]; then
    echo -e "PID\t"
    echo `cat "$CRAFTER_ROOT/bin/solr/bin/solr-$SOLR_PORT.pid"`
    echo -e  "uptime (in minutes):\t"
    echo "$solrStatusOut"  | python -m json.tool | grep upTimeMS | awk -F"[,|:]" '{print $2}'| awk '{print ($1/1000)/60}'| bc
    echo -e  "Solr Version:\t"
    echo "$solrStatusOut"  | python -m json.tool | grep solr-spec-version | awk -F"[,|:]" '{print $2}'
  else
    echo -e "\033[38;5;196m"
    echo "Solr is not running or is unreachable on port $SOLR_PORT"
    echo -e "\033[0m"
  fi
}

function deployerStatus(){
  echo "------------------------------------------------------------"
  echo "Crafter Deployer status                                     "
  echo "------------------------------------------------------------"
  deployerStatusOut=$(curl --silent  -f  "http://localhost:$DEPLOYER_PORT/api/1/monitor/status")
  if [ $? -eq 0 ]; then
    echo -e "PID\t"
    echo `cat "$DEPLOYER_PID"`
    echo -e  "uptime:\t"
    echo "$deployerStatusOut"  | python -m json.tool | grep uptime | awk -F"[,|:|]" '{print $2}'
    echo -e  "Status:\t"
    echo "$deployerStatusOut"  | python -m json.tool | grep status | awk -F"[,|:]" '{print $2}'
    deployerVersion=$(curl --silent  -f  "http://localhost:$DEPLOYER_PORT/api/1/monitor/version")
    if [ $? -eq 0 ]; then
        echo -e  "Version:\t"
        printf $(echo "$deployerVersion"  | python -m json.tool | grep packageVersion | awk -F"[,|:]" '{print $2}')
        echo "$deployerVersion"| python -m json.tool | grep -w build | awk -F"[,|:]" '{print $2}'
    fi
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
  studioStatusOut=$(curl --silent  -f \
  "http://localhost:$TOMCAT_HTTP_PORT/studio/api/1/services/api/1/monitor/status.json")
  if [ $? -eq 0 ]; then
    echo -e "PID\t"
    echo `cat "$CATALINA_PID"`
    echo -e  "uptime:\t"
    echo "$studioStatusOut" | python -m json.tool | grep uptime | awk -F"[,|:]" '{print $2}'
    echo -e  "Status:\t"
    echo "$studioStatusOut" | python -m json.tool | grep status | awk -F"[,|:]" '{print $2}'
    deployerVersion=$(curl --silent  -f  "http://localhost:$TOMCAT_HTTP_PORT/studio/api/1/services/api/1/monitor/version.json")
    if [ $? -eq 0 ]; then
        echo -e  "Version:\t"
        printf "$(echo "$deployerVersion"  | python -m json.tool | grep packageVersion | awk -F"[,|:]" '{print $2}')"
        echo  "$deployerVersion"| python -m json.tool | grep -w build | awk -F"[,|:]" '{print $2}'
    fi
  else
    echo -e "\033[38;5;196m"
    echo "Crafter Studio is not running or is unreachable on port $TOMCAT_HTTP_PORT"
    echo -e "\033[0m"
  fi
}

function mariadbStatus(){
  echo "------------------------------------------------------------"
  echo "MariaDB status                                              "
  echo "------------------------------------------------------------"
  if [ -s "$MYSQL_DATA/$MYSQL_PID_FILE_NAME" ]; then
    echo -e "PID \t"
    echo `cat "$MYSQL_DATA/$MYSQL_PID_FILE_NAME"`
  else
    echo "MariaDB is not running."
  fi
}

function mongoDbStatus(){
  echo "------------------------------------------------------------"
  echo "MongoDB status                                              "
  echo "------------------------------------------------------------"
 if $(isMongoNeeded $1) || [ ! -z $(pidOf $MONGODB_PORT) ]; then
      if [ -e "$MONGODB_PID" ]; then
        echo -e "MongoDB PID"
        echo $(cat $MONGODB_PID)
      else
        echo -e "\033[38;5;196m"
        echo " MongoDB is not running"
        echo -e "\033[0m"
      fi
 elif [ ! -d "$MONGODB_HOME" ]; then
    echo "MongoDB is not installed."
 else
    echo "MongoDB is not running"
  fi
}

function start() {
  startDeployer
  startSolr
 if isMongoNeeded $1; then
    startMongoDB
 fi
  startTomcat
  printTailInfo
}

function debug() {
  debugDeployer
  debugSolr
  if isMongoNeeded $1; then
    startMongoDB
  fi
  debugTomcat
  printTailInfo
}

function stop() {
  stopTomcat
  if $(isMongoNeeded $1) || [ ! -z $(pidOf $MONGODB_PORT) ]; then
     stopMongoDB
  fi
  stopSolr
  stopDeployer
}

function status(){
  solrStatus
  deployerStatus
  studioStatus
  mariadbStatus
  mongoDbStatus
}

function doBackup() {
  export TARGET_NAME=$1
  if [ -z "$TARGET_NAME" ]; then
    if [ -x "$CRAFTER_HOME/dbms/bin/mysqldump" ]; then
      export TARGET_NAME="crafter-authoring-backup"
    else
      export TARGET_NAME="crafter-delivery-backup"
    fi
  fi
  export CURRENT_DATE=$(date +'%Y-%m-%d-%H-%M-%S')
  export TARGET_FOLDER="$CRAFTER_ROOT/backups"
  export TARGET_FILE="$TARGET_FOLDER/$TARGET_NAME.$CURRENT_DATE.zip"
  export TEMP_FOLDER="$CRAFTER_HOME/temp"

  echo "Starting backup into $TARGET_FILE"
  mkdir -p "$TEMP_FOLDER"
  mkdir -p "$TARGET_FOLDER"
  if [ -f "$TARGET_FILE" ]; then
    rm "$TARGET_FILE"
  fi

  # MySQL Dump
  if [ -d "$MYSQL_DATA" ]; then
    if [ -x "$CRAFTER_HOME/dbms/bin/mysqldump" ]; then
      #Do dump
      echo "Adding mysql dump"
      $CRAFTER_HOME/dbms/bin/mysqldump --databases crafter --port=$MARIADB_PORT --protocol=tcp --user=root > "$TEMP_FOLDER/crafter.sql"
      echo -e "SET GLOBAL innodb_large_prefix = TRUE ;\nSET GLOBAL innodb_file_format = 'BARRACUDA' ;\nSET GLOBAL innodb_file_format_max = 'BARRACUDA' ;\nSET GLOBAL innodb_file_per_table = TRUE ;\n$(cat $TEMP_FOLDER/crafter.sql)" > $TEMP_FOLDER/crafter.sql
    fi
  fi

  # MongoDB Dump
  if [ -d "$MONGODB_DATA_DIR" ]; then
    if [ -x "$CRAFTER_HOME/mongodb/bin/mongodump" ]; then
      echo "Adding mongodb dump"
      $CRAFTER_HOME/mongodb/bin/mongodump --port $MONGODB_PORT --out "$TEMP_FOLDER/mongodb" --quiet
      cd "$TEMP_FOLDER/mongodb"
      java -jar $CRAFTER_HOME/craftercms-utils.jar zip . "$TEMP_FOLDER/mongodb.zip"
      cd ..
      rm -r mongodb
      cd ..
    fi
  fi

  # ZIP git repos
  echo "Adding git repos"
  cd "$CRAFTER_ROOT/data/repos"
  java -jar $CRAFTER_HOME/craftercms-utils.jar zip . "$TEMP_FOLDER/repos.zip"
  # ZIP solr indexes
  echo "Adding solr indexes"
  cd "$SOLR_INDEXES_DIR"
  java -jar $CRAFTER_HOME/craftercms-utils.jar zip . "$TEMP_FOLDER/indexes.zip"
  # ZIP deployer data
  echo "Adding deployer data"
  cd "$DEPLOYER_DATA_DIR"
  java -jar $CRAFTER_HOME/craftercms-utils.jar zip . "$TEMP_FOLDER/deployer.zip"
  # ZIP everything (without compression)
  cd "$TEMP_FOLDER"
  java -jar $CRAFTER_HOME/craftercms-utils.jar zip . "$TARGET_FILE" true

  rm -rf "$TEMP_FOLDER"
  echo "Backup completed"
}

function doRestore() {
  pid=$(pidOf $TOMCAT_HTTP_PORT)
  if ! [ -z $pid ]; then
    echo "Please stop the system before starting the restore process."
    exit 1
  fi
  export SOURCE_FILE=$1
  if [ ! -f "$SOURCE_FILE" ]; then
    echo "The file does not exist"
    help
    exit 1
  fi
  export TEMP_FOLDER="$CRAFTER_HOME/temp"

  read -p "Warning, you're about to restore CrafterCMS from a backup, which will wipe the \
existing sites and associated database and replace everything with the restored data. If you \
care about the existing state of the system then stop this process, backup the system, and then \
attempt the restore. Are you sure you want to proceed? (yes/no) "
  if [ "$REPLY" != "yes" ]; then
    echo "Canceling restore"
    exit 0
  fi

  echo "Clearing all existing data"
  rm -rf $CRAFTER_ROOT/data/*

  echo "Starting restore from $SOURCE_FILE"
  mkdir -p "$TEMP_FOLDER"

  # UNZIP everything
  java -jar $CRAFTER_HOME/craftercms-utils.jar unzip "$SOURCE_FILE" "$TEMP_FOLDER"

  # MongoDB Dump
  if [ -f "$TEMP_FOLDER/mongodb.zip" ]; then
    echo "Restoring MongoDB"
    startMongoDB
    java -jar $CRAFTER_HOME/craftercms-utils.jar unzip "$TEMP_FOLDER/mongodb.zip" "$TEMP_FOLDER/mongodb"
    $CRAFTER_HOME/mongodb/bin/mongorestore --port $MONGODB_PORT "$TEMP_FOLDER/mongodb" --quiet
  fi

  # UNZIP git repos
  echo "Restoring git repos"
  rm -rf "$CRAFTER_ROOT/data/repos/*"
  java -jar $CRAFTER_HOME/craftercms-utils.jar unzip "$TEMP_FOLDER/repos.zip" "$CRAFTER_ROOT/data/repos"

  # UNZIP solr indexes
  echo "Restoring solr indexes"
  rm -rf "$SOLR_INDEXES_DIR/*"
  java -jar $CRAFTER_HOME/craftercms-utils.jar unzip "$TEMP_FOLDER/indexes.zip" "$SOLR_INDEXES_DIR"

  # UNZIP deployer data
  echo "Restoring deployer data"
  rm -rf "$DEPLOYER_DATA_DIR/*"
  java -jar $CRAFTER_HOME/craftercms-utils.jar unzip "$TEMP_FOLDER/deployer.zip" "$DEPLOYER_DATA_DIR"

  # If it is an authoring env then sync the repos
  if [ -f "$TEMP_FOLDER/crafter.sql" ]; then
    mkdir "$MYSQL_DATA"
    #Start DB
    echo "Starting DB"
    java -jar -DmariaDB4j.port=$MARIADB_PORT -DmariaDB4j.baseDir="$CRAFTER_HOME/dbms" -DmariaDB4j.dataDir="$MYSQL_DATA" $CRAFTER_HOME/mariaDB4j-app.jar &
    sleep 30
    # Import
    echo "Restoring DB"
    $CRAFTER_HOME/dbms/bin/mysql --user=root --port=$MARIADB_PORT --protocol=TCP --binary-mode < "$TEMP_FOLDER/crafter.sql"
    # Stop DB
    echo "Stopping DB"
    kill $(cat mariadb4j.pid)
    sleep 10
  fi

  rm -r "$TEMP_FOLDER"
  echo "Restore complete, you may now start the system"
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
  debug $2
  ;;
  start)
  logo
  start $2
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
  status)
  status
  ;;
  backup)
    doBackup $2
  ;;
  restore)
    doRestore $2
  ;;
  status_tomcat)
    studioStatus
  ;;
  status_deployer)
    deployerStatus
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
  man)
    manPages
  ;;
  *)
  help
  ;;
esac
