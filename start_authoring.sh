#!/usr/bin/env bash
./gradlew start -Penv=authoring ;
tail -f crafter-authoring/logs/tomcat/catalina.out;