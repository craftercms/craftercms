#!/bin/bash

# Copyright (C) 2007-2021 Crafter Software Corporation. All Rights Reserved.
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

########################################################################################################################
################################################ COMMONS ###############################################################
cecho () {

    if [ "$2" == "info" ] ; then
        COLOR="96m";
    elif [ "$2" == "strong" ] ; then
        COLOR="94m";
    elif [ "$2" == "success" ] ; then
        COLOR="92m";
    elif [ "$2" == "warning" ] ; then
        COLOR="93m";
    elif [ "$2" == "error" ] ; then
        COLOR="91m";
    else #default color
        COLOR="0m";
    fi

    STARTCOLOR="\e[$COLOR";
    ENDCOLOR="\e[0m";

    printf "$STARTCOLOR%b$ENDCOLOR" "$1";
}

# Kill a process given a PID
function killProcess() {
  pid=$1

  pkill -15 -F "$pid"
  sleep 5 # wait for 5 seconds, then kill -9
  if [ -s "$pid" ] && pgrep -F "$pid" > /dev/null; then
    pkill -9 -F "$pid" # force kill
  fi
}

# Get the process ID given a port number
function getPidByPort() {
  port=$1

  echo $(lsof -i :$port | grep LISTEN | awk '{print $2}' | grep -v PID | uniq)
}

# Check if the process holding the port is ours
function isCorrectProcessHoldingPort() {
  process=$1
  port=$2
  result=1

  pidOfPort=$(getPidByPort $port)
  if [ "$pidOfPort"=="$process" ]; then
    # The process holding the port is ours, this is fine
    result=$pidOfPort
  else
    # Some other process is holding the port, this is not good
    result=0
  fi

  echo $result
}

# Run a module (example Apache Tomcat, Elasticsearch, etc.)
function runModule() {
	module=$1
	executable=$2
	port=$3
	foldersToCreate=$4
	pidFile=$5
	operation=$6

	cd $CRAFTER_BIN_DIR

	banner "$operation $module"

  createFolders $foldersToCreate

	# Check if PID exits already
	if [ ! -s "$pidFile" ]; then
    runProcessOrHijackExisting $pidFile $port "$executable"
	else
    exitIfPortInUse $port $pidFile
		if ( isPidFileCorrect "$pidFile" ); then
			cecho "$module PID file is not correct, forcing startup\n" "warning"
			rm "$pidFile"
			runModule "$module" "$executable" "$port" "$foldersToCreate" "$pidFile"
		fi
		cecho "$operation: Operation already executed for module: $module\n" "warning"
	fi
}

# Stop a module
function stopModule() {
	module=$1
	executable=$2
	port=$3
	pidFile=$4

	cd $CRAFTER_BIN_DIR

	banner "Stop $module"

	# If PID file has a value
	if [ -s "$pidFile" ]; then
		# Try to stop
		runTask $executable
		# If PID file still exists
		if [ -e "$pidFile" ]; then
			# Check if the process is still up
			if pgrep -F "$pidFile" > /dev/null; then
				# Kill it
				KillProcess $pidFile
			fi
			# If the process died, then delete the PID file
			if [ $? -eq 0 ]; then
				rm $pidFile
			fi
		fi
	else
		# We don't have a PID file, let's try to identify the process
		pid=$( getPidByPort $port )
		if ! [ -z $pid ]; then
			# Found the process, let's kill it
			KillProcess $pid
		else
			# The process is not running, let the user know
			cecho "$module already shutdown\n" "warn"
		fi
	fi
}

# Run an external program
function runTask() {
  #cecho "Running: $@\n" "error"
  TASK_PID=bash "$@"
  #TASK_PID=$!
  disown -h $TASK_PID 2> /dev/null
}

function createFolders() {
	foldersToCreate=$1

	for i in "${foldersToCreate[@]}"; do
		if [ ! -d $i ]; then
			mkdir -p $i;
		fi
	done
}

function banner() {
	message=$1

	cecho "------------------------------------------------------------------------\n" "info"
	cecho "$message\n" "info"
	cecho "------------------------------------------------------------------------\n" "info"
}

function runProcessOrHijackExisting() {
  pidFile=$1
  port=$2
  executable=$3

  # Check if the port is available
  existingPid=$( getPidByPort "$port" )
  if  [ -z "$existingPid" ];  then
    # All clear to start
    runTask $executable
  else
    # A process has the file, assume it to be our daemon and grab the PID
    echo $existingPid > $pidFile
    cecho "Found a process with PID $existingPid listening port $port\n" "warning"
    cecho "Hijacking this PID and saving it into $pidFile\n" "warning"
    exit 0
  fi
}

function exitIfPortInUse() {
	port=$1
	pidFile=$2

	# get PID of process holding the port
	pid=$( getPidByPort "$port" )
	# if the process holding the port is not the one in PID file, fail
	if ! [ "$pid"==$( cat "$pidFile" ) ]; then
		# A process holding the port we need, inform the user and exit
		cecho " Port $port is in use by another process with PID $pid\n
			Please shutdown process with PID $pid and try again\n" "error"
		exit 6
	fi
}

function isPidFileCorrect() {
  pidFile=$1
  result=0

  if ! pgrep -u $(whoami) -F "$pidFile" > /dev/null; then
    result=1
  fi

  return $result
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
    cecho "Unable to continue, an error occurred or the script was forcefully stopped\n" "error"
    exit 1
  fi
}

function splash() {
  # TODO: Switch this to the new output system
  echo -e "\033[38;5;196m"
  echo " ██████╗ ██████╗   █████╗  ███████╗ ████████╗ ███████╗ ██████╗      ██████╗ ███╗   ███╗ ███████╗"
  echo "██╔════╝ ██╔══██╗ ██╔══██╗ ██╔════╝ ╚══██╔══╝ ██╔════╝ ██╔══██╗    ██╔════╝ ████╗ ████║ ██╔════╝"
  echo "██║      ██████╔╝ ███████║ █████╗      ██║    █████╗   ██████╔╝    ██║      ██╔████╔██║ ███████╗"
  echo "██║      ██╔══██╗ ██╔══██║ ██╔══╝      ██║    ██╔══╝   ██╔══██╗    ██║      ██║╚██╔╝██║ ╚════██║"
  echo "╚██████╗ ██║  ██║ ██║  ██║ ██║         ██║    ███████╗ ██║  ██║    ╚██████╗ ██║ ╚═╝ ██║ ███████║"
  echo " ╚═════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚═╝         ╚═╝    ╚══════╝ ╚═╝  ╚═╝     ╚═════╝ ╚═╝     ╚═╝ ╚══════╝"
  echo -e "\033[0m"
}

########################################################################################################################
################################################ BACKUP ###############################################################
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

  banner "Starting backup"

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
    banner "Backing up external DB"

    # Check that the mysqldump is in the path
    if type "mysqldump" >/dev/null 2>&1; then
      export MYSQL_PWD=$MARIADB_PASSWD
      mysqldump --databases crafter --user=$MARIADB_USER --host=$MARIADB_HOST --port=$MARIADB_PORT --protocol=tcp --routines > "$tempFolder/crafter.sql"
      mysqldump --user=$MARIADB_ROOT_USER --password=$MARIADB_ROOT_PASSWD --host=$MARIADB_HOST --port=$MARIADB_PORT --protocol=tcp --skip-add-drop-table --no-create-info --insert-ignore --complete-insert mysql user db global_priv -r $tempFolder/users.sql
      abortOnError
    else
      cecho "External DB backup failed, unable to find mysqldump in the PATH. Please make sure you have a proper MariaDB/MySQL client installed\n" "error"
      exit 1
    fi
  elif [ -d "$MARIADB_DATA_DIR" ]; then
    # Start DB if necessary
    DB_STARTED=false
    if [ -z $(getPidByPort "$MARIADB_PORT") ]; then
      mkdir -p "$CRAFTER_BIN_DIR/dbms"
      banner "Starting DB"
      java -jar -DmariaDB4j.port=$MARIADB_PORT -DmariaDB4j.baseDir="$CRAFTER_BIN_DIR/dbms" -DmariaDB4j.dataDir="$MARIADB_DATA_DIR" $CRAFTER_BIN_DIR/mariaDB4j-app.jar &
      $CRAFTER_BIN_DIR/wait-for-it.sh -h "$MARIADB_HOST" -p "$MARIADB_PORT" -t $MARIADB_TCP_TIMEOUT
      DB_STARTED=true
    fi

    #Do dump
    banner "Backing up embedded DB"
    export MYSQL_PWD=$MARIADB_ROOT_PASSWD
    $CRAFTER_BIN_DIR/dbms/bin/mysqldump --databases crafter --user=$MARIADB_ROOT_USER --host=$MARIADB_HOST --port=$MARIADB_PORT --protocol=tcp --routines > "$tempFolder/crafter.sql"
    $CRAFTER_BIN_DIR/dbms/bin/mysqldump --user=$MARIADB_ROOT_USER --password=$MARIADB_ROOT_PASSWD --host=$MARIADB_HOST --port=$MARIADB_PORT --protocol=tcp --skip-add-drop-table --no-create-info --insert-ignore --complete-insert mysql user db global_priv -r $tempFolder/users.sql
    abortOnError

    if [ "$DB_STARTED" = true ]; then
      # Stop DB
      banner "Stopping DB"
      kill $(cat mariadb4j.pid)
      sleep 10
    fi
  fi

  # MongoDB Dump
  if [ -d "$MONGODB_DATA_DIR" ]; then
    # Start MongoDB if necessary
    MONGODB_STARTED=false
    if [ -z $(getPidByPort "$MONGODB_PORT") ]; then
      startMongoDB
      sleep 15
      MONGODB_STARTED=true
    fi

    banner "Backing up MongoDB"

    $MONGODB_HOME/bin/mongodump --port $MONGODB_PORT --out "$tempFolder/mongodb"
    abortOnError

    CURRENT_DIR=$(pwd)

    cd "$tempFolder/mongodb"
    tar cvf "$tempFolder/mongodb.tar" .
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
    banner "Backing up git repos"
    cd "$CRAFTER_DATA_DIR/repos"
    tar cvf "$tempFolder/repos.tar" .
    abortOnError
  fi

  # ZIP elasticsearch indexes
  banner "Backing up elasticsearch indexes"
  if [ -d "$ES_INDEXES_DIR" ]; then
    cecho "Adding elasticsearch indexes\n" "info"
    cd "$ES_INDEXES_DIR"
    tar cvf "$tempFolder/indexes-es.tar" .
    abortOnError
  fi

  # ZIP deployer data
  if [ -d "$DEPLOYER_DATA_DIR" ]; then
   banner "Backing up Deployer data"
   cd "$DEPLOYER_DATA_DIR"
   tar cvf "$tempFolder/deployer.tar" .
   abortOnError
  fi

  # ZIP everything (without compression)
  banner "Packaging everything"
  cd "$tempFolder"
  tar czvf "$targetFile" .
  abortOnError

  rmDirContents "$tempFolder"
  rmdir "$tempFolder"

  cecho "> Backup completed and saved to $targetFile\n" "strong"
}

function doRestore() {
  local pid=$(getPidByPort $TOMCAT_HTTP_PORT)
  if ! [ -z $pid ]; then
    cecho "Please stop the system before starting the restore process.\n" "warning"
    exit 1
  fi

  local sourceFile=$1
  if [ ! -f "$sourceFile" ]; then
    cecho "The source file $sourceFile does not exist\n" "error"
    help
    exit 1
  fi

  local tempFolder="$CRAFTER_BACKUPS_DIR/temp"
  local packageExt=""

  read -p "Warning, you're about to restore CrafterCMS from a backup, which will wipe the\
  existing sites and associated database and replace everything with the restored data. If you\
  care about the existing state of the system then stop this process, backup the system, and then\
  attempt the restore. Are you sure you want to proceed? (yes/no)\n" "warning"
  if [ "$REPLY" != "yes" ] && [ "$REPLY" != "y" ]; then
    cecho "Canceling restore\n" "strong"
    exit 0
  fi

  banner "Clearing all existing data"
  rmDirContents "$MONGODB_DATA_DIR"
  rmDirContents "$CRAFTER_DATA_DIR/repos"
  rmDirContents "$ES_INDEXES_DIR"
  rmDirContents "$DEPLOYER_DATA_DIR"
  rmDirContents "$MARIADB_DATA_DIR"

  banner "Starting restore from $sourceFile"
  mkdir -p "$tempFolder"

  # UNZIP everything
  if [[ "$sourceFile" == *.tar.gz ]]; then
    tar xzvf "$sourceFile" -C "$tempFolder"
    abortOnError

    packageExt="tar"
  else
    unzip "$sourceFile" "$tempFolder"
    abortOnError

    packageExt="zip"
  fi

  # MongoDB Dump
  if [ -f "$tempFolder/mongodb.$packageExt" ]; then
    mkdir -p "$tempFolder/mongodb"

    startMongoDB
    sleep 15

    banner "Restoring MongoDB"

    if [ "$packageExt" == "tar" ]; then
      tar xvf "$tempFolder/mongodb.tar" -C "$tempFolder/mongodb"
      abortOnError
    else
      unzip "$tempFolder/mongodb.zip" "$tempFolder/mongodb"
      abortOnError
    fi

    $CRAFTER_BIN_DIR/mongodb/bin/mongorestore --port $MONGODB_PORT "$tempFolder/mongodb"
    abortOnError

    stopMongoDB
  fi

  # UNZIP git repos
  if [ -f "$tempFolder/repos.$packageExt" ]; then
    mkdir -p "$CRAFTER_DATA_DIR/repos"

    banner "Restoring git repos"

    if [ "$packageExt" == "tar" ]; then
      tar xvf "$tempFolder/repos.tar" -C "$CRAFTER_DATA_DIR/repos"
      abortOnError
    else
      unzip "$tempFolder/repos.zip" "$CRAFTER_DATA_DIR/repos"
      abortOnError
    fi
  fi

  # UNZIP elasticsearch indexes
  if [ -f "$tempFolder/indexes-es.$packageExt" ]; then
    mkdir -p "$ES_INDEXES_DIR"

    banner "Restoring Elasticsearch indexes"

    if [ "$packageExt" == "tar" ]; then
      tar xvf "$tempFolder/indexes-es.tar" -C "$ES_INDEXES_DIR"
      abortOnError
    else
      unzip "$tempFolder/indexes-es.zip" "$ES_INDEXES_DIR"
      abortOnError
    fi
  fi

  # UNZIP deployer data
  if [ -f "$tempFolder/deployer.$packageExt" ]; then
    mkdir -p "$DEPLOYER_DATA_DIR"

    banner "Restoring Deployer data"

    if [ "$packageExt" == "tar" ]; then
      tar xvf "$tempFolder/deployer.tar" -C "$DEPLOYER_DATA_DIR"
      abortOnError
    else
      unzip "$tempFolder/deployer.zip" "$DEPLOYER_DATA_DIR"
      abortOnError
    fi
  fi

  # Restore DB
  if [ -f "$tempFolder/crafter.sql" ]; then
    if [[ $SPRING_PROFILES_ACTIVE = *crafter.studio.externalDb* ]]; then
      banner "Restoring external DB"

      # Check that the mysql is in the path
      if type "mysql" >/dev/null 2>&1; then
        export MYSQL_PWD=$MARIADB_PASSWD
        mysql --user=$MARIADB_USER --host=$MARIADB_HOST --port=$MARIADB_PORT --protocol=tcp --binary-mode < "$tempFolder/crafter.sql"
        if [ -f "$tempFolder/users.sql" ]; then
          mysql --user=$MARIADB_USER --host=$MARIADB_HOST --port=$MARIADB_PORT --protocol=tcp --binary-mode mysql < "$tempFolder/users.sql"
        else
          cecho "Users backup does not exists. Skipping restore users\n" "warning"
        fi
        abortOnError
      else
        cecho "External DB restore failed, unable to find mysql in the PATH. Please make sure you have a proper MariaDB/MySQL client installed\n" "error"
        exit 1
      fi
    else
      mkdir -p "$MARIADB_DATA_DIR"
      #Start DB
      banner "Starting DB"
      java -jar -DmariaDB4j.port=$MARIADB_PORT -DmariaDB4j.baseDir="$CRAFTER_BIN_DIR/dbms" -DmariaDB4j.dataDir="$MARIADB_DATA_DIR" $CRAFTER_BIN_DIR/mariaDB4j-app.jar &
      $CRAFTER_BIN_DIR/wait-for-it.sh -h "$MARIADB_HOST" -p "$MARIADB_PORT" -t $MARIADB_TCP_TIMEOUT

      # Import
      banner "Restoring embedded DB"
      export MYSQL_PWD=$MARIADB_ROOT_PASSWD
      $CRAFTER_BIN_DIR/dbms/bin/mysql --user=$MARIADB_ROOT_USER --host=$MARIADB_HOST --port=$MARIADB_PORT --protocol=tcp --binary-mode < "$tempFolder/crafter.sql"
      if [ -f "$tempFolder/users.sql" ]; then
        $CRAFTER_BIN_DIR/dbms/bin/mysql --user=$MARIADB_ROOT_USER --host=$MARIADB_HOST --port=$MARIADB_PORT --protocol=tcp --binary-mode mysql < "$tempFolder/users.sql"
      else
        cecho "Users backup does not exists. Skipping restore users\n" "warning"
      fi
      abortOnError

      # Stop DB
      banner "Stopping DB"
      kill $(cat mariadb4j.pid)
      sleep 10
    fi
  fi

  rm -r "$tempFolder"
  cecho "> Restore complete, you may now start the system\n" "strong"
}

########################################################################################################################
################################################### DB #################################################################
function doUpgradeDB() {
  banner "Starting upgrade of embedded database $MARIADB_DATA_DIR"

  # Upgrade database
  if [ -d "$MARIADB_DATA_DIR" ]; then
    # Start DB if necessary
    DB_STARTED=false
    if [ -z $(getPidByPort "$MARIADB_PORT") ]; then
      mkdir -p "$CRAFTER_BIN_DIR/dbms"
      banner "Starting DB"
      java -jar -DmariaDB4j.port=$MARIADB_PORT -DmariaDB4j.baseDir="$CRAFTER_BIN_DIR/dbms" -DmariaDB4j.dataDir="$MARIADB_DATA_DIR" $CRAFTER_BIN_DIR/mariaDB4j-app.jar &
      sleep 30
      DB_STARTED=true
    fi

    # Do upgrade
    banner "Upgrading embedded DB"
    export MYSQL_PWD=$MARIADB_ROOT_PASSWD
    $CRAFTER_BIN_DIR/dbms/bin/mysql_upgrade --user=$MARIADB_ROOT_USER --host=$MARIADB_HOST --port=$MARIADB_PORT --protocol=tcp
    abortOnError

    if [ "$DB_STARTED" = true ]; then
      # Stop DB
      banner "Stopping DB"
      kill $(cat mariadb4j.pid)
      sleep 10
    fi

    cecho "> Upgrade database completed\n" "strong"
  else
    cecho "No embedded DB found, skipping upgrade" "warning"
  fi
}

########################################################################################################################
################################################## MAIN ################################################################

# Do not run as root
if [ "$(whoami)" == "root" ]; then
  cecho "Crafter CMS cowardly refuses to run as root.\n
  Running as root is dangerous and is not supported.\n" "error"

  exit 1
fi

# Do not run on 32-bit arch
OSARCH=$(getconf LONG_BIT)
if [[ $OSARCH -eq "32" ]]; then
  cecho "Crafter CMS is not supported on 32-bit architecture\n" "error"
  exit 5
fi

# Export our coordinates
export CRAFTER_BIN_DIR=${CRAFTER_BIN_DIR:=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )}
export CRAFTER_HOME=${CRAFTER_HOME:=$( cd "$CRAFTER_BIN_DIR/.." && pwd )}

# Check if OS is macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Remove com.apple.quarantine flag for elasticsearch files
  xattr -rd com.apple.quarantine $CRAFTER_BIN_DIR/elasticsearch
fi

# Set up the environment
source "$CRAFTER_BIN_DIR/crafter-setenv.sh"

# Help for those who need it
function help() {
  # TODO: Review and redo

  cecho "$(basename $BASH_SOURCE)\n\n" "strong"
  cecho "    start [withMongoDB] [skipElasticsearch] [skipMongoDB], Starts Tomcat, Deployer and Elasticsearch.
             If withMongoDB is specified MongoDB will be started,
             if skipElasticsearch is specified Elasticsearch will not be started,
             if skipMongoDB is specified MongoDB will not be started even if
             the Crafter Profile WAR file is present.\n" "info"
  cecho "    stop, Stops Tomcat, Deployer, Elasticsearch (if started), Mongo (if started)\n" "info"
  cecho "    debug [withMongoDB] [skipElasticsearch] [skipMongoDB], Starts Tomcat, Deployer and
             Elasticsearch in debug mode. If withMongoDB is specified MongoDB will be started,
             if skipElasticsearch is specified Elasticsearch will not be started, if skipMongoDB is specified MongoDB
             will not be started even if the Crafter Profile war is present\n" "info"
  cecho "    start_deployer, Starts Deployer\n" "info"
  cecho "    stop_deployer, Stops Deployer\n" "info"
  cecho "    debug_deployer, Starts Deployer in debug mode\n" "info"
  cecho "    start_elasticsearch, Starts Elasticsearch\n" "info"
  cecho "    stop_elasticsearch, Stops Elasticsearch\n" "info"
  cecho "    debug_elasticsearch, Starts Elasticsearch in debug mode\n" "info"
  cecho "    start_tomcat, Starts Tomcat\n" "info"
  cecho "    stop_tomcat, Stops Tomcat\n" "info"
  cecho "    debug_tomcat, Starts Tomcat in debug mode\n" "info"
  cecho "    start_mongodb, Starts Mongo DB\n" "info"
  cecho "    stop_mongodb, Stops Mongo DB\n" "info"
  cecho "    status, Status of all CrafterCms subsystems\n" "info"
  cecho "    status_engine, Status of Crafter Engine\n" "info"
  cecho "    status_studio, Status of Crafter Studio\n" "info"
  cecho "    status_profile, Status of Crafter Profile\n" "info"
  cecho "    status_social, Status of Crafter Social\n" "info"
  cecho "    status_search, Status of Crafter Search\n" "info"
  cecho "    status_deployer, Status of Deployer\n" "info"
  cecho "    status_elasticsearch, Status of Elasticsearch\n" "info"
  cecho "    status_mariadb, Status of MariaDB\n" "info"
  cecho "    status_mongodb, Status of MonoDb\n" "info"
  cecho "    backup <name>, Perform a backup of all data\n" "info"
  cecho "    restore <file>, Perform a restore of all data\n" "info"
  cecho "    upgradedb, Perform database upgrade (mysql_upgrade)\n" "info"
  exit 2;
}

# Version info
function version() {
  cecho "Copyright (C) 2007-2021 Crafter Software Corporation. All rights reserved.\n" "info"
  cecho "Version @VERSION@-@GIT_BUILD_ID@\n" "info"
}

# Display instructions for tailing logs
function printTailInfo(){
  cecho "Log files live here: \"$CRAFTER_LOGS_DIR\".\n" "strong"
  cecho "To follow the main tomcat log, you can run:\n" "strong"
  cecho "tail -F $CRAFTER_LOGS_DIR/tomcat/catalina.out\n" "info"
}

function startDeployer() {
  runModule "Deployer" "$DEPLOYER_HOME/deployer.sh start" $DEPLOYER_PORT "$DEPLOYER_LOGS_DIR" $DEPLOYER_PID "Start"
}

function debugDeployer() {
  runModule "Deployer" "$DEPLOYER_HOME/deployer.sh debug" $DEPLOYER_PORT "$DEPLOYER_LOGS_DIR" $DEPLOYER_PID "Debug"
}

function stopDeployer() {
	stopModule "Deployer" "$DEPLOYER_HOME/deployer.sh stop" "$DEPLOYER_PORT" "$DEPLOYER_PID"
}

function startElasticsearch() {
  runModule "Elasticsearch" "$ES_HOME/elasticsearch -d -p $ES_PID" $ES_PORT "$ES_INDEXES_DIR" $ES_PID "Start"
}

function debugElasticsearch() {
  runModule "Elasticsearch"\
   "ES_JAVA_OPTS=\"$ES_JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=1045\";$ES_HOME/elasticsearch -d -p $ES_PID"\
   $ES_PORT "$ES_INDEXES_DIR" $ES_PID "Debug"
}

function stopElasticsearch() {
	stopModule "Elasticsearch" "killProcess $ES_PID" "$ES_PORT" "$ES_PID"
}

function elasticsearchStatus() {
  getStatus "Elasticsearch" $ES_PORT "$ES_PID"
}

function startTomcat() {
  cd $CRAFTER_BIN_DIR
  if [[ ! -d "$CRAFTER_BIN_DIR/dbms" ]] || [[ -z $(getPidByPort "$MARIADB_PORT") ]] || [[ $SPRING_PROFILES_ACTIVE = *crafter.studio.externalDb* ]]; then
    runModule "Tomcat" "$CRAFTER_BIN_DIR/apache-tomcat/bin/catalina.sh start" $TOMCAT_HTTP_PORT "$CATALINA_LOGS_DIR $CATALINA_TMPDIR" $CATALINA_PID "Start"
  else
    cecho "Crafter CMS Database Port: $MARIADB_PORT is in use by process id $(getPidByPort "$MARIADB_PORT").\n
            This might be because of a prior unsuccessful or incomplete shut down.\n
            Please terminate that process before attempting to start Crafter CMS.\n" "error"
    read -t 10 # Timeout for the read, (if gradle start)
    exit -7
  fi
}

function debugTomcat() {
  cd $CRAFTER_BIN_DIR
  if [[ ! -d "$CRAFTER_BIN_DIR/dbms" ]] || [[ -z $(getPidByPort "$MARIADB_PORT") ]] ;then
    runModule "Tomcat" "$CRAFTER_BIN_DIR/apache-tomcat/bin/catalina.sh jpda start" $TOMCAT_HTTP_PORT "$CATALINA_LOGS_DIR $CATALINA_TMPDIR" $CATALINA_PID "Debug"
  else
    cecho ""
    cecho "Crafter CMS Database Port: $MARIADB_PORT is in use by process id $(getPidByPort "$MARIADB_PORT").\n" "error"
    cecho "This might be because of a prior unsuccessful or incomplete shut down.\n" "error"
    cecho "Please terminate that process before attempting to start Crafter CMS.\n" "error"
    read -t 10 # Timeout for the read, (if gradle start)
    exit -7
  fi
}

function stopTomcat() {
	stopModule "Tomcat" "$CRAFTER_BIN_DIR/apache-tomcat/bin/shutdown.sh 10 -force" "$TOMCAT_HTTP_PORT" "$CATALINA_PID"
}

function startMongoDB() {
  runModule "MongoDB" "$MONGODB_HOME/bin/mongod --dbpath=$CRAFTER_DATA_DIR/mongodb --directoryperdb --journal --fork --logpath=$MONGODB_LOGS_DIR/mongod.log --port $MONGODB_PORT"\
  $MONGODB_PORT "$MONGODB_DATA_DIR $MONGODB_LOGS_DIR" $MONGODB_PID "Start"
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

function stopMongoDB() {
	stopModule "MongoDB" "$MONGODB_HOME/bin/mongod --shutdown --dbpath=$CRAFTER_DATA_DIR/mongodb --logpath=$MONGODB_LOGS_DIR/mongod.log --port $MONGODB_PORT" "$MONGODB_PORT" "$MONGODB_PID"
}

function skipElasticsearch() {
  for o in "$@"; do
    if [ $o = "skipElasticsearch" ]; then
      return 0
    fi
  done
  return 1
}

function getStatus() {
  module=$1
  port=$2
  pidFile=$3

  banner "$module status"

  pid=$(getPidByPort $port)
  if [ -z $pid ]; then
    cecho "$module is not running\n" "warning"
  else
    cecho "$module is up and running with PID:\t$pid\n" "strong"
  fi
}

function deployerStatus(){
  getStatus "Crafter Deployer" $DEPLOYER_PORT $DEPLOYER_PID
}

function searchStatus(){
  getStatus "Crafter Search" $TOMCAT_HTTP_PORT $CATALINA_PID
}

function engineStatus(){
  getStatus "Crafter Engine" $TOMCAT_HTTP_PORT $CATALINA_PID
}

function studioStatus(){
  getStatus "Crafter Studio" $TOMCAT_HTTP_PORT $CATALINA_PID
}

function profileStatus(){
  getStatus "Crafter Profile" $TOMCAT_HTTP_PORT $CATALINA_PID
}

function socialStatus(){
  getStatus "Crafter Social" $TOMCAT_HTTP_PORT $CATALINA_PID
}

function mariadbStatus() {
  getStatus "Studio Database" $MARIADB_PORT $MARIADB_PID
}

function mongoDbStatus() {
  getStatus "MongoDB" $MONGODB_PORT "$MONGODB_PID"
}

function start() {
  startDeployer
  if ! skipElasticsearch "$@"; then
    startElasticsearch
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
  if isMongoNeeded "$@"; then
    startMongoDB
  fi
  debugTomcat
  printTailInfo
}

function stop() {
  stopTomcat
  if [ ! -z "$(getPidByPort $MONGODB_PORT)" ]; then
     stopMongoDB
  fi
  stopDeployer
  if [ ! -z "$(getPidByPort $ES_PORT)" ]; then
    stopElasticsearch
  fi
}

# shellcheck disable=SC2120
function status() {
  elasticsearchStatus
  deployerStatus
  engineStatus
  searchStatus
  if [ -f "$CRAFTER_BIN_DIR/apache-tomcat/webapps/studio.war" ]; then
    studioStatus
    mariadbStatus
  fi
  if [ -f "$CRAFTER_BIN_DIR/apache-tomcat/webapps/crafter-profile.war" ]; then
    if isMongoNeeded "$@"; then
      mongoDbStatus
    fi
    profileStatus
    if [ -f "$CRAFTER_BIN_DIR/apache-tomcat/webapps/crafter-social.war" ]; then
      socialStatus
    fi
  fi
}

case $1 in
  debug)
    splash
    debug "$@"
  ;;
  start)
    splash
    start "$@"
  ;;
  stop)
    splash
    stop $2
  ;;
  debug_deployer)
    splash
    debugDeployer
  ;;
  start_deployer)
    splash
    startDeployer
  ;;
  stop_deployer)
    splash
    stopDeployer
  ;;
  start_elasticsearch)
    splash
    startElasticsearch
  ;;
  debug_elasticsearch)
    splash
    debugElasticsearch
  ;;
  stop_elasticsearch)
    splash
    stopElasticsearch
  ;;
  debug_tomcat)
    splash
    debugTomcat
  ;;
  start_tomcat)
    splash
    startTomcat start
  ;;
  stop_tomcat)
    splash
    stopTomcat
  ;;
  start_mongodb)
    splash
    startMongoDB
  ;;
  stop_mongodb)
    splash
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
########################################################################################################################