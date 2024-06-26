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
FROM alpine:3.19 as main

# Add default variables. Default cron runs the logrotate every hour.
ENV CRON_SCHEDULE='0 * * * *' \
    LOGROTATE_PATTERN='/opt/crafter/logs/*/*.log /opt/crafter/logs/*/*.txt /opt/crafter/logs/*/*.csv' \
    LOGROTATE_COPIES='10' \
    LOGROTATE_SIZE='100M' \
    LOGROTATE_DATE_FORMAT='-%Y%m%d_%H%M%S' \
    CRONTAB_DIRECTORY='/home/crafter/crontabs' \
    LOGROTATE_DIRECTORY='/home/crafter/logrotate'

# Update & Upgrade existing packages
RUN apk update && apk upgrade

# Install dependencies
RUN apk add --no-cache bash shadow logrotate tini gettext libintl vim nano dcron libcap

# Add the Crafter user
RUN groupadd -r -g 1000 crafter && useradd -r -m -u 1000 -g crafter crafter

# Copy entrypoint script and make it executable
COPY docker-entrypoint.sh .
RUN chmod +x docker-entrypoint.sh

# Copy logrotate template conf
COPY logrotate.tpl.conf .
RUN cat logrotate.tpl.conf | envsubst > /etc/logrotate.conf

# Setup crafter user crontab
RUN chown crafter:crafter /usr/sbin/crond; \
    setcap cap_setgid=ep /usr/sbin/crond; \
    mkdir -p $LOGROTATE_DIRECTORY; \
    chown -R crafter:crafter $LOGROTATE_DIRECTORY; \
    mkdir -p $CRONTAB_DIRECTORY; \
    echo "$CRON_SCHEDULE /usr/sbin/logrotate /etc/logrotate.conf -s $LOGROTATE_DIRECTORY/logrotate-state" > $CRONTAB_DIRECTORY/crafter; \
    chown -R crafter:crafter $CRONTAB_DIRECTORY; \
    chmod 600 $CRONTAB_DIRECTORY/crafter; \
    crontab $CRONTAB_DIRECTORY/crafter;

# Run as crafter user
USER crafter

# Entrypoint and command
ENTRYPOINT [ "./docker-entrypoint.sh" ]
CMD ["/usr/sbin/crond", "-f", "-L", "/dev/stdout", "-c", "/home/crafter/crontabs"]
