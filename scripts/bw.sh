#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

BW_VERSION="2025.11.0"

install_bw() {
    local platform
    local arch
    local filename
    local url
    
    # Detect platform and architecture
    case "$(uname -s)" in
        Darwin*)
            platform="macos"
            ;;
        Linux*)
            platform="linux"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            platform="windows"
            ;;
        *)
            log_error "Unsupported platform: $(uname -s)"
            return 1
            ;;
    esac
    
    case "$(uname -m)" in
        x86_64|amd64)
            arch="amd64"
            ;;
        arm64|aarch64)
            arch="arm64"
            ;;
        *)
            log_error "Unsupported architecture: $(uname -m)"
            return 1
            ;;
    esac
    
    # Determine filename based on platform and architecture
    if [[ "$platform" == "windows" ]]; then
        filename="bw-windows-${BW_VERSION}.zip"
    elif [[ "$platform" == "macos" ]]; then
        if [[ "$arch" == "arm64" ]]; then
            filename="bw-macos-arm64-${BW_VERSION}.zip"
        else
            filename="bw-macos-${BW_VERSION}.zip"
        fi
    else # Linux
        filename="bw-linux-${BW_VERSION}.zip"
    fi
    
    local url="https://github.com/bitwarden/clients/releases/download/cli-v${BW_VERSION}/${filename}"
    local install_dir="$HOME/.local/bin"
    local temp_file=$(mktemp)
    
    log_info "Installing Bitwarden CLI $BW_VERSION for $platform-$arch"
    
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
        log_error "Failed to extract Bitwarden CLI archive"
        return 1
    fi
    
    # Find and copy the binary
    local binary_name="bw"
    if [[ "$platform" == "windows" ]]; then
        binary_name="bw.exe"
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
        log_error "Could not find Bitwarden CLI binary in archive"
        return 1
    fi
    
    # Make binary executable and copy to install directory
    chmod +x "$binary_path"
    cp "$binary_path" "$install_dir/$binary_name"
    
    # Cleanup
    rm -f "$temp_file"
    rm -rf "$temp_dir"
    
    log_success "Bitwarden CLI $BW_VERSION installed successfully to $install_dir"
    
    # Check if install_dir is in PATH
    if [[ ":$PATH:" != *":$install_dir:"* ]]; then
        log_warning "Please add $install_dir to your PATH to use bw command"
        log_info "Add this to your shell profile: export PATH=\"\$PATH:$install_dir\""
    fi
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists bw; then
    install_bw
elif command_exists bw; then
    current_version=$(bw --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [[ "$current_version" == "$BW_VERSION" ]]; then
        log_success "Bitwarden CLI $BW_VERSION is already installed"
    else
        log_warning "Bitwarden CLI is installed but version mismatch. Current: $current_version, Expected: $BW_VERSION"
        log_info "Use --force to reinstall"
    fi
fi