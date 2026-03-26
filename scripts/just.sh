#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

JUST_VERSION="1.46.0"

install_just() {
    local platform
    platform=$(detect_platform)

    if [[ $? -ne 0 ]]; then
        return 1
    fi

    # Map platform to just binary naming convention
    local binary_platform
    case "$platform" in
        darwin-arm64)
            binary_platform="aarch64-apple-darwin"
            ;;
        darwin-amd64)
            binary_platform="x86_64-apple-darwin"
            ;;
        linux-amd64)
            binary_platform="x86_64-unknown-linux-musl"
            ;;
        linux-arm64)
            binary_platform="aarch64-unknown-linux-musl"
            ;;
        *)
            log_error "Unsupported platform: $platform"
            return 1
            ;;
    esac

    local url="https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-${binary_platform}.tar.gz"
    local install_dir="$HOME/.local/bin"
    local temp_dir=$(mktemp -d)
    local temp_file="$temp_dir/just.tar.gz"

    log_info "Installing just $JUST_VERSION for $platform"

    if ! download_file "$url" "$temp_file"; then
        rm -rf "$temp_dir"
        return 1
    fi

    # Extract the tarball
    if ! tar -xzf "$temp_file" -C "$temp_dir"; then
        log_error "Failed to extract just archive"
        rm -rf "$temp_dir"
        return 1
    fi

    mkdir -p "$install_dir"
    mv "$temp_dir/just" "$install_dir/just"
    chmod +x "$install_dir/just"

    rm -rf "$temp_dir"

    log_success "just $JUST_VERSION installed successfully"
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists just; then
    install_just
elif command_exists just; then
    current_version=$(just --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [[ "$current_version" == "$JUST_VERSION" ]]; then
        log_success "just $JUST_VERSION is already installed"
    else
        log_warning "just is installed but version mismatch. Current: $current_version, Expected: $JUST_VERSION"
        log_info "Use --force to reinstall"
    fi
fi
