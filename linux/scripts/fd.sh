#!/bin/bash

## Install fd - require root
if test ! -f $LOCAL_BIN/fd; then
  FD_VERSION="v10.2.0"
  wget "https://github.com/sharkdp/fd/releases/download/$FD_VERSION/fd-$FD_VERSION-x86_64-unknown-linux-musl.tar.gz" -O tmp
  tar xzf tmp
  rm tmp
  dir="fd-$FD_VERSION-x86_64-unknown-linux-musl"

  mkdir -p $LOCAL_BIN
  cp $dir/fd $LOCAL_BIN/

  mkdir -p $LOCAL_SHARE/man/man1
  cp $dir/fd.1 $LOCAL_SHARE/man/man1/

  mkdir -p $LOCAL_SHARE/zsh-completion/completions
  cp $dir/autocomplete/_fd $LOCAL_SHARE/zsh-completion/completions/_fd
  
  rm -r $dir
fi
