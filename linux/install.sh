#!/bin/bash

# Path to file containing package list
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$BASEDIR/packages.txt" 

echo "Updating package list..."
sudo apt-get update

echo "Installing packages..."

# Read packages from file 
while IFS= read -r package; do

  echo "Installing $package"
  sudo apt-get -y install $package

done < "$package_file"

# Install from github release

mkdir -p "$BASEDIR/tmp"
mkdir -p "$HOME/opt"
cd "$BASEDIR/tmp"

## Install bat - require root
if test ! -f "$HOME/opt/bat/bat"; then
  BAT_VERSION="0.24.0"
  wget "https://github.com/sharkdp/bat/releases/download/v$BAT_VERSION/bat-v$BAT_VERSION-x86_64-unknown-linux-musl.tar.gz"
  tar xzf "bat-v$BAT_VERSION-x86_64-unknown-linux-musl.tar.gz"
  mv "bat-v$BAT_VERSION-x86_64-unknown-linux-musl" "$HOME/opt/bat"
fi

## Install FZF

if test ! -f "$HOME/.local/bin/fzf"; then
  FZF_VERSION="0.53.0"
  wget "https://github.com/junegunn/fzf/releases/download/$FZF_VERSION/fzf-$FZF_VERSION-linux_amd64.tar.gz"
  tar xzf "fzf-$FZF_VERSION-linux_amd64.tar.gz"
  mv fzf "$HOME/.local/bin"
fi

## Install NeoVim

if test ! -d "$HOME/opt/nvim-linux64"; then
  NVIM_VERSION="v0.10.0"
  wget "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux64.tar.gz"
  tar xzf nvim-linux64.tar.gz
  mv nvim-linux64 "$HOME/opt/"
fi

# Install Tmux
if test ! -f "$HOME/.local/bin/tmux"; then
  TMUX_VERSION="3.4"
  cp "$BASEDIR/app/tmux" "$HOME/.local/bin/tmux"
fi

cd $BASEDIR
rm -rf "$BASEDIR/tmp"

## Install xh

if ! [ -x "$(command -v xh)" ]; then
  curl -sfL https://raw.githubusercontent.com/ducaale/xh/master/install.sh | XH_BINDIR="$HOME/.local/bin" sh
fi

## Install zoxide

if ! [ -x "$(command -v zoxide)" ]; then
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

## Install starship

if ! [ -x "$(command -v starship)" ]; then
  curl -sS https://starship.rs/install.sh | sh
fi
