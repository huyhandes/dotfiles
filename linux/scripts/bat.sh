#!/bin/bash

## Install bat

BAT_VERSION="0.24.0"

if test ! -f $LOCAL_BIN/bat || [ $(bat --version | cut -d ' ' -f 2) != $BAT_VERSION ]; then
  wget "https://github.com/sharkdp/bat/releases/download/v$BAT_VERSION/bat-v$BAT_VERSION-x86_64-unknown-linux-musl.tar.gz" -O tmp
  # tar xzf "bat-v$BAT_VERSION-x86_64-unknown-linux-musl.tar.gz"
  tar xzf tmp
  rm tmp
  dir="bat-v$BAT_VERSION-x86_64-unknown-linux-musl"

  mkdir -p $LOCAL_BIN
  cp $dir/bat $LOCAL_BIN/

  mkdir -p $LOCAL_SHARE/man/man1
  cp $dir/bat.1 $LOCAL_SHARE/man/man1/

  mkdir -p $LOCAL_SHARE/zsh/completions
  cp $dir/autocomplete/bat.zsh $LOCAL_SHARE/zsh/completions/_bat
  
  rm -r $dir
fi
