#!/bin/bash

## Install eza
EZA_VERSION="0.20.5"

if test ! -f $LOCAL_BIN/eza || [ $(eza --version | sed -n '2p' | cut -d ' ' -f 1 | tr -d 'v') != $EZA_VERSION ]; then
  wget "https://github.com/eza-community/eza/releases/download/v$EZA_VERSION/eza_x86_64-unknown-linux-musl.tar.gz" -O tmp
  tar xf tmp

  mkdir -p $LOCAL_BIN
  cp eza $LOCAL_BIN/

  rm eza tmp

  wget "https://github.com/eza-community/eza/releases/download/v$EZA_VERSION/completions-$EZA_VERSION.tar.gz" -O tmp
  tar xf tmp
  wget "https://github.com/eza-community/eza/releases/download/v$EZA_VERSION/man-$EZA_VERSION.tar.gz" -O tmp
  tar xf tmp

  mkdir -p $LOCAL_SHARE/zsh/completions
  cp "target/completions-$EZA_VERSION/_eza" $LOCAL_SHARE/zsh/completions/
  
  mkdir -p $LOCAL_SHARE/man/man1
  cp "target/man-$EZA_VERSION/eza.1" $LOCAL_SHARE/man/man1/
  rm -r tmp target
fi
