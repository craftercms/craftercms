FROM openjdk:8-slim

ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update; \
    apt-get install -y --no-install-recommends lsof; \
    apt-get install -y --no-install-recommends curl

# Create main installation folder and bin folder. Current dir change to that one
RUN mkdir -p /opt/crafter && mkdir /opt/crafter/bin
WORKDIR /opt/crafter

# Create volumes for data, logs, and temp
RUN mkdir ./data && mkdir ./logs && mkdir ./temp
VOLUME ./data ./logs ./temp

# Copy delivery folder
COPY ./bin ./bin/
COPY docker-entrypoint.sh .

# Add the Crafter user. This user will be used onwards to setup the image and when running the container
RUN groupadd -g 1000 -r crafter && useradd -r -u 1000 -g crafter crafter
RUN chown -R crafter:crafter .
USER crafter

# Expose port
ENV DEPLOYER_PORT 9191
EXPOSE 9191

# Make sure docker-entrypoint.sh is executable
RUN chmod +x docker-entrypoint.sh

# Main startup command
CMD [ "./docker-entrypoint.sh" ]