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
	echo ls downloads
	ls $HOME/downloads
	cd "$HOME/downloads"
	wget -q "$JDK_URL"
	echo ls downloads
	ls $HOME/downloads
	popd
fi

if [ -f "$HOME/jdk/bin/java" ]
then
	echo Java already installed
else
	echo Unzipping the JDK
	pushd .
	cd "$HOME/downloads"
	echo ls downloads
	ls -lh
	ls -lh $JDK_FOLDER
	rm -rf "$HOME/downloads/$JDK_FOLDER"
	tar xzf "$JDK_FILE"
	cd $HOME
	mkdir -p jdk
	cd jdk
	echo ls jdk
	ls -lh
	echo Moving the into JDK home
	echo mv "$HOME/downloads/$JDK_FOLDER/*" .
	echo ls "$HOME/downloads/$JDK_FOLDER/*"
	ls "$HOME/downloads/$JDK_FOLDER/*"
	mv "$HOME/downloads/$JDK_FOLDER/*" .
	popd
fi

ls -lh $HOME/downloads
ls -lh $HOME/jdk
