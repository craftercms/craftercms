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
FROM tomcat:8-slim

# Install dependencies
ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get update; \
    apt-get install -y gosu; \
    apt-get install -y --no-install-recommends lsof; \
    apt-get install -y --no-install-recommends openssh-client; \
    apt-get install -y --no-install-recommends git; \
    rm -rf /var/lib/apt/lists/*;

# Create folders and make CRAFTER_HOME the workdir
RUN mkdir -p /opt/crafter; \
    mkdir /opt/crafter/bin; \
    mkdir /opt/crafter/backups; \
    mkdir /opt/crafter/data; \
    mkdir /opt/crafter/logs; \
    mkdir /opt/crafter/temp

WORKDIR /opt/crafter

# Create volumes
VOLUME [ "/opt/crafter/data", "/opt/crafter/logs", "/opt/crafter/temp" ]

# Copy bin folder
COPY ./bin ./bin/

# Delete the apache tomcat folder, we're going to link to the image's own Tomcat
RUN rm -rf ./bin/apache-tomcat && ln -s /usr/local/tomcat ./bin/apache-tomcat

# Copy Tomcat setenv.sh, config, shared and webapps
RUN rm -rf ./bin/apache-tomcat/conf/* && rm -rf ./bin/apache-tomcat/webapps/*
COPY ./bin/apache-tomcat/bin/setenv.sh ./bin/apache-tomcat/bin/
COPY ./bin/apache-tomcat/conf ./bin/apache-tomcat/conf/
COPY ./bin/apache-tomcat/webapps ./bin/apache-tomcat/webapps/

# Create and copy the shared folder
RUN mkdir ./bin/apache-tomcat/shared
COPY ./bin/apache-tomcat/shared ./bin/apache-tomcat/shared/

# Remove CATALINA_HOME from crafter-setenv.sh
RUN sed -i '/export CATALINA_HOME=$CRAFTER_BIN_DIR\/apache-tomcat/d' ./bin/crafter-setenv.sh

# Replace ports for default ones
RUN sed -i 's/8695/8983/g' ./bin/crafter-setenv.sh; \
    sed -i 's/9202/9200/g' ./bin/crafter-setenv.sh; \
    sed -i 's/9192/9191/g' ./bin/crafter-setenv.sh; \
    sed -i 's/28020/27017/g' ./bin/crafter-setenv.sh; \
    sed -i 's/9080/8080/g' ./bin/crafter-setenv.sh; \
    sed -i 's/9443/8443/g' ./bin/crafter-setenv.sh; \
    sed -i 's/9009/8009/g' ./bin/crafter-setenv.sh; \
    sed -i 's/9005/8005/g' ./bin/crafter-setenv.sh;

# Copy entrypoint script and make it executable
COPY ./docker-entrypoint.sh .
RUN chmod +x docker-entrypoint.sh

# Add the Crafter user
RUN groupadd -r -g 1000 crafter && useradd -r -m -u 1000 -g crafter crafter; \
    chown -R crafter:crafter .; \
    chown -R crafter:crafter /usr/local/tomcat

# Entrypoint and command (run by default)
ENTRYPOINT [ "./docker-entrypoint.sh" ]
CMD [ "run" ]