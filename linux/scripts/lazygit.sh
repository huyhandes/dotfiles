#!/bin/bash

## Install lazygit
LAZYGIT_VERSION="0.44.0"

if test ! -f $HOME/.local/bin/lazygit || [ $(lazygit --version | cut -d',' -f4 | cut -d'=' -f2) != $LAZYGIT_VERSION ]; then
  wget "https://github.com/jesseduffield/lazygit/releases/download/v$LAZYGIT_VERSION/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" -O tmp
  mkdir lazygit 
  tar xf tmp -C lazygit
  
  mkdir -p $HOME/.local/bin
  cp lazygit/lazygit $HOME/.local/bin/

  rm -r lazygit tmp
fi
