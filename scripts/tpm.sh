#!/bin/bash

# Add tmux plugin manager
if test ! -d $HOME/.tmux/plugins/tpm; then
  git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
fi
