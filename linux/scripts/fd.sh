#!/bin/bash

## Install fd
FD_VERSION="10.2.0"
if test ! -f $HOME/.local/bin/fd || [ $(fd --version | cut -d ' ' -f 2) != $FD_VERSION ]; then
  wget "https://github.com/sharkdp/fd/releases/download/v$FD_VERSION/fd-v$FD_VERSION-x86_64-unknown-linux-musl.tar.gz" -O tmp
  tar xzf tmp
  rm tmp
  dir="fd-v$FD_VERSION-x86_64-unknown-linux-musl"

  mkdir -p $HOME/.local/bin
  cp $dir/fd $HOME/.local/bin/

  mkdir -p $HOME/.local/share/man/man1
  cp $dir/fd.1 $HOME/.local/share/man/man1/

  mkdir -p $HOME/.local/share/zsh/completions
  cp $dir/autocomplete/_fd $HOME/.local/share/zsh/completions/_fd
  
  rm -r $dir
fi
