#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

BWS_VERSION="1.0.0"

install_bws() {
    local platform
    local arch
    local filename
    local url
    
    # Detect platform and architecture
    case "$(uname -s)" in
        Darwin*)
            platform="apple-darwin"
            ;;
        Linux*)
            platform="unknown-linux-gnu"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            platform="pc-windows-msvc"
            ;;
        *)
            log_error "Unsupported platform: $(uname -s)"
            return 1
            ;;
    esac
    
    case "$(uname -m)" in
        x86_64|amd64)
            arch="x86_64"
            ;;
        arm64|aarch64)
            arch="aarch64"
            ;;
        *)
            log_error "Unsupported architecture: $(uname -m)"
            return 1
            ;;
    esac
    
    # Special case: use universal binary for macOS if available
    if [[ "$(uname -s)" == "Darwin" ]]; then
        filename="bws-macos-universal-${BWS_VERSION}.zip"
        url="https://github.com/bitwarden/sdk-sm/releases/download/bws-v${BWS_VERSION}/${filename}"
    else
        # Standard naming pattern for other platforms
        filename="bws-${arch}-${platform}-${BWS_VERSION}.zip"
        url="https://github.com/bitwarden/sdk-sm/releases/download/bws-v${BWS_VERSION}/${filename}"
    fi
    
    local install_dir="$HOME/.local/bin"
    local temp_file=$(mktemp)
    
    log_info "Installing Bitwarden Secrets Manager CLI $BWS_VERSION for $arch-$platform"
    
    # Create install directory
    mkdir -p "$install_dir"
    
    # Download the file
    if ! download_file "$url" "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi
    
    # Extract the zip file
    local temp_dir=$(mktemp -d)
    if ! unzip -q "$temp_file" -d "$temp_dir"; then
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        log_error "Failed to extract Bitwarden Secrets Manager CLI archive"
        return 1
    fi
    
    # Find and copy the binary
    local binary_name="bws"
    if [[ "$(uname -s)" == MINGW* ]] || [[ "$(uname -s)" == MSYS* ]] || [[ "$(uname -s)" == CYGWIN* ]]; then
        binary_name="bws.exe"
    fi
    
    local binary_path
    if [[ -f "$temp_dir/$binary_name" ]]; then
        binary_path="$temp_dir/$binary_name"
    else
        # Try to find the binary in subdirectories
        binary_path=$(find "$temp_dir" -name "$binary_name" -type f | head -1)
    fi
    
    if [[ -z "$binary_path" ]]; then
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        log_error "Could not find Bitwarden Secrets Manager CLI binary in archive"
        return 1
    fi
    
    # Make binary executable and copy to install directory
    chmod +x "$binary_path"
    cp "$binary_path" "$install_dir/$binary_name"
    
    # Cleanup
    rm -f "$temp_file"
    rm -rf "$temp_dir"
    
    log_success "Bitwarden Secrets Manager CLI $BWS_VERSION installed successfully to $install_dir"
    
    # Check if install_dir is in PATH
    if [[ ":$PATH:" != *":$install_dir:"* ]]; then
        log_warning "Please add $install_dir to your PATH to use bws command"
        log_info "Add this to your shell profile: export PATH=\"\$PATH:$install_dir\""
    fi
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists bws; then
    install_bws
elif command_exists bws; then
    current_version=$(bws --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [[ "$current_version" == "$BWS_VERSION" ]]; then
        log_success "Bitwarden Secrets Manager CLI $BWS_VERSION is already installed"
    else
        log_warning "Bitwarden Secrets Manager CLI is installed but version mismatch. Current: $current_version, Expected: $BWS_VERSION"
        log_info "Use --force to reinstall"
    fi
fi