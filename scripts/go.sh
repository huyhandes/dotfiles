#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

GO_VERSION="1.25.3"

install_go() {
    local platform
    platform=$(detect_platform)
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    local url="https://go.dev/dl/go${GO_VERSION}.${platform}.tar.gz"
    local install_dir="$HOME/opt"
    local temp_file=$(mktemp)
    
    log_info "Installing Go $GO_VERSION for $platform"
    
    if ! download_file "$url" "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi
    
    mkdir -p "$install_dir"
    
    # Remove existing Go installation
    if [[ -d "$install_dir/go" ]]; then
        log_info "Removing existing Go installation"
        rm -rf "$install_dir/go"
    fi
    
    if ! extract_archive "$temp_file" "$install_dir"; then
        rm -f "$temp_file"
        return 1
    fi
    
    rm -f "$temp_file"
    log_success "Go $GO_VERSION installed successfully"
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists go; then
    install_go
elif command_exists go; then
    current_version=$(go version | grep -oE 'go[0-9.]+' | head -1)
    if [[ "$current_version" == "go$GO_VERSION" ]]; then
        log_success "Go $GO_VERSION is already installed"
    else
        log_warning "Go is installed but version mismatch. Current: $current_version, Expected: go$GO_VERSION"
        log_info "Use --force to reinstall"
    fi
fi
