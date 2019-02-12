#!/bin/bash

DOCKER_IMAGE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
DEPLOYED_AUTHORING_BIN_DIR=$( cd "$DOCKER_IMAGE_DIR/../../crafter-authoring/bin" && pwd )
DEPLOYED_DELIVERY_BIN_DIR=$( cd "$DOCKER_IMAGE_DIR/../../crafter-delivery/bin" && pwd )
BUILD_DIR=$DOCKER_IMAGE_DIR/build

function buildAuthoringTomcat() {
    echo "------------------------------------------------------------------------"
    echo "Building Authoring Tomcat Image"
    echo "------------------------------------------------------------------------"

    AUTHORING_TOMCAT_BUILD_DIR=$BUILD_DIR/authoring/tomcat

    # Clean old build files
    rm -rf $AUTHORING_TOMCAT_BUILD_DIR
    mkdir -p $AUTHORING_TOMCAT_BUILD_DIR

    cp -r $DOCKER_IMAGE_DIR/authoring/tomcat/* $AUTHORING_TOMCAT_BUILD_DIR/
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

    docker build -t craftercms/authoring_tomcat $AUTHORING_TOMCAT_BUILD_DIR
}

function buildDeliveryTomcat() {
    echo "------------------------------------------------------------------------"
    echo "Building Delivery Tomcat Image"
    echo "------------------------------------------------------------------------"

    DELIVERY_TOMCAT_BUILD_DIR=$BUILD_DIR/delivery/tomcat

    # Clean old build files
    rm -rf $DELIVERY_TOMCAT_BUILD_DIR
    mkdir -p $DELIVERY_TOMCAT_BUILD_DIR

    cp -r $DOCKER_IMAGE_DIR/delivery/tomcat/* $DELIVERY_TOMCAT_BUILD_DIR/
    cp -r $DEPLOYED_DELIVERY_BIN_DIR $DELIVERY_TOMCAT_BUILD_DIR/

    rm -rf $DELIVERY_TOMCAT_BUILD_DIR/bin/migration
    rm -rf $DELIVERY_TOMCAT_BUILD_DIR/bin/upgrade
    rm -rf $DELIVERY_TOMCAT_BUILD_DIR/bin/crafter-deployer
    rm -rf $DELIVERY_TOMCAT_BUILD_DIR/bin/elasticsearch
    rm -rf $DELIVERY_TOMCAT_BUILD_DIR/bin/solr
    rm -rf $DELIVERY_TOMCAT_BUILD_DIR/bin/apache-tomcat/work/*
    rm -rf $DELIVERY_TOMCAT_BUILD_DIR/bin/apache-tomcat/temp/*
    rm -rf $DELIVERY_TOMCAT_BUILD_DIR/bin/apache-tomcat/webapps/crafter-search*
    rm -rf $DELIVERY_TOMCAT_BUILD_DIR/bin/apache-tomcat/webapps/ROOT
    rm $DELIVERY_TOMCAT_BUILD_DIR/bin/init-site*
    rm $DELIVERY_TOMCAT_BUILD_DIR/bin/remove-site*
    find $DELIVERY_TOMCAT_BUILD_DIR/bin -name "*.pid" -type f -delete

    docker build -t craftercms/delivery_tomcat $DELIVERY_TOMCAT_BUILD_DIR
}

function buildDisklessS3DeliveryTomcat() {
    buildDeliveryTomcat

    echo "------------------------------------------------------------------------"
    echo "Building Diskless S3 Delivery Tomcat Image"
    echo "------------------------------------------------------------------------" 

    docker build -t craftercms/diskless_s3_delivery_tomcat $DOCKER_IMAGE_DIR/diskless/s3/delivery/tomcat
}

function buildDeployer() {
    echo "------------------------------------------------------------------------"
    echo "Building Deployer Image"
    echo "------------------------------------------------------------------------"

    DEPLOYER_BUILD_DIR=$BUILD_DIR/deployer

    # Clean old build files
    rm -rf $DEPLOYER_BUILD_DIR
    mkdir -p $DEPLOYER_BUILD_DIR

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
    delivery)
    buildDeliveryTomcat
    buildDeployer
    ;;    
    diskless_s3_delivery)
    buildDisklessS3DeliveryTomcat
    ;;   
esac