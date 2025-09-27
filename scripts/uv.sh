#!/bin/bash

if ! [ -x "$(command -v uv)" ]; then
  curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR="$HOME/opt/uv" sh

  mkdir -p $HOME/.local/share/zsh/completions
  uv generate-shell-completion zsh > $HOME/.local/share/zsh/completions/_uv
fi
