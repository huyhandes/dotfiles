#!/bin/bash

## Install bat

BAT_VERSION="0.24.0"

if test ! -f $HOME/.local/bin/bat || [ $(bat --version | cut -d ' ' -f 2) != $BAT_VERSION ]; then
  wget "https://github.com/sharkdp/bat/releases/download/v$BAT_VERSION/bat-v$BAT_VERSION-x86_64-unknown-linux-musl.tar.gz" -O tmp
  # tar xzf "bat-v$BAT_VERSION-x86_64-unknown-linux-musl.tar.gz"
  tar xzf tmp
  rm tmp
  dir="bat-v$BAT_VERSION-x86_64-unknown-linux-musl"

  mkdir -p $HOME/.local/bin
  cp $dir/bat $HOME/.local/bin/

  mkdir -p $HOME/.local/share/man/man1
  cp $dir/bat.1 $HOME/.local/share/man/man1/

  mkdir -p $HOME/.local/share/zsh/completions
  cp $dir/autocomplete/bat.zsh $HOME/.local/share/zsh/completions/_bat
  
  rm -r $dir
fi
