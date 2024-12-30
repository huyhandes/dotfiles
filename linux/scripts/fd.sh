#!/bin/bash

## Install fd
FD_VERSION="10.2.0"
if test ! -f $LOCAL_BIN/fd || [ $(fd --version | cut -d ' ' -f 2) != $FD_VERSION ]; then
  wget "https://github.com/sharkdp/fd/releases/download/v$FD_VERSION/fd-v$FD_VERSION-x86_64-unknown-linux-musl.tar.gz" -O tmp
  tar xzf tmp
  rm tmp
  dir="fd-v$FD_VERSION-x86_64-unknown-linux-musl"

  mkdir -p $LOCAL_BIN
  cp $dir/fd $LOCAL_BIN/

  mkdir -p $LOCAL_SHARE/man/man1
  cp $dir/fd.1 $LOCAL_SHARE/man/man1/

  mkdir -p $LOCAL_SHARE/zsh/completions
  cp $dir/autocomplete/_fd $LOCAL_SHARE/zsh/completions/_fd
  
  rm -r $dir
fi
