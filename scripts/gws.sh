#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

GWS_VERSION="0.22.5"

install_gws() {
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
            url="https://github.com/googleworkspace/cli/releases/download/v${GWS_VERSION}/google-workspace-cli-aarch64-apple-darwin.tar.gz"
            ;;
        darwin-amd64)
            url="https://github.com/googleworkspace/cli/releases/download/v${GWS_VERSION}/google-workspace-cli-x86_64-apple-darwin.tar.gz"
            ;;
        linux-amd64)
            url="https://github.com/googleworkspace/cli/releases/download/v${GWS_VERSION}/google-workspace-cli-x86_64-unknown-linux-gnu.tar.gz"
            ;;
        linux-arm64)
            url="https://github.com/googleworkspace/cli/releases/download/v${GWS_VERSION}/google-workspace-cli-aarch64-unknown-linux-gnu.tar.gz"
            ;;
        *)
            log_error "Unsupported platform for gws: $platform"
            return 1
            ;;
    esac

    log_info "Installing gws v${GWS_VERSION} for $platform"

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

    local gws_bin
    gws_bin=$(find "$temp_dir" -maxdepth 3 -type f -name "gws" | head -1)

    if [[ -z "$gws_bin" || ! -f "$gws_bin" ]]; then
        log_error "gws binary not found in extracted archive"
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi

    mkdir -p "$install_dir"
    cp "$gws_bin" "$install_dir/gws"
    chmod +x "$install_dir/gws"

    rm -f "$temp_file"
    rm -rf "$temp_dir"

    log_success "gws v${GWS_VERSION} installed successfully"
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists gws; then
    install_gws
elif command_exists gws; then
    current_version=$(gws --version 2>/dev/null | head -1 | awk '{print $2}')
    if [[ "$current_version" == "$GWS_VERSION" ]]; then
        log_success "gws v${GWS_VERSION} is already installed"
    else
        log_warning "gws is installed but version mismatch. Current: v${current_version}, Expected: v${GWS_VERSION}"
        log_info "Use --force to reinstall"
    fi
fi
