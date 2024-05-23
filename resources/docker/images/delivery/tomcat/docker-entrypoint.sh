#!/bin/bash

# Copyright (C) 2007-2021 Crafter Software Corporation. All Rights Reserved.
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

chown_dir() {
  local dir="$1"
  owner=$(stat -c "%U:%G" "$dir")
  if [ "$owner" != "crafter:crafter" ]; then
    echo "The owner of $dir is $owner. Changing to crafter:crafter"
    chown -R crafter:crafter "$dir"
  fi
}

host_keyscan() {
    if [ ! -d $CRAFTER_SSH_CONFIG ]; then
        mkdir -p $CRAFTER_SSH_CONFIG
        chown_dir "$CRAFTER_SSH_CONFIG"
    fi

    DOMAINS=${SSH_KEYSCAN_DOMAINS:-"bitbucket.com,gitlab.com,github.com"}
    IFS=',' read -ra LIST <<< "$DOMAINS"

    known_hosts_file="${CRAFTER_SSH_CONFIG}/known_hosts"
    if [ ! -f $known_hosts_file ]; then
        touch $known_hosts_file
    fi
    chown_dir "$known_hosts_file"

    for domain in "${LIST[@]}"; do
        host_keys=$(ssh-keygen -F "$domain" -f "$known_hosts_file")
        if [ -z "$host_keys" ]; then
            echo "Adding host keys for domain $domain to $known_hosts_file"
            ssh-keyscan "$domain" >> "$known_hosts_file"
        else
            echo "Host keys for $domain already present in $known_hosts_file"
        fi
    done
}

export CRAFTER_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export CRAFTER_BIN_DIR=$CRAFTER_HOME/bin
export CRAFTER_BACKUPS_DIR=$CRAFTER_HOME/backups

. "$CRAFTER_BIN_DIR/crafter-setenv.sh"

# Fix for volume permissions
if [ -d $CRAFTER_BACKUPS_DIR ]; then
    chown_dir "$CRAFTER_BACKUPS_DIR"
fi

chown_dir "$CRAFTER_BIN_DIR/grapes"
chown_dir "$CRAFTER_LOGS_DIR"
chown_dir "$CRAFTER_DATA_DIR"
chown_dir "$CRAFTER_TEMP_DIR"

if [ ! -d $CATALINA_LOGS_DIR ]; then
    mkdir -p $CATALINA_LOGS_DIR
    chown_dir "$CATALINA_LOGS_DIR"
fi
if [ ! -d $CATALINA_TMPDIR ]; then
    mkdir -p $CATALINA_TMPDIR
    chown_dir "$CATALINA_TMPDIR"
fi

# Export the crafter HOME dir
export HOME=/home/crafter

# Fix for ssh key permissions
MOUNTED_SSH_DIR=$CRAFTER_HOME/.ssh
USER_HOME_SSH_DIR=$HOME/.ssh

if [ -d $MOUNTED_SSH_DIR ]; then
    mkdir -p $USER_HOME_SSH_DIR
    cp -L $MOUNTED_SSH_DIR/* $USER_HOME_SSH_DIR

    chown_dir "$USER_HOME_SSH_DIR"
    chmod 700 $USER_HOME_SSH_DIR
    chmod 600 $USER_HOME_SSH_DIR/*
    chmod 644 $USER_HOME_SSH_DIR/*.pub
fi

# ssh keyscan supported domains
host_keyscan

TRUSTED_CERTS_DIR=$CRAFTER_HOME/trusted-certs

# Import trusted certs
if [ -d $TRUSTED_CERTS_DIR ]; then
    for cert_file in "$TRUSTED_CERTS_DIR"/*; do
        cert_filename="${cert_file##*/}"
        cert_filename_no_ext="${cert_filename%.*}"

        echo "Importing trusted certificate $cert_file"
        keytool -importcert -cacerts -keypass changeit -storepass changeit -noprompt -alias "$cert_filename_no_ext" -file "$cert_file"
    done
fi

if [ "$1" = 'run' ]; then
    exec gosu crafter $CRAFTER_BIN_DIR/apache-tomcat/bin/catalina.sh run
elif [ "$1" = 'debug' ]; then
    exec gosu crafter $CRAFTER_BIN_DIR/apache-tomcat/bin/catalina.sh jpda run
elif [ "$1" = 'backup' ]; then
    exec gosu crafter $CRAFTER_BIN_DIR/crafter.sh backup
elif [ "$1" = 'restore' ]; then
    if [ -z "$2" ]; then
        echo "The backup path parameter was not specified"
        exit 1
    fi

    exec gosu crafter $CRAFTER_BIN_DIR/crafter.sh restore "$2"
else
    exec "$@"
fi