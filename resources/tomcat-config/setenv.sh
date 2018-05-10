#!/usr/bin/env bash
if [ "$(whoami)" == "root" ]; then
	echo -e "\033[38;5;196m"
	echo -e "Crafter CMS cowardly refuses to run as root."
    echo -e "Running as root is dangerous and is not supported."
    echo -e "\033[0m"
	exit 1
fi
JAVA_OPTS="$JAVA_OPTS -server -Xss1024K -Xms1G -Xmx3G -Djava.net.preferIPv4Stack=true"
UMASK=$(umask)