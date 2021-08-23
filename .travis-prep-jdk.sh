#!/bin/bash
JDK_FILE=OpenJDK11U-jdk_x64_linux_11.0.12_7.tar.gz
JDK_URL=https://github.com/AdoptOpenJDK/openjdk11-upstream-binaries/releases/download/jdk-11.0.12%2B7/$JDK_FILE
JDK_FOLDER=openjdk-11.0.12_7

if [ -f "$HOME/downloads/OpenJDK11U-jdk_x64_linux_11.0.12_7.tar.gz" ]
then
	echo JDK already downloaded
else
	pushd .
	mkdir -p $HOME/downloads
	cd $HOME/downloads
	wget -q $JDK_URL
	popd
fi

if [ -f "$HOME/jdk/bin/java" ]
then
	echo Java already installed
else
	pushd .
	cd $HOME/downloads
	tar xvzf $JDK_FILE
	mv $HOME/downloads/$JDK_FOLDER $HOME/jdk
	popd
fi
