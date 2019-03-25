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
FROM openjdk:8-alpine

# Install dependencies
RUN apk add --no-cache bash shadow openssh-client git su-exec

# Create folders and make CRAFTER_HOME the workdir
RUN mkdir -p /opt/crafter; \
    mkdir /opt/crafter/bin; \
    mkdir /opt/crafter/data; \
    mkdir /opt/crafter/logs; \
    mkdir /opt/crafter/temp

WORKDIR /opt/crafter

# Create volumes
VOLUME [ "/opt/crafter/data", "/opt/crafter/logs", "/opt/crafter/temp" ]

# Copy bin folder
COPY ./bin ./bin/

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
COPY ./docker-run.sh .
RUN chmod +x docker-run.sh

# Add the Crafter user
RUN groupadd -r -g 1000 crafter && useradd -r -m -u 1000 -g crafter crafter; \
    chown -R crafter:crafter .

# Expose port
EXPOSE 9191

# Main startup command
CMD [ "./docker-run.sh" ]