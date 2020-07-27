#!/bin/bash

if [ "$TRAVIS_PULL_REQUEST" = "false" ]; then
	bash -c 'mvn -DskipTests --settings .travis-settings.xml deploy';
fi

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
	bash -c 'mvn -DskipTests clean install';
fi
