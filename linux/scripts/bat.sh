#!/bin/bash

## Install bat - require root
if test ! -f $LOCAL_BIN/bat; then
  BAT_VERSION="0.24.0"
  wget "https://github.com/sharkdp/bat/releases/download/v$BAT_VERSION/bat-v$BAT_VERSION-x86_64-unknown-linux-musl.tar.gz"
  tar xzf "bat-v$BAT_VERSION-x86_64-unknown-linux-musl.tar.gz"
  dir = "bat-v$BAT_VERSION-x86_64-unknown-linux-musl"

  mkdir -p $LOCAL_BIN
  cp $dir/bat/bat $LOCAL_BIN/

  mkdir -p $LOCAL_SHARE/man/man1
  cp $dir/bat/bat.1 $LOCAL_SHARE/man/man1/

  mkdir -p $LOCAL_SHARE/zsh-completion/completions
  cp $dir/autocomplete/bat.zsh $LOCAL_SHARE/zsh-completion/completions
  
  rm $dir
fi
