#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

EZA_VERSION="0.23.4"

install_eza() {
    local platform
    platform=$(detect_platform)

    if [[ $? -ne 0 ]]; then
        return 1
    fi

    local url
    local temp_file=$(mktemp)
    local temp_dir=$(mktemp -d)
    local install_dir="$HOME/.local/bin"

    # eza is Linux-only, no macOS support
    case "$platform" in
        linux-amd64)
            url="https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz"
            ;;
        linux-arm64)
            url="https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_aarch64-unknown-linux-gnu.tar.gz"
            ;;
        *)
            log_error "Unsupported platform for eza: $platform (eza is Linux-only)"
            return 1
            ;;
    esac

    log_info "Installing eza $EZA_VERSION for $platform"

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

    # Copy eza binary to install directory
    if [[ -f "$temp_dir/eza" ]]; then
        mkdir -p "$install_dir"
        cp "$temp_dir/eza" "$install_dir/eza"
        chmod +x "$install_dir/eza"
    else
        log_error "eza binary not found in extracted archive"
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi

    rm -f "$temp_file"
    rm -rf "$temp_dir"

    log_success "eza $EZA_VERSION installed successfully"

    # Install completions and man pages
    install_eza_extras
}

install_eza_extras() {
    local temp_file=$(mktemp)
    local temp_dir=$(mktemp -d)

    log_info "Installing eza completions and man pages"

    # Download completions
    if download_file "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/completions-${EZA_VERSION}.tar.gz" "$temp_file"; then
        if extract_archive "$temp_file" "$temp_dir"; then
            # Install zsh completion
            if [[ -f "$temp_dir/target/completions-${EZA_VERSION}/_eza" ]]; then
                mkdir -p "$HOME/.local/share/zsh/completions"
                cp "$temp_dir/target/completions-${EZA_VERSION}/_eza" "$HOME/.local/share/zsh/completions/_eza"
            fi
        fi
    fi

    # Download man pages
    if download_file "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/man-${EZA_VERSION}.tar.gz" "$temp_file"; then
        if extract_archive "$temp_file" "$temp_dir"; then
            # Install man page
            if [[ -f "$temp_dir/target/man-${EZA_VERSION}/eza.1" ]]; then
                mkdir -p "$HOME/.local/share/man/man1"
                cp "$temp_dir/target/man-${EZA_VERSION}/eza.1" "$HOME/.local/share/man/man1/eza.1"
            fi
        fi
    fi

    rm -f "$temp_file"
    rm -rf "$temp_dir"
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists eza; then
    install_eza
elif command_exists eza; then
    current_version=$(eza --version | sed -n '2p' | cut -d ' ' -f 1 | tr -d 'v')
    if [[ "$current_version" == "$EZA_VERSION" ]]; then
        log_success "eza $EZA_VERSION is already installed"
    else
        log_warning "eza is installed but version mismatch. Current: $current_version, Expected: $EZA_VERSION"
        log_info "Use --force to reinstall"
    fi
fi
