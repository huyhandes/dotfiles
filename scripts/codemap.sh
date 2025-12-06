#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

CODEMAP_VERSION="3.0.3"

install_codemap() {
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
        darwin-amd64)
            url="https://github.com/JordanCoin/codemap/releases/download/v${CODEMAP_VERSION}/codemap_${CODEMAP_VERSION}_darwin_amd64.tar.gz"
            ;;
        darwin-arm64)
            url="https://github.com/JordanCoin/codemap/releases/download/v${CODEMAP_VERSION}/codemap_${CODEMAP_VERSION}_darwin_arm64.tar.gz"
            ;;
        linux-amd64)
            url="https://github.com/JordanCoin/codemap/releases/download/v${CODEMAP_VERSION}/codemap_${CODEMAP_VERSION}_linux_amd64.tar.gz"
            ;;
        linux-arm64)
            url="https://github.com/JordanCoin/codemap/releases/download/v${CODEMAP_VERSION}/codemap_${CODEMAP_VERSION}_linux_arm64.tar.gz"
            ;;
        *)
            log_error "Unsupported platform for codemap: $platform"
            return 1
            ;;
    esac

    log_info "Installing codemap $CODEMAP_VERSION for $platform"

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

    # Copy codemap binary to install directory
    if [[ -f "$temp_dir/codemap" ]]; then
        mkdir -p "$install_dir"
        cp "$temp_dir/codemap" "$install_dir/codemap"
        chmod +x "$install_dir/codemap"
    else
        log_error "codemap binary not found in extracted archive"
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi

    rm -f "$temp_file"
    rm -rf "$temp_dir"

    log_success "codemap $CODEMAP_VERSION installed successfully"
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists codemap; then
    install_codemap
elif command_exists codemap; then
    log_success "codemap is already installed"
    log_info "Use --force to reinstall if needed"
fi