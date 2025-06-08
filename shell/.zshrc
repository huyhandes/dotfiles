export DOTFILES="$HOME/dotfiles"
# precmd(){
#   source $HOME/.aliases
#   source $HOME/.exports
#   source $HOME/.functions
#   if [[ "$OSTYPE" == "darwin"* ]]; then

#   elif [[ "$OSTYPE" =~ ^linux ]]; then
#     source "$DOTFILES/linux/.ext_aliases"
#   fi
#   typeset -U path
#   typeset -U fpath
# }
#

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

if [[ "$OSTYPE" =~ ^linux ]]; then
  echo "External Export Temporary shutdown"
  # source "$DOTFILES/linux/.ext_exports"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  source "$DOTFILES/macos/.ext_exports"
  source "$HOME/.kube/load-k8s-config.sh"
else
  echo "No ext exports for this platform"
fi
if test -d "$HOME/opt/rye"; then
  source "$HOME/opt/rye/env"
fi
typeset -U path
typeset -U fpath

source ${ZIM_HOME}/init.zsh
fsh-alias XDG:catppuccin-macchiato -q

eval "$(starship init zsh)"
