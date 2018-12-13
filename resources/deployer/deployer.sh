#!/usr/bin/env bash

DEPLOYER_HOME=${DEPLOYER_HOME:=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )}
CRAFTER_HOME=${CRAFTER_HOME:=$( cd "$DEPLOYER_HOME/.." && pwd )}
CRAFTER_ROOT=${CRAFTER_ROOT:=$( cd "$CRAFTER_HOME/.." && pwd )}
LOGS_DIR=${DEPLOYER_LOGS_DIR:="$CRAFTER_LOGS_DIR/deployer"}
DATA_DIR=${DEPLOYER_DATA_DIR:="$CRAFTER_ROOT/data/deployer"}
DEPLOYMENTS_DIR=${DEPLOYER_DEPLOYMENTS_DIR:="$CRAFTER_ROOT/data/repos/sites"}
TARGETS_DIR=$DATA_DIR/targets
PROCESSED_COMMITS=$DATA_DIR/processed-commits
PORT=${DEPLOYER_PORT:="9191"}
JAVA_OPTS="$DEPLOYER_JAVA_OPTS -Dserver.port=$PORT -Dlogging.config=$DEPLOYER_HOME/logback-spring.xml -Dlogs.dir=$LOGS_DIR -Ddeployments.dir=$DEPLOYMENTS_DIR -Dtargets.dir=$TARGETS_DIR -DprocessedCommits.dir=$PROCESSED_COMMITS -Dloader.path=$DEPLOYER_HOME/lib"
PID=${DEPLOYER_PID:="$DATA_DIR/crafter-deployer.pid"}
OUTPUT=${DEPLOYER_SDOUT:="$LOGS_DIR/crafter-deployer.out"}

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

function help() {
  echo $(basename $BASH_SOURCE)
  echo "    start, Starts Deployer"
  echo "    stop, Stops Deployer"
  echo "    debug, Starts Deployer in debug mode"
  exit 0;
}

function start() {
  if [ ! -s "$PID" ]; then
    ## Before run check if the port is available.
    possiblePID=$(pidOf $PORT)
    if  [ -z "$possiblePID" ];  then
      nohup java -jar $JAVA_OPTS "$DEPLOYER_HOME/crafter-deployer.jar"  > "$OUTPUT" >&1&
      echo $! > $PID
    else
      echo $possiblePID > $PID
      echo "Process PID $possiblePID is listening port $PORT"
      echo "Hijacking PID and saving into $PID"
      exit
    fi
  else
    # IS it really up ?
    if ! checkPortForRunning $PORT $(cat "$PID");then
      exit 5
    fi
    if ! pgrep -u `whoami` -F "$PID" >/dev/null
    then
      echo "Deployer pid file is not ok, forcing startup"
      rm "$PID"
      start
    else
      echo "Deployer already started"
    fi
  fi
}

function stop() {
  if [ -s "$PID" ]; then
    killPID $PID
  else
    pid=$(pidOf $PORT)
    if ! [ -z $pid ]; then
      #No Pid file but aye to the port
      echo "$pid" > $PID
      killPID $PID
    fi
    echo "Crafter Deployer already shutdown or pid $PID file not found";
  fi
  if [ $? -eq 0 ] && [ -e $PID ]; then
    rm $PID
  fi
}

case $1 in
  debug)
  JAVA_OPTS="$JAVA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005"
  start
  ;;
  start)
  start
  ;;
  stop)
  stop
  ;;
  *)
  help
  ;;
esac
