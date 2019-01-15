#!/usr/bin/env bash

# Script to upgrade a target Crafter installation based on this bundle

if [ "$(whoami)" == "root" ]; then
  echo -e "\033[38;5;196m"
  echo -e "Crafter CMS cowardly refuses to run as root."
  echo -e "Running as root is dangerous and is not supported."
  echo -e "\033[0m"
  exit 1
fi

export UPGRADE_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export CRAFTER_BIN_DIR=$( cd "$UPGRADE_HOME/.." && pwd )
export CRAFTER_HOME=$( cd "$CRAFTER_BIN_DIR/.." && pwd )
export ENVIRONMENT_NAME="@ENV@"

. "$CRAFTER_BIN_DIR/crafter-setenv.sh"

# Execute Groovy scripts
"$CRAFTER_BIN_DIR/groovy/bin/groovy" -cp "$CRAFTER_BIN_DIR" -Dgrape.root="$CRAFTER_BIN_DIR" "$UPGRADE_HOME/upgrade-target.groovy" "$@"
