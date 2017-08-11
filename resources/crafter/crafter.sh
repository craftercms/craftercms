#!/usr/bin/env bash
export CRAFTER_HOME=${CRAFTER_HOME:=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )}
export CRAFTER_ROOT=${CRAFTER_ROOT:=$( cd "$CRAFTER_HOME/.." && pwd )}
export DEPLOYER_HOME=${DEPLOYER_HOME:=$CRAFTER_HOME/crafter-deployer}

. "$CRAFTER_HOME/crafter-setenv.sh"

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
  echo "    backup <name>, Perform a backup of all data"
  echo "    restore <file>, Perform a restore of all data"
  echo "    tail,  Tails all Crafter CMS logs"
  exit 0;
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
  if [ ! -d $SOLR_LOGS_DIR ]; then
    mkdir -p $SOLR_LOGS_DIR;
  fi

  if [ ! -s "$SOLR_PID" ]; then
    ## Before run check if the port is available.
    possiblePID=$(pidOf $SOLR_PORT)
    if  [ -z "$possiblePID" ];  then
      $CRAFTER_HOME/solr/bin/solr start -p $SOLR_PORT -Dcrafter.solr.index=$SOLR_INDEXES_DIR -a "$SOLR_JAVA_OPTS"
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
      exit 5
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
  if [ ! -d $SOLR_LOGS_DIR ]; then
    mkdir -p $SOLR_LOGS_DIR;
  fi
  if [ ! -s "$SOLR_PID" ]; then
    ## Before run check if the port is available.
    possiblePID=$(pidOf $SOLR_PORT)
    if  [ -z "$possiblePID" ];  then
      $CRAFTER_HOME/solr/bin/solr start -p $SOLR_PORT -Dcrafter.solr.index=$SOLR_INDEXES_DIR \
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
      exit 5
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
      $CRAFTER_HOME/apache-tomcat/bin/startup.sh
    else
      echo $possiblePID > $CATALINA_PID
      echo "Process PID $possiblePID is listening port $TOMCAT_HTTP_PORT"
      echo "Hijacking PID and saving into $CATALINA_PID"
      exit
    fi
  else
    # Is it really up?
    if ! checkPortForRunning $TOMCAT_HTTP_PORT $(cat "$CATALINA_PID");then
      exit 5
    fi
    if ! pgrep -u `whoami` -F "$CATALINA_PID" >/dev/null
    then
      echo "Tomcat Pid file is not ok, forcing startup"
      rm "$CATALINA_PID"
      startTomcat
    fi
    echo "Tomcat already started"
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
      exit 5
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
      exit 5
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
    echo -e "MySQL sub-process:\t"
    echo -e "PID \t"
    echo ` cat "$MYSQL_DATA/$MYSQL_PID_FILE_NAME"`
  else
    echo -e "\033[38;5;196m"
    echo "Crafter Studio is not running or is unreachable on port $TOMCAT_HTTP_PORT"
    echo -e "\033[0m"
  fi
}

function mongoDbStatus(){
  echo "------------------------------------------------------------"
  echo "MongoDB status                                              "
  echo "------------------------------------------------------------"
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

function doBackup() {
  export TARGET_NAME=$1
  if [ -z "$TARGET_NAME" ]; then
    if [ -d "$MYSQL_DATA" ]; then
      export TARGET_NAME="crafter-authoring-backup"
    else
      export TARGET_NAME="crafter-delivery-backup"
    fi
  fi
  export CURRENT_DATE=$(date +'%Y-%m-%d-%H-%M-%S')
  export TARGET_FILE="$CRAFTER_ROOT/$TARGET_NAME.$CURRENT_DATE.zip"
  export TEMP_FOLDER="$CRAFTER_HOME/backup"
  
  echo "Starting backup into $TARGET_FILE"
  mkdir -p "$TEMP_FOLDER"
  rm "$TARGET_FILE"

  # MySQL Dump
  if [ -d "$MYSQL_DATA" ]; then
    #Do dump
    $CRAFTER_HOME/dbms/bin/mysqldump --databases crafter --port=@MARIADB_PORT@ --protocol=tcp --user=root > "$TEMP_FOLDER/crafter.sql"
  fi
  
  # MongoDB Dump
  if [ -d "$MONGODB_DATA_DIR" ]; then
    echo "Adding mongodb dump"
    $CRAFTER_HOME/mongodb/bin/mongodump --port $MONGODB_PORT --out "$TEMP_FOLDER/mongodb" --quiet
    cd "$TEMP_FOLDER/mongodb"
    java -jar $CRAFTER_HOME/craftercms-utils.jar zip . "$TEMP_FOLDER/mongodb.zip"
    cd ..
    rm -r mongodb
    cd ..
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

function checkFolder() {
  echo "Checking folder for $1"
  local result=0
  if [ -d "$CRAFTER_HOME/data/$1" ]; then
    read -p "Folder already exist, do you want to overwrite it? (yes/no) "
    if [ "$REPLY" != "yes" ]; then
      result=1
    fi
  fi
  return $result
}

function doRestore() {
  export SOURCE_FILE=$1
  if [ ! -f "$SOURCE_FILE" ]; then
    echo "The file does not exist"
    help
    exit 1
  fi
  export TEMP_FOLDER="$CRAFTER_HOME/backup"
  
  echo "Starting restore from $SOURCE_FILE"
  mkdir -p "$TEMP_FOLDER"

  # UNZIP everything
  java -jar $CRAFTER_HOME/craftercms-utils.jar unzip "$SOURCE_FILE" "$TEMP_FOLDER"
  
  # MongoDB Dump
  if [ -f "$TEMP_FOLDER/mongodb.zip" ]; then
    if checkFolder "mongodb"; then
      echo "Restoring MongoDB"
      startMongoDB
      java -jar $CRAFTER_HOME/craftercms-utils.jar unzip "$TEMP_FOLDER/mongodb.zip" "$TEMP_FOLDER/mongodb"
      $CRAFTER_HOME/mongodb/bin/mongorestore --port $MONGODB_PORT "$TEMP_FOLDER/mongodb" --quiet
    fi
  fi
  
  # UNZIP git repos
  if checkFolder "repos"; then
    echo "Restoring git repos"
    rm -rf "$CRAFTER_ROOT/data/repos/*"
    java -jar $CRAFTER_HOME/craftercms-utils.jar unzip "$TEMP_FOLDER/repos.zip" "$CRAFTER_ROOT/data/repos"
  fi
  # UNZIP solr indexes
  if checkFolder "indexes"; then
    echo "Restoring solr indexes"
    rm -rf "$SOLR_INDEXES_DIR/*"
    java -jar $CRAFTER_HOME/craftercms-utils.jar unzip "$TEMP_FOLDER/indexes.zip" "$SOLR_INDEXES_DIR"
  fi
  # UNZIP deployer data
  if checkFolder "deployer"; then
    echo "Restoring deployer data"
    rm -rf "$DEPLOYER_DATA_DIR/*"
    java -jar craftercms-utils.jar unzip "$TEMP_FOLDER/deployer.zip" "$DEPLOYER_DATA_DIR"
  fi
  
  # If it is an authoring env then sync the repos
  if [ -f "$TEMP_FOLDER/crafter.sql" ]; then
    mkdir "$MYSQL_DATA"
    #Start DB
    $CRAFTER_HOME/dbms/bin/mysqld --no-defaults --console --skip-grant-tables --max_allowed_packet=64M --basedir=dbms --datadir="$MYSQL_DATA" --port=@MARIADB_PORT@ --pid="$CRAFTER_HOME/MariaDB4j.pid" --innodb_large_prefix=TRUE --innodb_file_format=BARRACUDA --innodb_file_format_max=BARRACUDA --innodb_file_per_table=TRUE &
    sleep 5
    # Import
    $CRAFTER_HOME/dbms/bin/mysql --user=root --port=@MARIADB_PORT@ < "$TEMP_FOLDER/crafter.sql"
    # Stop DB
    kill $(cat $CRAFTER_HOME/MariaDB4j.pid)
    start
    echo "Waiting for studio to start"
    sleep 60
    for SITE in $(ls $DEPLOYER_DEPLOYMENTS_DIR)
    do
      echo "Running sync for site $SITE"
      java -jar $CRAFTER_HOME/craftercms-utils.jar post "http://localhost:8080/studio/api/1/services/api/1/repo/sync-from-repo.json" "{ \"site_id\":\"$SITE\" }"
    done
  fi
  
  rm -r "$TEMP_FOLDER"
  echo "Restore completed"
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
  backup)
    doBackup $2
  ;;
  restore)
    doRestore $2
  ;;
  *)
  help
  ;;
esac
