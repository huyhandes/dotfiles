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

# Add tmux plugin manager
if test ! -d $HOME/.tmux/plugins/tpm; then
  git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
fi
