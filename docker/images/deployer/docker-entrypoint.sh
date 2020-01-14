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

if [ ! -d $DEPLOYER_LOGS_DIR ]; then
    mkdir -p $DEPLOYER_LOGS_DIR;
fi

# Fix for volume permissions
chown -R crafter:crafter "$CRAFTER_LOGS_DIR"
chown -R crafter:crafter "$CRAFTER_DATA_DIR"
chown -R crafter:crafter "$CRAFTER_TEMP_DIR"

# Export the crafter HOME dir
export HOME=/home/crafter

# Fix for ssh key permissions
MOUNTED_SSH_DIR=$CRAFTER_HOME/.ssh
USER_HOME_SSH_DIR=$HOME/.ssh

if [ -d $MOUNTED_SSH_DIR ]; then
    mkdir -p $USER_HOME_SSH_DIR
    cp -L $MOUNTED_SSH_DIR/* $USER_HOME_SSH_DIR

    chown -R crafter:crafter "$USER_HOME_SSH_DIR" 
    chmod 700 $USER_HOME_SSH_DIR
    chmod 600 $USER_HOME_SSH_DIR/*
    chmod 644 $USER_HOME_SSH_DIR/*.pub
fi

if [ "$1" = 'run' ]; then
    cd $DEPLOYER_HOME
    exec gosu crafter $CRAFTER_BIN_DIR/crafter-deployer/deployer.sh run
elif [ "$1" = 'debug' ]; then
    export JAVA_OPTS="$JAVA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005"
    cd $DEPLOYER_HOME
    exec gosu crafter $CRAFTER_BIN_DIR/crafter-deployer/deployer.sh run
else
    exec "$@"
fi