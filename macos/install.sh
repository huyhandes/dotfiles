#!/bin/bash

# Path to file containing package list
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$BASEDIR/Brewfile"
if ! brew --version; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi
brew bundle install --file="$package_file"
