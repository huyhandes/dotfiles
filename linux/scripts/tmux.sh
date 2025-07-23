#!/bin/bash

## Install Tmux
if test ! -f "$HOME/.local/bin/tmux"; then
  TMUX_VERSION="3.4"
  mkdir -p $HOME/.local/bin
  cp "$DOTFILES/linux/app/tmux" "$HOME/.local/bin/tmux"
fi
