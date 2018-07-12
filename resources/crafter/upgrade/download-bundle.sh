#!/usr/bin/env bash

# Script download new version of the Crafter installation bundle

if [ "$(whoami)" == "root" ]; then
	echo -e "\033[38;5;196m"
	echo -e "Crafter CMS cowardly refuses to run as root."
	echo -e "Running as root is dangerous and is not supported."
	echo -e "\033[0m"
	exit 1
fi

export UPGRADE_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export CRAFTER_HOME=$( cd "$UPGRADE_HOME/.." && pwd )
export CRAFTER_ROOT=$( cd "$CRAFTER_HOME/.." && pwd )
export UPGRADE_TMP_DIR="$CRAFTER_ROOT/upgrade"

. "$CRAFTER_HOME/crafter-setenv.sh"

# Execute Groovy script
"$CRAFTER_HOME/groovy/bin/groovy" -cp "$CRAFTER_HOME" -Dgrape.root="$CRAFTER_HOME" "$UPGRADE_HOME/download-bundle.groovy" "$@"
