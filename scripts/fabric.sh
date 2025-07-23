#!/bin/bash

## Install fabric

if ! [ -x "$(command -v fabric)" ]; then

  platform="$(uname | tr '[:upper:]' '[:lower:]')-$(uname -m)"
  mkdir -p $HOME/.local/bin
  curl -L https://github.com/danielmiessler/fabric/releases/latest/download/fabric-$platform > $HOME/.local/bin/fabric
  chmod +x $HOME/.local/bin/fabric
fi
