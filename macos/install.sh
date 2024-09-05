#!/bin/bash

# Path to file containing package list
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$BASEDIR/Brewfile"

brew bundle install --file="$package_file"
