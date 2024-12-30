#!/bin/bash

if ! [ -x "$(command -v rye)" ]; then
  curl -sSf https://rye.astral.sh/get | RYE_VERSION='0.42.0' RYE_INSTALL_OPTION='--yes' \
  RYE_TOOLCHAIN_VERSION='cpython@3.12.7' bash

  cmd='source $HOME/opt/rye/env'

  eval $cmd

  mkdir -p $LOCAL_SHARE/zsh/completions
  rye self completion -s zsh > $LOCAL_SHARE/zsh/completions/_rye

  rye config --set-bool behavior.use-uv=true
  rye config --set-bool behavior.global-python=true
fi
