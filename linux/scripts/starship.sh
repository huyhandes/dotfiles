#!/bin/bash

## Install starship

if ! [ -x "$(command -v starship)" ]; then
  STARSHIP_VERSION="v1.21.1"
  curl -sS https://starship.rs/install.sh | sh -s -- -b $LOCAL_BIN
fi
