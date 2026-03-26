#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

install_cship() {
    local install_dir="$HOME/.local/bin"
    local platform
    platform=$(detect_platform)
    
    log_info "Installing Cship for $platform"
    
    mkdir -p "$install_dir"
    
    # Use install script
    if command_exists curl; then
        curl -fsSL https://cship.dev/install.sh | bash
        if [[ $? -eq 0 ]]; then
            log_success "Cship installed successfully"
        else
            log_error "Failed to install Cship"
            return 1
        fi
    else
        log_error "curl not available for Cship installation"
        return 1
    fi
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists cship; then
    install_cship
elif command_exists cship; then
    log_success "Cship is already installed"
fi
