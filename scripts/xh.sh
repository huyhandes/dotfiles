#!/bin/bash

if ! [ -x "$(command -v xh)" ]; then
  mkdir -p $HOME/.local/bin
  curl -sfL https://raw.githubusercontent.com/ducaale/xh/master/install.sh | XH_BINDIR="$HOME/.local/bin" sh
fi
