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

if [ -f "$HOME/downloads/$JDK_FOLDER/bin/java" ]
then
	echo JDK is present and unzipped, must check symlink
else
	echo Unzipping JDK
	pushd .
	cd "$HOME/downloads"
	tar xvzf "$JDK_FILE"
	popd
fi

if [ -f "$HOME/jdk" ]
then
	echo JDK symlink is present
else
	echo Creating JDK symlink
	pushd .
	cd "$HOME"
	ln -sf "$HOME/downloads/$JDK_FOLDER" jdk
	popd
fi
