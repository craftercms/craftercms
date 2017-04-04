#!/usr/bin/env bash
CD_HOME=${CRAFTER_DEPLOYER_HOME:=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )}
C_HOME=${C_HOME:="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/../}
DEPLOYER_JAVA_OPTS="$DEPLOYER_JAVA_OPTS -Dlogging.config=logback-spring.xml -Ddeployer.main.deployments.output.folderPath=logs -Ddeployer.main.logging.folderPath=logs -Ddeployer.main.homePath=$C_HOME/data/deployer"
PID=${DEPLOYER_PID:="crafter-deployer.pid"}
OUTPUT=${CRAFTER_DEPLOYER_SDOUT:='crafter-deployer.log'}
echo $C_HOME
function start() {
    if [ -f $CD_HOME/$PID ]; then
        if pgrep -F $CD_HOME/$PID > /dev/null ; then
            echo "Crafter Deployer still running";
            exit -1;
        else
            rm $CD_HOME/$PID
        fi
    fi
    nohup java -jar $DEPLOYER_JAVA_OPTS "$CD_HOME/crafter-deployer.jar"  > "$CD_HOME/$OUTPUT" >&1&
    echo $! > $CD_HOME/$PID
    exit 0;
}
function stop() {
    if [ -e "$CD_HOME/$PID" ]
         kill `cat $CD_HOME/$PID`
    if [ $? -eq 0 ]; then
        rm $CD_HOME/$PID
    fi
    exit 0;
then
    "Default \e[43mCrafter Deployer already shutdown or pid $CD_HOME/$PID file not found"
fi

}
function help() {
        echo $(basename $BASH_SOURCE)
        echo "-s start, Start crafter deployer"
        echo "-k stop, Stop crafter deployer"
        echo "-d debug, Implieds start, Start crafter deployer in debug mode"
        exit 0;
}
case $1 in
    -d|--debug)
        set DEPLOYER_JAVA_OPTS = "$DEPLOYER_JAVA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005"
        start
    ;;
    -s|--start)
        start
    ;;
    -k|--stop)
        stop
    ;;
    *)
        help
    ;;
esac
