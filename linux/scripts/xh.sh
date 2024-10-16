#!/bin/bash

if ! [ -x "$(command -v xh)" ]; then
  curl -sfL https://raw.githubusercontent.com/ducaale/xh/master/install.sh | XH_BINDIR="$LOCAL_BIN" sh
fi
