#!/usr/bin/env bash

# Copyright (C) 2007-2019 Crafter Software Corporation. All Rights Reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Script to remove a site from a delivery environment.

if [ "$(whoami)" == "root" ]; then
	echo -e "\033[38;5;196m"
	echo -e "Crafter CMS cowardly refuses to run as root."
	echo -e "Running as root is dangerous and is not supported."
	echo -e "\033[0m"
	exit 1
fi

export DELIVERY_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. "$DELIVERY_HOME/crafter-setenv.sh"

# Execute Groovy script
"$DELIVERY_HOME/groovy/bin/groovy" -cp "$DELIVERY_HOME" -Dgrape.root="$DELIVERY_HOME" "$DELIVERY_HOME/remove-site.groovy" "$@"
