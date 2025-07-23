#!/bin/bash

## Install rg
RG_VERSION="14.1.1"

if test ! -f $HOME/.local/bin/rg || [ $(rg --version | grep ripgrep | cut -d ' ' -f 2) != $RG_VERSION ]; then
  wget "https://github.com/BurntSushi/ripgrep/releases/download/$RG_VERSION/ripgrep-$RG_VERSION-x86_64-unknown-linux-musl.tar.gz" -O tmp
  tar xzf tmp
  rm tmp
  dir="ripgrep-$RG_VERSION-x86_64-unknown-linux-musl"

  mkdir -p $HOME/.local/bin
  cp $dir/rg $HOME/.local/bin/

  mkdir -p $HOME/.local/share/man/man1
  cp $dir/doc/rg.1 $HOME/.local/share/man/man1/

  mkdir -p $HOME/.local/share/zsh/completions
  cp $dir/complete/_rg $HOME/.local/share/zsh/completions/
  
  rm -r $dir
fi
