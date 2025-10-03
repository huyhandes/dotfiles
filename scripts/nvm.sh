#!/bin/bash

if ! [ -x "$(command -v npm)" ]; then
  mkdir -p $HOME/opt/nvm
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | NVM_DIR=$HOME/opt/nvm bash
fi
