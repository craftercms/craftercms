#!/usr/bin/env bash

 DEPLOYER_JAVA_OPTS="$DEPLOYER_JAVA_OPTS "
 CD_HOME=${CRAFTER_DEPLOYER_HOME:=`pwd`}
 CATALINA_PID=${CATALINA_HOME}/tomcat.pid
CATALINA_HOME="./apache-tomcat"
 function help() {
         echo $(basename $BASH_SOURCE)
         echo "-s --start, Start crafter deployer"
         echo "-k --stop, Stop crafter deployer"
         echo "-d --debug, Implieds start, Start crafter deployer in debug mode"
         exit 0;
 }

function debug() {
    cd crafter-deployer
     ./deployer.sh --debug;
     cd ..
      ./solr/bin/solr start -p 8984 -a "-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=1044"
     ./apache-tomcat/bin/catalina.sh jpda start;
}
function start() {
    cd crafter-deployer
     ./deployer.sh --start;
     cd ..
     ./solr/bin/solr start -p 8984
     ./apache-tomcat/bin/startup.sh
}

function tail() {
        tail -f crafter-deployer/crafter-deployer.log apache-tomcat/logs/catalina.out solr/server/logs/solr.log
}

function stop() {
    cd crafter-deployer
     ./deployer.sh --stop;
     cd ..
     ./solr/bin/solr stop
     ./apache-tomcat/bin/shutdown.sh
}

function logo() {
echo " ██████╗ ██████╗   █████╗  ███████╗ ████████╗ ███████╗ ██████╗      ██████╗ ███╗   ███╗ ███████╗"
echo "██╔════╝ ██╔══██╗ ██╔══██╗ ██╔════╝ ╚══██╔══╝ ██╔════╝ ██╔══██╗    ██╔════╝ ████╗ ████║ ██╔════╝"
echo "██║      ██████╔╝ ███████║ █████╗      ██║    █████╗   ██████╔╝    ██║      ██╔████╔██║ ███████╗"
echo "██║      ██╔══██╗ ██╔══██║ ██╔══╝      ██║    ██╔══╝   ██╔══██╗    ██║      ██║╚██╔╝██║ ╚════██║"
echo "╚██████╗ ██║  ██║ ██║  ██║ ██║         ██║    ███████╗ ██║  ██║    ╚██████╗ ██║ ╚═╝ ██║ ███████║"
echo " ╚═════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚═╝         ╚═╝    ╚══════╝ ╚═╝  ╚═╝     ╚═════╝ ╚═╝     ╚═╝ ╚══════╝"
}

 case $1 in
     -d|--debug)
        logo
        debug
     ;;
     -s|--start)
        logo
        start
     ;;
     -k|--stop)
        logo
        stop
     ;;
     -t|--tail)
        tail
     ;;
     *)
         help
 ;;
 esac
