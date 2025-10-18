#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

BAT_VERSION="0.25.0"

install_bat() {
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
            url="https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-aarch64-apple-darwin.tar.gz"
            ;;
        darwin-amd64)
            url="https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-x86_64-apple-darwin.tar.gz"
            ;;
        linux-amd64)
            url="https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
            ;;
        linux-arm64)
            url="https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-aarch64-unknown-linux-gnu.tar.gz"
            ;;
        *)
            log_error "Unsupported platform for bat: $platform"
            return 1
            ;;
    esac

    log_info "Installing bat $BAT_VERSION for $platform"

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

    # Find the extracted directory (bat-v{version}-{platform})
    local extracted_dir
    extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "bat-*" | head -1)

    if [[ -z "$extracted_dir" ]]; then
        log_error "Could not find bat directory in extracted archive"
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi

    # Copy bat binary to install directory
    if [[ -f "$extracted_dir/bat" ]]; then
        mkdir -p "$install_dir"
        cp "$extracted_dir/bat" "$install_dir/bat"
        chmod +x "$install_dir/bat"
    else
        log_error "bat binary not found in extracted archive"
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi

    # Install man page
    if [[ -f "$extracted_dir/bat.1" ]]; then
        mkdir -p "$HOME/.local/share/man/man1"
        cp "$extracted_dir/bat.1" "$HOME/.local/share/man/man1/"
    fi

    # Install zsh completion
    if [[ -f "$extracted_dir/autocomplete/bat.zsh" ]]; then
        mkdir -p "$HOME/.local/share/zsh/completions"
        cp "$extracted_dir/autocomplete/bat.zsh" "$HOME/.local/share/zsh/completions/_bat"
    fi

    rm -f "$temp_file"
    rm -rf "$temp_dir"

    log_success "bat $BAT_VERSION installed successfully"

    # Install themes
    install_bat_themes
}

install_bat_themes() {
    local themes_dir="$HOME/.config/bat/themes"
    mkdir -p "$themes_dir"

    log_info "Installing Catppuccin Macchiato theme for bat"
    if ! download_file "https://raw.githubusercontent.com/catppuccin/bat/refs/heads/main/themes/Catppuccin%20Macchiato.tmTheme" "$themes_dir/Catppuccin Macchiato.tmTheme"; then
        log_warning "Failed to download Catppuccin Macchiato theme"
    fi
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists bat; then
    install_bat
elif command_exists bat; then
    current_version=$(bat --version | cut -d ' ' -f 2)
    if [[ "$current_version" == "$BAT_VERSION" ]]; then
        log_success "bat $BAT_VERSION is already installed"
    else
        log_warning "bat is installed but version mismatch. Current: $current_version, Expected: $BAT_VERSION"
        log_info "Use --force to reinstall"
    fi
fi