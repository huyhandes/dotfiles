#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

ZELLIJ_VERSION="0.43.1"

install_zellij() {
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
            url="https://github.com/zellij-org/zellij/releases/download/v${ZELLIJ_VERSION}/zellij-aarch64-apple-darwin.tar.gz"
            ;;
        darwin-amd64)
            url="https://github.com/zellij-org/zellij/releases/download/v${ZELLIJ_VERSION}/zellij-x86_64-apple-darwin.tar.gz"
            ;;
        linux-amd64)
            url="https://github.com/zellij-org/zellij/releases/download/v${ZELLIJ_VERSION}/zellij-x86_64-unknown-linux-musl.tar.gz"
            ;;
        linux-arm64)
            url="https://github.com/zellij-org/zellij/releases/download/v${ZELLIJ_VERSION}/zellij-aarch64-unknown-linux-musl.tar.gz"
            ;;
        *)
            log_error "Unsupported platform for zellij: $platform"
            return 1
            ;;
    esac

    log_info "Installing zellij $ZELLIJ_VERSION for $platform"

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

    # Find the extracted binary (zellij binary directly in archive)
    local zellij_binary
    zellij_binary=$(find "$temp_dir" -name "zellij" -type f | head -1)

    if [[ -z "$zellij_binary" ]]; then
        log_error "Could not find zellij binary in extracted archive"
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi

    # Copy zellij binary to install directory
    mkdir -p "$install_dir"
    cp "$zellij_binary" "$install_dir/zellij"
    chmod +x "$install_dir/zellij"

    rm -f "$temp_file"
    rm -rf "$temp_dir"

    log_success "zellij $ZELLIJ_VERSION installed successfully"
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists zellij; then
    install_zellij
elif command_exists zellij; then
    current_version=$(zellij --version | cut -d ' ' -f 2)
    if [[ "$current_version" == "$ZELLIJ_VERSION" ]]; then
        log_success "zellij $ZELLIJ_VERSION is already installed"
    else
        log_warning "zellij is installed but version mismatch. Current: $current_version, Expected: $ZELLIJ_VERSION"
        log_info "Use --force to reinstall"
    fi
fi