#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

YQ_VERSION="4.48.1"

install_yq() {
    local platform
    platform=$(detect_platform)
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Convert from darwin-arm64 to darwin_arm64 for yq binary naming
    local platform=$(echo "$platform" | sed 's/-/_/g')
    local url="https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_${platform}"
    local install_dir="$HOME/.local/bin"
    local temp_file=$(mktemp)
    
    log_info "Installing yq $YQ_VERSION for $platform"
    
    if ! download_file "$url" "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi
    
    mkdir -p "$install_dir"
    mv "$temp_file" "$install_dir/yq"
    chmod +x "$install_dir/yq"
    
    log_success "yq $YQ_VERSION installed successfully"
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists yq; then
    install_yq
elif command_exists yq; then
    current_version=$(yq --version | grep -oE 'version v[0-9.]+' | head -1)
    if [[ "$current_version" == "version v$YQ_VERSION" ]]; then
        log_success "yq $YQ_VERSION is already installed"
    else
        log_warning "yq is installed but version mismatch. Current: $current_version, Expected: version v$YQ_VERSION"
        log_info "Use --force to reinstall"
    fi
fi