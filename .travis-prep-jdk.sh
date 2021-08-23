#!/bin/bash
JDK_FILE=OpenJDK11U-jdk_x64_linux_11.0.12_7.tar.gz
JDK_URL=https://github.com/AdoptOpenJDK/openjdk11-upstream-binaries/releases/download/jdk-11.0.12%2B7/$JDK_FILE
JDK_FOLDER=openjdk-11.0.12_7

if [ -f "$HOME/downloads/OpenJDK11U-jdk_x64_linux_11.0.12_7.tar.gz" ]
then
	echo JDK already downloaded
else
	echo Downloading JDK from $JDK_URL
	pushd .
	mkdir -p "$HOME/downloads"
	cd "$HOME/downloads"
	wget -q "$JDK_URL"
	popd
fi

if [ -f "$HOME/jdk/bin/java" ]
then
	echo Java already installed
else
	echo Unzipping the JDK
	pushd .
	echo Remove old JDK if present
	rm -rf "$HOME/downloads/$JDK_FOLDER"
	echo Old JDK Removed, unzip the JDK
	tar xvzf "$JDK_FILE"
	cd "$HOME"
	ln -sf "$HOME/downloads/$JDK_FOLDER" jdk
	popd
fi

ls -lh $HOME/downloads
ls -lh $HOME/jdk
