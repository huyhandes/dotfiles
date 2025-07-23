#!/bin/bash

## Install vimongo

if ! [ -x "$(command -v vi-mongo)" ]; then
  VI_MONGO_VERSION=0.1.20
  platform="$(uname)_$(uname -m)"
  curl -LO https://github.com/kopecmaciej/vi-mongo/releases/download/v$VI_MONGO_VERSION/vi-mongo_$platform.tar.gz
  tar -xzf vi-mongo_$platform.tar.gz
  chmod +x vi-mongo
  mkdir -p $HOME/.local/bin
  mv vi-mongo $HOME/.local/bin
  rm vi-mongo_$platform.tar.gz
fi
