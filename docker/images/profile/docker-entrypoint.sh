#!/bin/bash

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

export CRAFTER_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export CRAFTER_BIN_DIR=$CRAFTER_HOME/bin

. "$CRAFTER_BIN_DIR/crafter-setenv.sh"

if [ ! -z "$CRAFTER_PASSWORD" ]; then
    echo "$CRAFTER_PASSWORD" | passwd --stdin crafter
fi

if [ ! -d $CATALINA_LOGS_DIR ]; then
    mkdir -p $CATALINA_LOGS_DIR
fi
if [ ! -d $CATALINA_TMPDIR ]; then
    mkdir -p $CATALINA_TMPDIR
fi

chown -R crafter:crafter "$CRAFTER_LOGS_DIR"
chown -R crafter:crafter "$CRAFTER_TEMP_DIR"

# Export the crafter HOME dir
export HOME=/home/crafter

if [ "$1" = 'run' ]; then
    exec gosu crafter $CRAFTER_BIN_DIR/apache-tomcat/bin/catalina.sh run
elif [ "$1" = 'debug' ]; then
    exec gosu crafter $CRAFTER_BIN_DIR/apache-tomcat/bin/catalina.sh jpda run
else
    exec "$@"
fi