#!/bin/bash

## Install starship

if ! [ -x "$(command -v starship)" ]; then
  STARSHIP_VERSION = "v1.21.1"
  wget "https://github.com/starship/starship/releases/download/$STARSHIP_VERSION/starship-x86_64-unknown-linux-musl.tar.gz" -O tmp
  tar xf tmp
  mkdir -p $LOCAL_BIN
  mv starship $LOCAL_BIN/

  rm tmp
fi
