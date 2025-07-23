#!/bin/bash

NVIM_VERSION="v0.11.1"

if test ! -d $HOME/.local/bin/nvim-linux64 || [ $(nvim -v | grep "NVIM" | cut -d ' ' -f 2) != $NVIM_VERSION ]; then
  wget "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux-x86_64.tar.gz"
  tar xzf nvim-linux-x86_64.tar.gz
  mkdir -p $HOME/.local/bin
  mv  nvim-linux-x86_64 $HOME/.local/bin/
  rm -f $HOME/.local/bin/nvim
  ln -s $HOME/.local/bin/nvim-linux-x86_64/bin/nvim $HOME/.local/bin/nvim
  rm -r nvim-linux-x86_64*
fi
