#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

CRUSH_VERSION="0.12.3"

install_crush() {
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
            url="https://github.com/charmbracelet/crush/releases/download/v${CRUSH_VERSION}/crush_${CRUSH_VERSION}_Darwin_arm64.tar.gz"
            ;;
        darwin-amd64)
            url="https://github.com/charmbracelet/crush/releases/download/v${CRUSH_VERSION}/crush_${CRUSH_VERSION}_Darwin_x86_64.tar.gz"
            ;;
        linux-amd64)
            url="https://github.com/charmbracelet/crush/releases/download/v${CRUSH_VERSION}/crush_${CRUSH_VERSION}_Linux_x86_64.tar.gz"
            ;;
        linux-arm64)
            url="https://github.com/charmbracelet/crush/releases/download/v${CRUSH_VERSION}/crush_${CRUSH_VERSION}_Linux_arm64.tar.gz"
            ;;
        *)
            log_error "Unsupported platform for crush: $platform"
            return 1
            ;;
    esac

    log_info "Installing crush $CRUSH_VERSION for $platform"

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

    # Find the crush binary in the extracted directory
    local crush_binary
    crush_binary=$(find "$temp_dir" -name "crush" -type f | head -1)

    if [[ -z "$crush_binary" ]]; then
        log_error "crush binary not found in extracted archive"
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi

    # Copy crush binary to install directory
    mkdir -p "$install_dir"
    cp "$crush_binary" "$install_dir/crush"
    chmod +x "$install_dir/crush"

    # Install man page if available
    local man_page
    man_page=$(find "$temp_dir" -name "crush.1" -type f | head -1)
    if [[ -n "$man_page" ]]; then
        mkdir -p "$HOME/.local/share/man/man1"
        cp "$man_page" "$HOME/.local/share/man/man1/crush.1"
    fi

    # Install zsh completion if available
    local zsh_completion
    # Look for both _crush and crush.zsh patterns
    zsh_completion=$(find "$temp_dir" \( -name "_crush" -o -name "crush.zsh" \) -type f | head -1)
    if [[ -n "$zsh_completion" ]]; then
        mkdir -p "$HOME/.local/share/zsh/completions"
        # Always save as _crush for zsh completion
        cp "$zsh_completion" "$HOME/.local/share/zsh/completions/_crush"
    fi

    rm -f "$temp_file"
    rm -rf "$temp_dir"

    log_success "crush $CRUSH_VERSION installed successfully"
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists crush; then
    install_crush
elif command_exists crush; then
    current_version=$(crush --version 2>/dev/null | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "unknown")
    if [[ "$current_version" == "$CRUSH_VERSION" ]]; then
        log_success "crush $CRUSH_VERSION is already installed"
    else
        log_warning "crush is installed but version mismatch. Current: $current_version, Expected: $CRUSH_VERSION"
        log_info "Use --force to reinstall"
    fi
fi