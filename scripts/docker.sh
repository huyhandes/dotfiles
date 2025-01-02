#!/bin/bash

mkdir -p $LOCAL_SHARE/zsh/completions

wget https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker -O $LOCAL_SHARE/zsh/completions/_docker
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/plugins/docker-compose/_docker-compose -O $LOCAL_SHARE/zsh/completions/_docker-compose
