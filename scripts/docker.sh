#!/bin/bash

mkdir -p $HOME/.local/share/zsh/completions

wget https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker -O $HOME/.local/share/zsh/completions/_docker
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/plugins/docker-compose/_docker-compose -O $HOME/.local/share/zsh/completions/_docker-compose
