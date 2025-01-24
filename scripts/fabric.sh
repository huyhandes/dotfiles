#!/bin/bash

## Install fabric

if ! [ -x "$(command -v fabric)" ]; then

  platform="$(uname | tr '[:upper:]' '[:lower:]')-$(uname -m)"
  curl -L https://github.com/danielmiessler/fabric/releases/latest/download/fabric-$platform > $LOCAL_BIN/fabric
  chmod +x $LOCAL_BIN/fabric
fi
