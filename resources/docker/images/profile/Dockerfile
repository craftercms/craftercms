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
FROM eclipse-temurin:21-jdk-alpine AS main

############# INSTALL NATIVE TOMCAT #############
ENV CATALINA_HOME=/usr/local/tomcat \
    TOMCAT_MAJOR="10" \
    TOMCAT_VERSION="10.1.24"

# Download Tomcat, and then Build tc-native
RUN apk add --no-cache --virtual .my-build-deps apr-dev openssl-dev make g++ && \
    cd /tmp && \
    wget -O apache-tomcat.tar.gz http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar -C /opt -xf apache-tomcat.tar.gz && \
    ln -s /opt/apache-tomcat-$TOMCAT_VERSION $CATALINA_HOME && \
    cd $CATALINA_HOME/bin && \
    tar -xf tomcat-native.tar.gz && \
    rm -f tomcat-native.tar.gz && \
    cd tomcat-native-*-src/native && \
    ./configure --with-java-home=$JAVA_HOME --prefix=$CATALINA_HOME && \
    make && \
    make install && \
    make clean && \
    rm -rf /tmp/* && \
    # Remove added packages
    apk del --purge .my-build-deps && \
    rm -rf /var/cache/apk/*

#################################################

# Install dependencies
RUN set -eux; \
    apk update; \
    apk upgrade; \
    apk add --no-cache bash; \
#    apk add --no-cache vim; \
    apk add --no-cache nano;

# Install gosu
ENV GOSU_VERSION 1.17
RUN set -eux; \
    apk add --no-cache --virtual .fetch-deps dpkg gnupg; \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
    GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    gpgconf --kill all; \
    rm -rf "$GNUPGHOME"; unset GNUPGHOME; \
    apk del --no-network .fetch-deps; \
    chmod +x /usr/local/bin/gosu; \
    gosu --version; \
    gosu nobody true; \
    # hard link to / for ease of COPY --from
    ln -v /usr/local/bin/gosu /

# Create folders and make CRAFTER_HOME the workdir
RUN mkdir -p /opt/crafter; \
    mkdir /opt/crafter/bin; \
    mkdir /opt/crafter/logs; \
    mkdir /opt/crafter/temp

WORKDIR /opt/crafter

# Create volumes
VOLUME [ "/opt/crafter/logs", "/opt/crafter/temp" ]

# Add the Crafter user
RUN addgroup -S -g 1000 crafter && adduser -S -u 1000 -G crafter crafter; \
    chown -R crafter:crafter .; \
    chown -R crafter:crafter /usr/local/tomcat/

# Link ./bin/apache-tomcat to the image's own Tomcat
# Delete the conf and webapps
RUN gosu crafter ln -s /usr/local/tomcat ./bin/apache-tomcat; \
    rm -rf ./bin/apache-tomcat/conf/* && rm -rf ./bin/apache-tomcat/webapps/*

# Copy version.txt, crafter-setenv.sh, Tomcat setenv.sh, config, shared and profile webapps
COPY --chown=crafter:crafter ./bin/version.txt ./bin/
COPY --chown=crafter:crafter ./bin/crafter-setenv.sh ./bin/
COPY --chown=crafter:crafter ./bin/apache-tomcat/bin/setenv.sh ./bin/apache-tomcat/bin/
COPY --chown=crafter:crafter ./bin/apache-tomcat/conf ./bin/apache-tomcat/conf/
COPY --chown=crafter:crafter ./bin/apache-tomcat/webapps/crafter-profile.war ./bin/apache-tomcat/webapps/
COPY --chown=crafter:crafter ./bin/apache-tomcat/webapps/crafter-profile-admin.war ./bin/apache-tomcat/webapps/
COPY --chown=crafter:crafter ./bin/apache-tomcat/shared/classes/crafter/profile ./bin/apache-tomcat/shared/classes/crafter/profile/

# Remove CATALINA_HOME from crafter-setenv.sh
# Replace ports for default ones
RUN sed -i '/export CATALINA_HOME=$CRAFTER_BIN_DIR\/apache-tomcat/d' ./bin/crafter-setenv.sh; \
    sed -i 's/8695/8983/g' ./bin/crafter-setenv.sh; \
    sed -i 's/9202/9200/g' ./bin/crafter-setenv.sh; \
    sed -i 's/9192/9191/g' ./bin/crafter-setenv.sh; \
    sed -i 's/28020/27017/g' ./bin/crafter-setenv.sh; \
    sed -i 's/9080/8080/g' ./bin/crafter-setenv.sh; \
    sed -i 's/9443/8443/g' ./bin/crafter-setenv.sh; \
    sed -i 's/9009/8009/g' ./bin/crafter-setenv.sh; \
    sed -i 's/9005/8005/g' ./bin/crafter-setenv.sh;

# Copy entrypoint script and make it executable
COPY docker-entrypoint.sh .
RUN chmod +x docker-entrypoint.sh

# Run the application as following user
USER root

# Entrypoint and command (run by default)
ENTRYPOINT [ "./docker-entrypoint.sh" ]
CMD [ "run" ]
