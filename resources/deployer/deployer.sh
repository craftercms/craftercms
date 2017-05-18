#!/usr/bin/env bash
DEPLOYER_HOME=${DEPLOYER_HOME:=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )}
CRAFTER_HOME=${CRAFTER_HOME:=$( cd "$DEPLOYER_HOME/.." && pwd )}
LOGS_DIR=${DEPLOYER_LOGS_DIR:="$DEPLOYER_HOME/logs"}
DATA_DIR=${DEPLOYER_DATA_DIR:="$CRAFTER_HOME/data/deployer"}
TARGETS_DIR=$DATA_DIR/targets
PROCESSED_COMMITS=$DATA_DIR/processed-commits
PORT=${DEPLOYER_PORT:="9191"}
JAVA_OPTS="$DEPLOYER_JAVA_OPTS -Dserver.port=$PORT -Dlogging.config=$DEPLOYER_HOME/logback-spring.xml -Dlogs.dir=$LOGS_DIR -Dtargets.dir=$TARGETS_DIR -DprocessedCommits.dir=$PROCESSED_COMMITS"
PID=${DEPLOYER_PID:="$DEPLOYER_HOME/crafter-deployer.pid"}
OUTPUT=${DEPLOYER_SDOUT:="$DEPLOYER_HOME/crafter-deployer.out"}

function help() {
  echo $(basename $BASH_SOURCE)
  echo "    start, Starts Deployer"
  echo "    stop, Stops Deployer"
  echo "    debug, Starts Deployer in debug mode"
  exit 0;
}

function start() {
  if [ -e "$PID" ]; then
    if pgrep -F $PID > /dev/null ; then
      echo "Crafter Deployer still running";
      exit -1;
    else
      rm $PID
    fi
  fi
  nohup java -jar $JAVA_OPTS "$DEPLOYER_HOME/crafter-deployer.jar"  > "$OUTPUT" >&1&
  echo $! > $PID
  exit 0;
}

function stop() {
  if [ -e "$PID" ]; then
    pkill -F $PID
    if [ $? -eq 0 ]; then
      rm $PID
    fi
    exit 0;
  else
    echo "Crafter Deployer already shutdown or pid $PID file not found";
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
