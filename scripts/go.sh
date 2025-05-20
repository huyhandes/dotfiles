#!/bin/bash
GO_VERSION="1.24.2"

if ! [ -x "$(command -v go)" ]; then
  wget "https://go.dev/dl/go$GO_VERSION.darwin-arm64.tar.gz" -O tmp
  tar xzf tmp
  mkdir -p $HOME/opt
  mv go $HOME/opt/
  rm tmp
fi
