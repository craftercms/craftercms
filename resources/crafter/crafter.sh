#!/usr/bin/env bash

 DEPLOYER_JAVA_OPTS="$DEPLOYER_JAVA_OPTS "
 C_HOME=${CRAFTER_HOME:=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )}
 CD_HOME=${CRAFTER_DEPLOYER_HOME:=$C_HOME/crafter-deployer}
 CRAFTER_DEPLOYER_HOME=CD_HOME
 CATALINA_PID=${CATALINA_HOME}/tomcat.pid
 CATALINA_HOME="./apache-tomcat"
 JPDA_ADDRESS=@TOMCAT_DEBUG_PORT@
 MONGO_DB_FOLDER=mongodb

 function help() {
         echo $(basename $BASH_SOURCE)
         echo "-s start, Start crafter deployer"
         echo "-k stop, Stop crafter deployer"
         echo "-d debug, Implies start, Start crafter deployer in debug mode"
         exit 0;
 }

function mongoDB(){
    if [ -d "$MONGO_DB_FOLDER" ]; then
        cd $MONGO_DB_FOLDER
        echo "OK"
        cd $C_HOME
     else
       cd $C_HOME
       mkdir $MONGO_DB_FOLDER
       cd $MONGO_DB_FOLDER
       echo "MongoDB not found"
       java -jar $C_HOME/craftercms-utils.jar download mongodb
       tar xvf mongodb.tgz --strip 1
       rm mongodb.tgz
    fi
   $C_HOME/$MONGO_DB_FOLDER/bin/mongod --dbpath=$C_HOME/data/mongodb --directoryperdb --journal --fork --logpath=$C_HOME/data/mongodb/mongod.log --port @MONGODB_PORT@

}
function debug() {
    mongoDB
    cd $CD_HOME
     ./deployer.sh --debug;
     cd $C_HOME
     echo "Starting Solr server on port @SOLR_PORT@"
     ./solr/bin/solr start -p @SOLR_PORT@ -Dcrafter.solr.index=$C_HOME/data/indexes -a "-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=@SOLR_PORT_D@" &
     ./apache-tomcat/bin/catalina.sh jpda start;
}
function start() {
     mongoDB
    cd $CD_HOME
     ./deployer.sh --start;
     cd $C_HOME
     echo "Starting Solr server on port @SOLR_PORT@"
     ./solr/bin/solr start -p @SOLR_PORT@ -Dcrafter.solr.index=$C_HOME/data/indexes &
     ./apache-tomcat/bin/startup.sh
}

function tail() {
        tail -f $C_HOME/crafter-deployer/crafter-deployer.log $C_HOME/apache-tomcat/logs/catalina.out $C_HOME/solr/server/logs/solr.log
}

function stop() {
    mongoDB
    cd $CD_HOME
     ./deployer.sh --stop;
     cd $C_HOME
     ./solr/bin/solr stop &
     ./apache-tomcat/bin/shutdown.sh --force 20s
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
     -d|debug)
        logo
        debug
     ;;
     -s|start)
        logo
        start
     ;;
     -k|stop)
        logo
        stop
     ;;
     -t|tail)
        tail
     ;;
     *)
         help
 ;;
 esac