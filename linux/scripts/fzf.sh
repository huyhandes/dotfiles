#!/bin/bash

## Install fzf
FZF_VERSION="0.55.0"

if test ! -f $HOME/.local/bin/fzf || [ $(fzf --version | cut -d ' ' -f 1) != $FZF_VERSION ]; then
  wget "https://github.com/junegunn/fzf/releases/download/v$FZF_VERSION/fzf-$FZF_VERSION-linux_amd64.tar.gz" -O tmp
  tar xf tmp
  
  mkdir -p $HOME/.local/bin
  cp fzf $HOME/.local/bin/

  rm fzf tmp
fi
