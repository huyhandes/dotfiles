#!/bin/bash

## Install yazi

YAZI_VERSION="25.5.31"

if test ! -f $LOCAL_BIN/yazi || [ $(yazi --version | cut -d ' ' -f 2) != $YAZI_VERSION ]; then
  wget "https://github.com/sxyazi/yazi/releases/download/v$YAZI_VERSION/yazi-x86_64-unknown-linux-musl.zip" -O tmp
  unzip tmp
  rm tmp
  dir="yazi-x86_64-unknown-linux-musl"

  mkdir -p $LOCAL_BIN
  cp $dir/ya $LOCAL_BIN/
  cp $dir/yazi $LOCAL_BIN/

  mkdir -p $LOCAL_SHARE/zsh/completions
  cp $dir/completions/_ya $LOCAL_SHARE/zsh/completions/_ya
  cp $dir/completions/_yazi $LOCAL_SHARE/zsh/completions/_yazi
  
  rm -r $dir
fi
