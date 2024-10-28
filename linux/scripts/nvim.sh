#!/bin/bash

NVIM_VERSION="v0.10.2"

if test ! -d $LOCAL_BIN/nvim-linux64 || [ $(nvim -v | grep "NVIM" | cut -d ' ' -f 2) != $NVIM_VERSION ]; then
  wget "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux64.tar.gz"
  tar xzf nvim-linux64.tar.gz
  mkdir -p $LOCAL_BIN
  mv nvim-linux64 $LOCAL_BIN/
  rm -f $LOCAL_BIN/nvim
  ln -s $LOCAL_BIN/nvim-linux64/bin/nvim $LOCAL_BIN/nvim
  rm -r nvim-linux64*
fi
