#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

KUBECTX_VERSION="0.9.5"
INSTALL_DIR="$HOME/.local/bin"
RELEASE_URL="https://github.com/ahmetb/kubectx/releases/download/v${KUBECTX_VERSION}"
COMPLETION_URL="https://raw.githubusercontent.com/ahmetb/kubectx/master/completion"

install_kubectx() {
    log_info "Installing kubectx/kubens v${KUBECTX_VERSION}"

    mkdir -p "$INSTALL_DIR"

    # Download bash scripts (standalone, no extraction needed)
    download_file "${RELEASE_URL}/kubectx" "$INSTALL_DIR/kubectx"
    download_file "${RELEASE_URL}/kubens" "$INSTALL_DIR/kubens"

    chmod +x "$INSTALL_DIR/kubectx" "$INSTALL_DIR/kubens"

    log_success "kubectx/kubens installed successfully"

    install_completions
}

install_completions() {
    log_info "Installing completions"

    # Bash completions
    mkdir -p "$HOME/.local/share/bash-completion/completions"
    download_file "$COMPLETION_URL/kubectx.bash" "$HOME/.local/share/bash-completion/completions/kubectx"
    download_file "$COMPLETION_URL/kubens.bash" "$HOME/.local/share/bash-completion/completions/kubens"

    # Zsh completions
    mkdir -p "$HOME/.local/share/zsh/completions"
    download_file "$COMPLETION_URL/_kubectx.zsh" "$HOME/.local/share/zsh/completions/_kubectx"
    download_file "$COMPLETION_URL/_kubens.zsh" "$HOME/.local/share/zsh/completions/_kubens"

    log_success "Completions installed"
}

if [[ "$1" == "--force" ]] || ! command_exists kubectx || ! command_exists kubens; then
    install_kubectx
elif command_exists kubectx && command_exists kubens; then
    log_success "kubectx/kubens is already installed"
fi
