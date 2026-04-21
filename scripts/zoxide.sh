#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

install_zoxide() {
    local platform
    platform=$(detect_platform)

    log_info "Installing zoxide for $platform"

    if command_exists curl; then
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
        if [[ $? -eq 0 ]]; then
            log_success "zoxide installed successfully"
        else
            log_error "Failed to install zoxide"
            return 1
        fi
    else
        log_error "curl not available for zoxide installation"
        return 1
    fi
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists zoxide; then
    install_zoxide
elif command_exists zoxide; then
    log_success "zoxide is already installed"
fi
