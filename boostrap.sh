#!/bin/bash

echo "Setting up ..."

if [[ "$OSTYPE" == "darwin"* ]]; then
  # Check if Homebrew is already installed
  if ! brew --version; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi
  /bin/bash macos/install.sh
elif [[ "$OSTYPE" =~ ^linux ]]; then
  /bin/bash linux/install.sh
else
  echo "This script only works on macOS and linux!"
fi

# Check for Oh My Zsh and install if we don't have it
if test ! $(which omz); then
  export ZSH="$HOME/.oh-my-zsh"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended --skip-chsh --keep-zshrc"
fi

# Add tmux plugin manager
if test ! -d $HOME/.tmux/plugins/tpm; then
  git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
fi


