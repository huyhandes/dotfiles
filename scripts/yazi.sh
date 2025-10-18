#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

YAZI_VERSION="25.5.31"

install_yazi() {
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
            url="https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-aarch64-apple-darwin.zip"
            ;;
        darwin-amd64)
            url="https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-x86_64-apple-darwin.zip"
            ;;
        linux-amd64)
            url="https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-x86_64-unknown-linux-gnu.zip"
            ;;
        linux-arm64)
            url="https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-aarch64-unknown-linux-gnu.zip"
            ;;
        *)
            log_error "Unsupported platform for yazi: $platform"
            return 1
            ;;
    esac

    log_info "Installing yazi v${YAZI_VERSION} for $platform"

    if ! download_file "$url" "$temp_file"; then
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi

    if ! extract_archive "$temp_file" "$temp_dir" "zip"; then
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi

    # Find the extracted directory (yazi-{platform})
    local extracted_dir
    extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "yazi-*" | head -1)

    if [[ -z "$extracted_dir" ]]; then
        log_error "Could not find yazi directory in extracted archive"
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi

    # Copy yazi and ya binaries to install directory
    mkdir -p "$install_dir"
    if [[ -f "$extracted_dir/yazi" ]]; then
        cp "$extracted_dir/yazi" "$install_dir/yazi"
        chmod +x "$install_dir/yazi"
    else
        log_error "yazi binary not found in extracted archive"
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi

    if [[ -f "$extracted_dir/ya" ]]; then
        cp "$extracted_dir/ya" "$install_dir/ya"
        chmod +x "$install_dir/ya"
    fi

    # Install zsh completions
    if [[ -d "$extracted_dir/completions" ]]; then
        mkdir -p "$HOME/.local/share/zsh/completions"
        if [[ -f "$extracted_dir/completions/_yazi" ]]; then
            cp "$extracted_dir/completions/_yazi" "$HOME/.local/share/zsh/completions/_yazi"
        fi
        if [[ -f "$extracted_dir/completions/_ya" ]]; then
            cp "$extracted_dir/completions/_ya" "$HOME/.local/share/zsh/completions/_ya"
        fi
    fi

    rm -f "$temp_file"
    rm -rf "$temp_dir"

    log_success "yazi v${YAZI_VERSION} installed successfully"
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists yazi; then
    install_yazi
elif command_exists yazi; then
    current_version=$(yazi --version | cut -d ' ' -f 2)
    if [[ "$current_version" == "$YAZI_VERSION" ]]; then
        log_success "yazi v${YAZI_VERSION} is already installed"
    else
        log_warning "yazi is installed but version mismatch. Current: v${current_version}, Expected: v${YAZI_VERSION}"
        log_info "Use --force to reinstall"
    fi
fi