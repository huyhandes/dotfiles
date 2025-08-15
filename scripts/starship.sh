#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

install_starship() {
    local install_dir="$HOME/.local/bin"
    local platform
    platform=$(detect_platform)
    
    log_info "Installing Starship for $platform"
    
    mkdir -p "$install_dir"
    
    # Use install script
    if command_exists curl; then
        curl -sS https://starship.rs/install.sh | sh -s -- -b "$install_dir" --yes
        if [[ $? -eq 0 ]]; then
            log_success "Starship installed successfully"
        else
            log_error "Failed to install Starship"
            return 1
        fi
    else
        log_error "curl not available for Starship installation"
        return 1
    fi
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists starship; then
    install_starship
elif command_exists starship; then
    log_success "Starship is already installed"
fi
