#!/bin/bash

## Install lazygit - require root
if test ! -f $LOCAL_BIN/lazygit; then
  LAZYGIT_VERSION="0.44.0"
  wget "https://github.com/jesseduffield/lazygit/releases/download/v$LAZYGIT_VERSION/lazygit_$LAZYGIT_VERSION_Linux_x86_64.tar.gz" -O tmp
  mkdir lazygit 
  tar xf tmp -C lazygit
  
  mkdir -p $LOCAL_BIN
  cp lazygit/lazygit $LOCAL_BIN/

  rm -r lazygit tmp
fi
