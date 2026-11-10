#!/bin/bash

if ! [ -x "$(command -v uv)" ]; then
  curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR="$HOME/opt/uv" sh

  mkdir -p $HOME/.local/share/zsh/completions
  # ~/.exports puts ~/opt/uv on PATH, but it is not loaded in this run: call the binary by path
  "$HOME/opt/uv/uv" generate-shell-completion zsh > $HOME/.local/share/zsh/completions/_uv
fi
