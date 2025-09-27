#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

install_rust() {
    local rustup_url="https://sh.rustup.rs"
    local temp_file=$(mktemp)
    
    log_info "Installing Rust using rustup"
    
    # Download rustup installer
    if ! download_file "$rustup_url" "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi
    
    # Set environment variables for custom installation paths
    export CARGO_HOME="$HOME/opt/cargo"
    export RUSTUP_HOME="$HOME/opt/rustup"
    
    # Create directories if they don't exist
    mkdir -p "$CARGO_HOME" "$RUSTUP_HOME"
    
    # Run rustup installer with non-interactive mode
    log_info "Running rustup installer with custom paths"
    log_info "CARGO_HOME: $CARGO_HOME"
    log_info "RUSTUP_HOME: $RUSTUP_HOME"
    
    if bash "$temp_file" -y --no-modify-path; then
        rm -f "$temp_file"
        
        # Source the cargo environment to make rustup available
        source "$CARGO_HOME/env"
        
        # Set default toolchain to stable
        log_info "Setting default toolchain to stable"
        rustup default stable
        
        log_success "Rust installed successfully"
        return 0
    else
        rm -f "$temp_file"
        log_error "Failed to install Rust"
        return 1
    fi
}

generate_completions() {
    local completion_dir="$HOME/.local/share/zsh/completions"
    
    # Create completions directory if it doesn't exist
    mkdir -p "$completion_dir"
    
    # Generate rustup completions if rustup is available
    if command_exists rustup; then
        log_info "Generating rustup completions"
        rustup completions zsh > "$completion_dir/_rustup" 2>/dev/null || log_warning "Failed to generate rustup completions"
    fi
    
    # Note: cargo completions are typically built into rustup installation
    log_info "Rust completions setup complete"
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists rustup; then
    if install_rust; then
        generate_completions
    fi
elif command_exists rustup; then
    current_version=$(rustup --version 2>/dev/null | grep -oE 'rustup [0-9.]+' | head -1)
    if [[ -n "$current_version" ]]; then
        log_success "Rust is already installed ($current_version)"
    else
        log_success "Rust is already installed"
    fi
    log_info "Use --force to reinstall"
fi