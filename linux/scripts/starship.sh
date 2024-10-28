#!/bin/bash

## Install starship

if ! [ -x "$(command -v starship)" ]; then
  curl -sS https://starship.rs/install.sh | sh -s -- -b $LOCAL_BIN
fi
