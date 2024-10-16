#!/bin/bash
## Install zoxide

if ! [ -x "$(command -v zoxide)" ]; then
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi
