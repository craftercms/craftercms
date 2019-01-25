FROM openjdk:8-jdk-alpine

# Install dependencies
RUN apk update && \
    apk upgrade && \
    apk add bash && \
    apk add curl

# Create main installation folder and bin folder. Current dir change to that one
RUN mkdir -p /opt/crafter && mkdir /opt/crafter/bin
WORKDIR /opt/crafter

# Create volumes for data, logs, and temp
RUN mkdir ./data && mkdir ./logs && mkdir ./temp
VOLUME ./data ./logs ./temp

# Copy delivery folder
COPY ./bin ./bin/

# Delete unnecessary files and folders
RUN rm -rf ./bin/crafter-deployer; \
    rm -rf ./bin/elasticsearch; \
    rm -rf ./bin/solr; \
    rm -rf ./bin/apache-tomcat/webapps/crafter-search*; \
    rm ./bin/init-site*; \
    rm ./bin/remove-site*

# Add the Crafter user. This user will be used onwards to setup the image and when running the container
RUN addgroup -S crafter && adduser -S -G crafter crafter
RUN chown -R crafter:crafter .
USER crafter

# Expose port
EXPOSE 8080

# Main startup command
CMD ["./bin/crafter.sh", "start_tomcat"]

