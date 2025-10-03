#!/bin/bash

## Install yazi

YAZI_VERSION="25.5.31"

if test ! -f $HOME/.local/bin/yazi || [ $(yazi --version | cut -d ' ' -f 2) != $YAZI_VERSION ]; then
  wget "https://github.com/sxyazi/yazi/releases/download/v$YAZI_VERSION/yazi-x86_64-unknown-linux-musl.zip" -O tmp
  unzip tmp
  rm tmp
  dir="yazi-x86_64-unknown-linux-musl"

  mkdir -p $HOME/.local/bin
  cp $dir/ya $HOME/.local/bin/
  cp $dir/yazi $HOME/.local/bin/

  mkdir -p $$HOME/.local/share/zsh/completions
  cp $dir/completions/_ya $$HOME/.local/share/zsh/completions/_ya
  cp $dir/completions/_yazi $$HOME/.local/share/zsh/completions/_yazi
  
  rm -r $dir
fi
