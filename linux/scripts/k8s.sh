#!/bin/bash

## Install kubectl

KUBECTL_VERSION="1.31.2"

if test ! -f $HOME/.local/bin/kubectl || [ $(kubectl version --client --short 2>/dev/null | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 | cut -c2-) != $KUBECTL_VERSION ]; then
  wget "https://dl.k8s.io/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl" -O tmp
  
  mkdir -p $HOME/.local/bin
  cp tmp $HOME/.local/bin/kubectl
  chmod +x $HOME/.local/bin/kubectl
  rm tmp

  # Install kubectl bash completion
  mkdir -p $HOME/.local/share/bash-completion/completions
  $HOME/.local/bin/kubectl completion bash > $HOME/.local/share/bash-completion/completions/kubectl

  # Install kubectl zsh completion
  mkdir -p $HOME/.local/share/zsh/completions
  $HOME/.local/bin/kubectl completion zsh > $HOME/.local/share/zsh/completions/_kubectl
  
  echo "kubectl $KUBECTL_VERSION installed successfully"

