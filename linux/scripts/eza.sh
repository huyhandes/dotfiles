#!/bin/bash

## Install eza
EZA_VERSION="0.20.5"

if test ! -f $HOME/.local/bin/eza || [ $(eza --version | sed -n '2p' | cut -d ' ' -f 1 | tr -d 'v') != $EZA_VERSION ]; then
  wget "https://github.com/eza-community/eza/releases/download/v$EZA_VERSION/eza_x86_64-unknown-linux-musl.tar.gz" -O tmp
  tar xf tmp

  mkdir -p $HOME/.local/bin
  cp eza $HOME/.local/bin/

  rm eza tmp

  wget "https://github.com/eza-community/eza/releases/download/v$EZA_VERSION/completions-$EZA_VERSION.tar.gz" -O tmp
  tar xf tmp
  wget "https://github.com/eza-community/eza/releases/download/v$EZA_VERSION/man-$EZA_VERSION.tar.gz" -O tmp
  tar xf tmp

  mkdir -p $HOME/.local/share/zsh/completions
  cp "target/completions-$EZA_VERSION/_eza" $HOME/.local/share/zsh/completions/
  
  mkdir -p $HOME/.local/share/man/man1
  cp "target/man-$EZA_VERSION/eza.1" $HOME/.local/share/man/man1/
  rm -r tmp target
fi
