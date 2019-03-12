#!/bin/bash
if [ "$(whoami)" == "root" ]; then
	echo -e "\033[38;5;196m"
	echo -e "Crafter CMS cowardly refuses to run as root."
    echo -e "Running as root is dangerous and is not supported."
    echo -e "\033[0m"
	exit 1
fi
# Opts used in both Tomcat start and stop
JAVA_OPTS="$JAVA_OPTS -Dtomcat.shutdown.port=$TOMCAT_SHUTDOWN_PORT"
UMASK=$(umask)
