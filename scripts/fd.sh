#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

FD_VERSION="10.3.0"

install_fd() {
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
            url="https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-aarch64-apple-darwin.tar.gz"
            ;;
        darwin-amd64)
            url="https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-apple-darwin.tar.gz"
            ;;
        linux-amd64)
            url="https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
            ;;
        linux-arm64)
            url="https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-aarch64-unknown-linux-gnu.tar.gz"
            ;;
        *)
            log_error "Unsupported platform for fd: $platform"
            return 1
            ;;
    esac

    log_info "Installing fd $FD_VERSION for $platform"

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

    # Find the extracted directory (fd-v{version}-{platform})
    local extracted_dir
    extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "fd-*" | head -1)

    if [[ -z "$extracted_dir" ]]; then
        log_error "Could not find fd directory in extracted archive"
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi

    # Copy fd binary to install directory
    if [[ -f "$extracted_dir/fd" ]]; then
        mkdir -p "$install_dir"
        cp "$extracted_dir/fd" "$install_dir/fd"
        chmod +x "$install_dir/fd"
    else
        log_error "fd binary not found in extracted archive"
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi

    # Install man page
    if [[ -f "$extracted_dir/fd.1" ]]; then
        mkdir -p "$HOME/.local/share/man/man1"
        cp "$extracted_dir/fd.1" "$HOME/.local/share/man/man1/"
    fi

    # Install zsh completion
    if [[ -f "$extracted_dir/autocomplete/_fd" ]]; then
        mkdir -p "$HOME/.local/share/zsh/completions"
        cp "$extracted_dir/autocomplete/_fd" "$HOME/.local/share/zsh/completions/_fd"
    fi

    rm -f "$temp_file"
    rm -rf "$temp_dir"

    log_success "fd $FD_VERSION installed successfully"
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists fd; then
    install_fd
elif command_exists fd; then
    current_version=$(fd --version | cut -d ' ' -f 2)
    if [[ "$current_version" == "$FD_VERSION" ]]; then
        log_success "fd $FD_VERSION is already installed"
    else
        log_warning "fd is installed but version mismatch. Current: $current_version, Expected: $FD_VERSION"
        log_info "Use --force to reinstall"
    fi
fi