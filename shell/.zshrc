export DOTFILES="$HOME/dotfiles"

source $HOME/.aliases
source $HOME/.exports
source $HOME/.functions

export ZIM_HOME=$HOME/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  source "$DOTFILES/macos/.ext_exports"
fi

# Clean up duplicate paths
typeset -U path
typeset -U fpath

source ${ZIM_HOME}/init.zsh
fsh-alias XDG:catppuccin-macchiato -q

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

eval "$(starship init zsh)"

