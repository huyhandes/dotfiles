#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

FZF_VERSION="0.66.0"

install_fzf() {
    local platform
    platform=$(detect_platform)

    if [[ $? -ne 0 ]]; then
        return 1
    fi

    local url
    local temp_file=$(mktemp)
    local temp_dir=$(mktemp -d)
    local install_dir="$HOME/.local/bin"

    case "$platform" in
        darwin-arm64)
            url="https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-darwin_arm64.tar.gz"
            ;;
        darwin-amd64)
            url="https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-darwin_amd64.tar.gz"
            ;;
        linux-amd64)
            url="https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz"
            ;;
        linux-arm64)
            url="https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_arm64.tar.gz"
            ;;
        *)
            log_error "Unsupported platform for fzf: $platform"
            return 1
            ;;
    esac

    log_info "Installing fzf $FZF_VERSION for $platform"

    if ! download_file "$url" "$temp_file"; then
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi

    if ! extract_archive "$temp_file" "$temp_dir"; then
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi

    # Copy fzf binary to install directory
    if [[ -f "$temp_dir/fzf" ]]; then
        mkdir -p "$install_dir"
        cp "$temp_dir/fzf" "$install_dir/fzf"
        chmod +x "$install_dir/fzf"
    else
        log_error "fzf binary not found in extracted archive"
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi

    rm -f "$temp_file"
    rm -rf "$temp_dir"

    log_success "fzf $FZF_VERSION installed successfully"
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists fzf; then
    install_fzf
elif command_exists fzf; then
    current_version=$(fzf --version | cut -d ' ' -f 1)
    if [[ "$current_version" == "$FZF_VERSION" ]]; then
        log_success "fzf $FZF_VERSION is already installed"
    else
        log_warning "fzf is installed but version mismatch. Current: $current_version, Expected: $FZF_VERSION"
        log_info "Use --force to reinstall"
    fi
fi