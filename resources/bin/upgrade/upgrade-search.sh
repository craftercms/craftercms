#!/bin/bash

# Copyright (C) 2007-2023 Crafter Software Corporation. All Rights Reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as published by
# the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Script to upgrade a target Crafter installation based on this bundle

if [ "$(whoami)" == "root" ]; then
  echo -e "\033[38;5;196m"
  echo -e "CrafterCMS cowardly refuses to run as root."
  echo -e "Running as root is dangerous and is not supported."
  echo -e "\033[0m"
  exit 1
fi

export UPGRADE_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export UPGRADE_BIN_DIR=$( cd "$UPGRADE_HOME/.." && pwd )
export ENVIRONMENT_NAME="@ENV@"
export UPGRADE_TMP_DIR="$UPGRADE_HOME/../../temp/upgrade"

# Execute Groovy scripts
"$UPGRADE_BIN_DIR/groovy/bin/groovy" -cp "$UPGRADE_BIN_DIR" -Dgrape.root="$UPGRADE_BIN_DIR" "$UPGRADE_HOME/upgrade-search.groovy" "$@"
