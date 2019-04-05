#!/bin/bash
if [ "$(whoami)" == "root" ]; then
	echo -e "\033[38;5;196m"
	echo -e "Crafter CMS cowardly refuses to run as root."
    echo -e "Running as root is dangerous and is not supported."
    echo -e "\033[0m"
	exit 1
fi

# Opts used only in Tomcat start
CATALINA_OPTS="$CATALINA_OPTS -Dtomcat.host=$TOMCAT_HOST -Dtomcat.http.port=$TOMCAT_HTTP_PORT \
  -Dtomcat.https.port=$TOMCAT_HTTPS_PORT -Dtomcat.ajp.port=$TOMCAT_AJP_PORT -Dmail.host=$MAIL_HOST \
  -Dmail.port=$MAIL_PORT -Dmongodb.host=$MONGODB_HOST -Dmongodb.port=$MONGODB_PORT -Dmariadb.host=$MARIADB_HOST \
  -Dmariadb.port=$MARIADB_PORT -Dsolr.url=$SOLR_URL -Des.url=$ES_URL -Ddeployer.url=$DEPLOYER_URL \
  -Dcrafter.home=$CRAFTER_HOME -Dcrafter.bin.dir=$CRAFTER_BIN_DIR -Dcrafter.data.dir=$CRAFTER_DATA_DIR \
  -Dcrafter.logs.dir=$CRAFTER_LOGS_DIR -Dcatalina.logs=$CATALINA_LOGS_DIR -Dapplication.logs=$CATALINA_LOGS_DIR \
  -Djava.net.preferIPv4Stack=true"
# Opts used in both Tomcat start and stop
JAVA_OPTS="$JAVA_OPTS -Dtomcat.shutdown.port=$TOMCAT_SHUTDOWN_PORT"
UMASK=$(umask)
