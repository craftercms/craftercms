FROM craftercms/deployer

COPY --chown=crafter:crafter ./docker-entrypoint.sh .
COPY --chown=crafter:crafter ./config ./bin/crafter-deployer/config/

# Make sure docker-entrypoint.sh is executable
RUN chmod +x docker-entrypoint.sh