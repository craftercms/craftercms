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

# Generate host keys (if not mounted)
ssh-keygen -A

if [ ! -z "$CRAFTER_PASSWORD" ]; then
    echo "$CRAFTER_PASSWORD" | passwd --stdin crafter
fi

# Fix for ssh key permissions
MOUNTED_SSH_DIR=/opt/crafter/.ssh
USER_HOME_SSH_DIR=/home/crafter/.ssh

if [ -d $MOUNTED_SSH_DIR ]; then
    mkdir -p $USER_HOME_SSH_DIR
    cp -L $MOUNTED_SSH_DIR/* $USER_HOME_SSH_DIR

    chown -R crafter:crafter "$USER_HOME_SSH_DIR"
    chmod 700 $USER_HOME_SSH_DIR
    chmod 600 $USER_HOME_SSH_DIR/*
    chmod 644 $USER_HOME_SSH_DIR/*.pub
fi

if [ "$1" = 'run' ]; then
    # Do not detach, run in foreground (-D)
    exec /usr/sbin/sshd -D
else
    exec "$@"
fi