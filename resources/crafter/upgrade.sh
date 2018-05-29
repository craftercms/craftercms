#!/usr/bin/env bash

# Script to upgrade the Crafter installation

if [ "$(whoami)" == "root" ]; then
	echo -e "\033[38;5;196m"
	echo -e "Crafter CMS cowardly refuses to run as root."
	echo -e "Running as root is dangerous and is not supported."
	echo -e "\033[0m"
	exit 1
fi

export CRAFTER_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export CRAFTER_ROOT=$( cd "$( dirname "$CRAFTER_HOME/.." )" && pwd )

. "$CRAFTER_HOME/crafter-setenv.sh"

# Execute Groovy script
$CRAFTER_HOME/groovy/bin/groovy -Dgrape.root=$CRAFTER_HOME $CRAFTER_HOME/upgrade.groovy "$@"
