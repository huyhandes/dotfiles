#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

NEOVIM_VERSION="v0.11.4"

install_neovim() {
    local platform
    platform=$(detect_platform)
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    local url
    local install_dir
    local symlink_source
    local symlink_target="$HOME/.local/bin/nvim"
    
    case "$platform" in
        darwin-arm64)
            url="https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-macos-arm64.tar.gz"
            install_dir="$HOME/.local/bin/nvim-macos-arm64"
            symlink_source="$install_dir/bin/nvim"
            ;;
        darwin-amd64)
            url="https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-macos-x86_64.tar.gz"
            install_dir="$HOME/.local/bin/nvim-macos-x86_64"
            symlink_source="$install_dir/bin/nvim"
            ;;
        linux-amd64)
            url="https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux-x86_64.tar.gz"
	    install_dir="$HOME/.local/bin/nvim-linux-x86_64"
            symlink_source="$install_dir/bin/nvim"
            ;;
        linux-arm64)
            url="https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux-arm64.tar.gz"
            install_dir="$HOME/.local/bin/nvim-linux-arm64"
            symlink_source="$install_dir/bin/nvim"
            ;;
        *)
            log_error "Unsupported platform for Neovim: $platform"
            return 1
            ;;
    esac
    
    local temp_file=$(mktemp)
    
    log_info "Installing Neovim $NEOVIM_VERSION for $platform"
    
    if ! download_file "$url" "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi
    
    # Remove existing installation
    if [[ -d "$install_dir" ]]; then
        log_info "Removing existing Neovim installation"
        rm -rf "$install_dir"
    fi
    
    mkdir -p "$(dirname "$install_dir")"
    
    if ! extract_archive "$temp_file" "$(dirname "$install_dir")"; then
        rm -f "$temp_file"
        return 1
    fi
    
    rm -f "$temp_file"
    
    # Create symlink
    create_symlink_safe "$symlink_source" "$symlink_target"
    
    log_success "Neovim $NEOVIM_VERSION installed successfully"
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists nvim; then
    install_neovim
elif command_exists nvim; then
    current_version=$(nvim --version | head -1 | grep -oE 'v[0-9.]+' | head -1)
    if [[ "$current_version" == "$NEOVIM_VERSION" ]]; then
        log_success "Neovim $NEOVIM_VERSION is already installed"
    else
        log_warning "Neovim is installed but version mismatch. Current: $current_version, Expected: $NEOVIM_VERSION"
        log_info "Use --force to reinstall"
    fi
fi
