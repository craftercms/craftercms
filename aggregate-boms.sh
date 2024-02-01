#!/bin/bash

mkdir -p target
cyclonedx-cli merge --output-file target/bom.json --input-format json --output-format json --input-files $(find src -name 'bom.json')
