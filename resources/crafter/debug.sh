#!/usr/bin/env bash
CRAFTER_DEBUG_HOME=${CRAFTER_DEBUG_HOME:=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )}

if [[ -s  "$CRAFTER_DEBUG_HOME/crafter.sh" ]]; then
      $CRAFTER_DEBUG_HOME/crafter.sh stop
      exit 0
else
      echo -e "\033[38;5;196m"
      echo "crafter.sh was not found in $CRAFTER_DEBUG_HOME"
      echo -e "\033[0m"
      exit -1
fi
