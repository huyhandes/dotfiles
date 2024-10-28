#!/bin/bash

## Install rg
RG_VERSION="14.1.1"

if test ! -f $LOCAL_BIN/rg || [ $(rg --version | grep ripgrep | cut -d ' ' -f 2) != $RG_VERSION ]; then
  wget "https://github.com/BurntSushi/ripgrep/releases/download/$RG_VERSION/ripgrep-$RG_VERSION-x86_64-unknown-linux-musl.tar.gz" -O tmp
  tar xzf tmp
  rm tmp
  dir="ripgrep-$RG_VERSION-x86_64-unknown-linux-musl"

  mkdir -p $LOCAL_BIN
  cp $dir/rg $LOCAL_BIN/

  mkdir -p $LOCAL_SHARE/man/man1
  cp $dir/doc/rg.1 $LOCAL_SHARE/man/man1/

  mkdir -p $LOCAL_SHARE/zsh-completion/completions
  cp $dir/complete/_rg $LOCAL_SHARE/zsh-completion/completions/
  
  rm -r $dir
fi
