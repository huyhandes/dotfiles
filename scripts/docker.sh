#!/bin/bash

mkdir -p $LOCAL_SHARE/zsh/completions

wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/plugins/docker/completions/_docker -O $LOCAL_SHARE/zsh/completions/_docker
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/refs/heads/master/plugins/docker-compose/_docker-compose -O $LOCAL_SHARE/zsh/completions/_docker-compose
