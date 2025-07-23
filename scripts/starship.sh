#!/bin/bash

## Install starship

if ! [ -x "$(command -v starship)" ]; then
  mkdir -p $HOME/.local/bin
  curl -sS https://starship.rs/install.sh | sh -s -- -b $HOME/.local/bin
fi
