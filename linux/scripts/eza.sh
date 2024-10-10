#!/bin/bash

## Install fzf - require root
if test ! -f $LOCAL_BIN/eza; then
  EZA_VERSION="0.20.0"
  wget "https://github.com/eza-community/eza/releases/download/v$EZA_VERSION/eza_x86_64-unknown-linux-musl.tar.gz" -O tmp
  tar xf tmp

  mkdir -p $LOCAL_BIN
  cp eza $LOCAL_BIN/

  rm eza tmp

  wget "https://github.com/eza-community/eza/releases/download/v$EZA_VERSION/completions-$EZA_VERSION.tar.gz" -O tmp
  tar xf tmp
  wget "https://github.com/eza-community/eza/releases/download/v$EZA_VERSION/man-$EZA_VERSION.tar.gz" -O tmp
  tar xf tmp

  mkdir -p $LOCAL_SHARE/zsh-completion/completions
  cp "target/completions-$EZA_VERSION/_eza" $LOCAL_SHARE/zsh-completion/completions/
  
  mkdir -p $LOCAL_SHARE/man/man1
  cp "target/man-$EZA_VERSION/eza.1" $LOCAL_SHARE/man/man1/
  rm -r tmp target
fi
