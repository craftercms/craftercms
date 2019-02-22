FROM craftercms/delivery_tomcat

COPY --chown=crafter:crafter ./docker-entrypoint.sh .
COPY --chown=crafter:crafter ./config/engine ./bin/apache-tomcat/shared/classes/crafter/engine/extension/

# Make sure docker-entrypoint.sh is executable
RUN chmod +x docker-entrypoint.sh