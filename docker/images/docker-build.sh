#!/bin/bash

DOCKER_IMAGE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
DEPLOYED_AUTHORING_BIN_DIR=$( cd "$DOCKER_IMAGE_DIR/../../crafter-authoring/bin" && pwd )
DEPLOYED_DELIVERY_BIN_DIR=$( cd "$DOCKER_IMAGE_DIR/../../crafter-delivery/bin" && pwd )
BUILD_DIR=$DOCKER_IMAGE_DIR/build

function buildAuthoringTomcat() {
    echo "------------------------------------------------------------------------"
    echo "Building Authoring Tomcat Image"
    echo "------------------------------------------------------------------------"

    AUTHORING_TOMCAT_BUILD_DIR=$BUILD_DIR/authoring-tomcat

    # Clean old build files
    rm -rf $AUTHORING_TOMCAT_BUILD_DIR
    mkdir -p $AUTHORING_TOMCAT_BUILD_DIR;

    cp -r $DOCKER_IMAGE_DIR/authoring-tomcat/* $AUTHORING_TOMCAT_BUILD_DIR/
    cp -r $DEPLOYED_AUTHORING_BIN_DIR $AUTHORING_TOMCAT_BUILD_DIR/

    rm -rf $AUTHORING_TOMCAT_BUILD_DIR/bin/migration
    rm -rf $AUTHORING_TOMCAT_BUILD_DIR/bin/upgrade
    rm -rf $AUTHORING_TOMCAT_BUILD_DIR/bin/crafter-deployer
    rm -rf $AUTHORING_TOMCAT_BUILD_DIR/bin/elasticsearch
    rm -rf $AUTHORING_TOMCAT_BUILD_DIR/bin/solr
    rm -rf $AUTHORING_TOMCAT_BUILD_DIR/bin/dbms
    rm -rf $AUTHORING_TOMCAT_BUILD_DIR/bin/apache-tomcat/work/*
    rm -rf $AUTHORING_TOMCAT_BUILD_DIR/bin/apache-tomcat/temp/*
    rm -rf $AUTHORING_TOMCAT_BUILD_DIR/bin/apache-tomcat/webapps/crafter-search*
    rm -rf $AUTHORING_TOMCAT_BUILD_DIR/bin/apache-tomcat/webapps/ROOT
    rm -rf $AUTHORING_TOMCAT_BUILD_DIR/bin/apache-tomcat/webapps/studio
    find $AUTHORING_TOMCAT_BUILD_DIR/bin -name "*.pid" -type f -delete

    docker build -t craftercms/authoring-tomcat $AUTHORING_TOMCAT_BUILD_DIR
}

function buildDeployer() {
    echo "------------------------------------------------------------------------"
    echo "Building Deployer Image"
    echo "------------------------------------------------------------------------"

    DEPLOYER_BUILD_DIR=$BUILD_DIR/deployer

    # Clean old build files
    rm -rf $DEPLOYER_BUILD_DIR
    mkdir -p $DEPLOYER_BUILD_DIR;

    cp -r $DOCKER_IMAGE_DIR/deployer/* $DEPLOYER_BUILD_DIR/
    cp -r $DEPLOYED_DELIVERY_BIN_DIR $DEPLOYER_BUILD_DIR/

    rm -rf $DEPLOYER_BUILD_DIR/bin/migration
    rm -rf $DEPLOYER_BUILD_DIR/bin/upgrade
    rm -rf $DEPLOYER_BUILD_DIR/bin/apache-tomcat
    rm -rf $DEPLOYER_BUILD_DIR/bin/elasticsearch
    rm -rf $DEPLOYER_BUILD_DIR/bin/solr
    find $DEPLOYER_BUILD_DIR/bin -name "*.pid" -type f -delete

    docker build -t craftercms/deployer $DEPLOYER_BUILD_DIR
}

case $1 in
    authoring)
    buildAuthoringTomcat
    buildDeployer
    ;;
    authoring-tomcat)
    buildAuthoringTomcat
    ;;
    deployer)
    buildDeployer
    ;;
esac