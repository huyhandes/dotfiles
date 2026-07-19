#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

install_herdr() {
    local install_dir="$HOME/.local/bin"
    local platform
    platform=$(detect_platform)

    log_info "Installing herdr for $platform"

    mkdir -p "$install_dir"

    # herdr's installer needs curl + awk; it honors HERDR_INSTALL_DIR
    # (defaults to ~/.local/bin, but we set it explicitly for clarity)
    if command_exists curl; then
        if curl -fsSL https://herdr.dev/install.sh | HERDR_INSTALL_DIR="$install_dir" sh; then
            log_success "herdr installed successfully"
        else
            log_error "Failed to install herdr"
            return 1
        fi
    else
        log_error "curl not available for herdr installation"
        return 1
    fi
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists herdr; then
    install_herdr
elif command_exists herdr; then
    log_success "herdr is already installed"
fi
