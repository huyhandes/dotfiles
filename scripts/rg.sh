#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

RG_VERSION="15.0.0"

install_ripgrep() {
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
            url="https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-aarch64-apple-darwin.tar.gz"
            ;;
        darwin-amd64)
            url="https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-apple-darwin.tar.gz"
            ;;
        linux-amd64)
            url="https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz"
            ;;
        linux-arm64)
            url="https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-aarch64-unknown-linux-gnu.tar.gz"
            ;;
        *)
            log_error "Unsupported platform for ripgrep: $platform"
            return 1
            ;;
    esac

    log_info "Installing ripgrep ${RG_VERSION} for $platform"

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

    # Find the extracted directory (ripgrep-{version}-{platform})
    local extracted_dir
    extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "ripgrep-*" | head -1)

    if [[ -z "$extracted_dir" ]]; then
        log_error "Could not find ripgrep directory in extracted archive"
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi

    # Copy rg binary to install directory
    if [[ -f "$extracted_dir/rg" ]]; then
        mkdir -p "$install_dir"
        cp "$extracted_dir/rg" "$install_dir/rg"
        chmod +x "$install_dir/rg"
    else
        log_error "rg binary not found in extracted archive"
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi

    # Install man page
    if [[ -f "$extracted_dir/doc/rg.1" ]]; then
        mkdir -p "$HOME/.local/share/man/man1"
        cp "$extracted_dir/doc/rg.1" "$HOME/.local/share/man/man1/"
    fi

    # Install zsh completion
    if [[ -f "$extracted_dir/complete/_rg" ]]; then
        mkdir -p "$HOME/.local/share/zsh/completions"
        cp "$extracted_dir/complete/_rg" "$HOME/.local/share/zsh/completions/_rg"
    fi

    rm -f "$temp_file"
    rm -rf "$temp_dir"

    log_success "ripgrep ${RG_VERSION} installed successfully"
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists rg; then
    install_ripgrep
elif command_exists rg; then
    current_version=$(rg --version | grep ripgrep | cut -d ' ' -f 2)
    if [[ "$current_version" == "$RG_VERSION" ]]; then
        log_success "ripgrep ${RG_VERSION} is already installed"
    else
        log_warning "ripgrep is installed but version mismatch. Current: ${current_version}, Expected: ${RG_VERSION}"
        log_info "Use --force to reinstall"
    fi
fi