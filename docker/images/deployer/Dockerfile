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
FROM openjdk:8-slim

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
USER crafter

# Copy bin folder and entrypoint script
COPY --chown=crafter:crafter ./bin ./bin/
COPY --chown=crafter:crafter ./docker-entrypoint.sh .

# Replace ports for default ones
RUN sed -i 's/8695/8983/g' ./bin/crafter-setenv.sh; \
    sed -i 's/9202/9200/g' ./bin/crafter-setenv.sh; \
    sed -i 's/9192/9191/g' ./bin/crafter-setenv.sh; \
    sed -i 's/28020/27017/g' ./bin/crafter-setenv.sh; \
    sed -i 's/9080/8080/g' ./bin/crafter-setenv.sh; \
    sed -i 's/9443/8443/g' ./bin/crafter-setenv.sh; \
    sed -i 's/9009/8009/g' ./bin/crafter-setenv.sh; \
    sed -i 's/9005/8005/g' ./bin/crafter-setenv.sh;

# Expose port
EXPOSE 9191

# Make sure docker-entrypoint.sh is executable
RUN chmod +x docker-entrypoint.sh

# Main startup command
CMD [ "./docker-entrypoint.sh" ]