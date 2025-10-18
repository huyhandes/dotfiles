#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

install_coursier() {
    local platform
    platform=$(detect_platform)
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    local install_dir="$HOME/opt/coursier"
    local url
    
    case "$platform" in
        darwin-arm64)
            url="https://github.com/coursier/launchers/raw/master/cs-aarch64-apple-darwin.gz"
            ;;
        darwin-amd64)
            url="https://github.com/coursier/launchers/raw/master/cs-x86_64-apple-darwin.gz"
            ;;
        linux-amd64)
            url="https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz"
            ;;
        linux-arm64)
            url="https://github.com/coursier/launchers/raw/master/cs-aarch64-pc-linux.gz"
            ;;
        *)
            log_error "Unsupported platform for Coursier: $platform"
            return 1
            ;;
    esac
    
    local temp_file=$(mktemp)
    
    log_info "Installing Coursier for $platform"
    
    if ! download_file "$url" "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi
    
    mkdir -p "$install_dir"
    
    # Extract gzipped binary directly to final location
    if ! gzip -d -c "$temp_file" > "$install_dir/cs"; then
        log_error "Failed to extract Coursier binary"
        rm -f "$temp_file"
        return 1
    fi
    
    chmod +x "$install_dir/cs"
    rm -f "$temp_file"
    
    log_success "Coursier installed successfully"
    log_info "You can now run 'cs setup' to install Scala development tools"
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists cs; then
    install_coursier
elif command_exists cs; then
    current_version=$(cs version 2>/dev/null | grep -oE '[0-9.]+' | head -1 || echo "unknown")
    log_success "Coursier is already installed (version: $current_version)"
fi