#!/bin/bash

if ! [ -x "$(command -v fnm)" ]; then
  mkdir -p $HOME/opt/fnm
  mkdir -p $HOME/.local/share/zsh/completion
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir $HOME/opt/fnm --skip-shell --force-install
  $HOME/opt/fnm/fnm completions --shell zsh > $HOME/.local/share/zsh/completions/_fnm
fi
