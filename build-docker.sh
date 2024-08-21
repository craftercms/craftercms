#!/bin/bash

function run() {
	case $# in
		1)
			main $@
		;;
		*)
			echo "usage: $0 <version>"
		;;
	esac
}

function main() {
	local version=$1
	./gradlew buildMainImages -PpushDockerImages=true -PtagDockerImages=latest -PdockerTag="$version"
}

run $@
