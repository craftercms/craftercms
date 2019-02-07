FROM openjdk:8-slim

ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update; \
    apt-get install -y --no-install-recommends lsof; \
    apt-get install -y --no-install-recommends curl;

# Create folder and make CRAFTER_HOME the workdir
RUN mkdir -p /opt/crafter/authoring; \
    mkdir /opt/crafter/bin; \
    mkdir /opt/crafter/bin/dbms; \
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
COPY --chown=crafter:crafter docker-entrypoint.sh .

# Expose port
EXPOSE 8080

# Make sure docker-entrypoint.sh is executable
RUN chmod +x docker-entrypoint.sh

# Main startup command
CMD [ "./docker-entrypoint.sh" ]