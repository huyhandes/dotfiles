#!/bin/bash

## Install fzf
FZF_VERSION="0.55.0"

if test ! -f $LOCAL_BIN/fzf || [ $(fzf --version | cut -d ' ' -f 1) != $FZF_VERSION ]; then
  wget "https://github.com/junegunn/fzf/releases/download/v$FZF_VERSION/fzf-$FZF_VERSION-linux_amd64.tar.gz" -O tmp
  tar xf tmp
  
  mkdir -p $LOCAL_BIN
  cp fzf $LOCAL_BIN/

  rm fzf tmp
fi
