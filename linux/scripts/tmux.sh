#!/bin/bash

## Install Tmux
if test ! -f "$LOCAL_BIN/tmux"; then
  TMUX_VERSION="3.4"
  cp "$DOTFILES/linux/app/tmux" "$LOCAL_BIN/tmux"
fi
