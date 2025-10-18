#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

LAZYGIT_VERSION="0.55.1"

install_lazygit() {
    local platform
    platform=$(detect_platform)
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    local url
    local install_dir="$HOME/.local/bin"
    
    case "$platform" in
        darwin-arm64)
            url="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_darwin_arm64.tar.gz"
            ;;
        darwin-amd64)
            url="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_darwin_amd64.tar.gz"
            ;;
        linux-amd64)
            url="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_linux_x86_64.tar.gz"
            ;;
        linux-arm64)
            url="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_linux_arm64.tar.gz"
            ;;
        *)
            log_error "Unsupported platform for Lazygit: $platform"
            return 1
            ;;
    esac
    
    local temp_file=$(mktemp)
    local temp_dir=$(mktemp -d)
    
    log_info "Installing Lazygit $LAZYGIT_VERSION for $platform"
    
    if ! download_file "$url" "$temp_file"; then
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi
    
    mkdir -p "$install_dir"
    
    if ! extract_archive "$temp_file" "$temp_dir"; then
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Copy lazygit binary to install directory
    if [[ -f "$temp_dir/lazygit" ]]; then
        cp "$temp_dir/lazygit" "$install_dir/lazygit"
        chmod +x "$install_dir/lazygit"
    else
        log_error "lazygit binary not found in extracted archive"
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi
    
    rm -f "$temp_file"
    rm -rf "$temp_dir"
    
    log_success "Lazygit $LAZYGIT_VERSION installed successfully"
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists lazygit; then
    install_lazygit
elif command_exists lazygit; then
    current_version=$(lazygit --version | grep -oE 'version=[0-9.]+' | head -1 | cut -d'=' -f2)
    if [[ "$current_version" == "$LAZYGIT_VERSION" ]]; then
        log_success "Lazygit $LAZYGIT_VERSION is already installed"
    else
        log_warning "Lazygit is installed but version mismatch. Current: $current_version, Expected: $LAZYGIT_VERSION"
        log_info "Use --force to reinstall"
    fi
fi