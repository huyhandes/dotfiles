#!/bin/bash

# Path to file containing package list
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Install from github release
echo "Working on $BASEDIR..."

cd $BASEDIR/scripts

for script in *; do
  echo "Running $script"
  ./$script
done
