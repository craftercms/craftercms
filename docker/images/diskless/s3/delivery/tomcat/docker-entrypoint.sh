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

if [ -z "$AWS_ACCESS_KEY" ]; then
    if [ ! -z "$AWS_SECRET_KEY" ]; then
        echo "AWS_SECRET_KEY was specified but not AWS_ACCESS_KEY"
        exit 1
    fi
else
    if [ -z "$AWS_SECRET_KEY" ]; then
        echo "AWS_ACCESS_KEY was specified but not AWS_SECRET_KEY"
        exit 1
    else
        export CATALINA_OPTS="$CATALINA_OPTS -Daws.accessKey=$AWS_ACCESS_KEY -Daws.secretKey=$AWS_SECRET_KEY"
    fi
fi

if [ ! -z "$AWS_REGION" ]; then
    export CATALINA_OPTS="$CATALINA_OPTS -Daws.region=$AWS_REGION"
fi

if [ -z "$AWS_ELASTIC_SEARCH_URL" ]; then
    echo "AWS_ELASTIC_SEARCH_URL needs to be specified"
    exit 1
else
    export CATALINA_OPTS="$CATALINA_OPTS -Daws.elasticsearch.url=$AWS_ELASTIC_SEARCH_URL"
fi

if [ -z "$S3_BASE_PATH" ]; then
    echo "S3_BASE_PATH needs to be specified"
    exit 1
else
    export CATALINA_OPTS="$CATALINA_OPTS -Ds3.basePath=$S3_BASE_PATH"
fi

if [ ! -d $CATALINA_LOGS_DIR ]; then
    mkdir -p $CATALINA_LOGS_DIR;
fi
if [ ! -d $CATALINA_TMPDIR ]; then
    mkdir -p $CATALINA_TMPDIR;
fi

$CRAFTER_BIN_DIR/apache-tomcat/bin/catalina.sh run -security