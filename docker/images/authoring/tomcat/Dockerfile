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
FROM tomcat:8.5.38-slim

# Create folder and make CRAFTER_HOME the workdir
RUN mkdir -p /opt/crafter; \
    mkdir /opt/crafter/bin; \
    mkdir /opt/crafter/data; \
    mkdir /opt/crafter/logs; \
    mkdir /opt/crafter/temp
WORKDIR /opt/crafter

# Add the Crafter user. This user will be used onwards to setup the image and when running the container
RUN groupadd -g 1000 -r crafter && useradd -r -u 1000 -g crafter crafter
RUN chown -R crafter:crafter .
RUN chown -R crafter:crafter /usr/local/tomcat
USER crafter

# Copy bin folder
COPY --chown=crafter:crafter ./bin ./bin/

# Delete the apache tomcat folder, we're going to link to the image's own Tomcat
RUN rm -rf ./bin/apache-tomcat && ln -s /usr/local/tomcat ./bin/apache-tomcat

# Copy Tomcat config, shared and webapps
RUN rm -rf ./bin/apache-tomcat/conf/* && rm -rf ./bin/apache-tomcat/webapps/*
COPY --chown=crafter:crafter ./bin/apache-tomcat/conf ./bin/apache-tomcat/conf/
COPY --chown=crafter:crafter ./bin/apache-tomcat/webapps ./bin/apache-tomcat/webapps/

# Create and copy the shared folder
RUN mkdir ./bin/apache-tomcat/shared
COPY --chown=crafter:crafter ./bin/apache-tomcat/shared ./bin/apache-tomcat/shared/

# Copy entrypoint script and make it is executable
COPY --chown=crafter:crafter ./docker-entrypoint.sh .
RUN chmod +x docker-entrypoint.sh

# Remove CATALINA_HOME from crafter-setenv.sh
RUN sed -i '/export CATALINA_HOME=$CRAFTER_BIN_DIR\/apache-tomcat/d' ./bin/crafter-setenv.sh

# Replace ports for default ones
RUN sed -i 's/8694/8983/g' ./bin/crafter-setenv.sh; \
    sed -i 's/9201/9200/g' ./bin/crafter-setenv.sh; \
    sed -i 's/27020/27017/g' ./bin/crafter-setenv.sh; \
    sed -i 's/33306/3306/g' ./bin/crafter-setenv.sh;

# Main startup command
CMD [ "./docker-entrypoint.sh" ]