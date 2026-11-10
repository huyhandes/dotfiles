#!/bin/bash

source "$(dirname "$0")/../shell/.functions"

TREE_SITTER_VERSION="0.26.11"

install_tree_sitter() {
    local platform
    platform=$(detect_platform)

    if [[ $? -ne 0 ]]; then
        return 1
    fi

    local url
    local install_dir="$HOME/.local/bin"

    case "$platform" in
        darwin-arm64)
            url="https://github.com/tree-sitter/tree-sitter/releases/download/v${TREE_SITTER_VERSION}/tree-sitter-macos-arm64.gz"
            ;;
        darwin-amd64)
            url="https://github.com/tree-sitter/tree-sitter/releases/download/v${TREE_SITTER_VERSION}/tree-sitter-macos-x64.gz"
            ;;
        linux-amd64)
            url="https://github.com/tree-sitter/tree-sitter/releases/download/v${TREE_SITTER_VERSION}/tree-sitter-linux-x64.gz"
            ;;
        linux-arm64)
            url="https://github.com/tree-sitter/tree-sitter/releases/download/v${TREE_SITTER_VERSION}/tree-sitter-linux-arm64.gz"
            ;;
        *)
            log_error "Unsupported platform for tree-sitter: $platform"
            return 1
            ;;
    esac

    local temp_file
    temp_file=$(mktemp)

    log_info "Installing tree-sitter $TREE_SITTER_VERSION for $platform"

    if ! download_file "$url" "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi

    mkdir -p "$install_dir"

    gunzip -c "$temp_file" > "$install_dir/tree-sitter"
    chmod +x "$install_dir/tree-sitter"
    rm -f "$temp_file"

    log_success "tree-sitter $TREE_SITTER_VERSION installed successfully"
}

if [[ "$1" == "--force" ]] || ! command_exists tree-sitter; then
    install_tree_sitter
elif command_exists tree-sitter; then
    current_version=$(tree-sitter --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [[ "$current_version" == "$TREE_SITTER_VERSION" ]]; then
        log_success "tree-sitter $TREE_SITTER_VERSION is already installed"
    else
        log_warning "tree-sitter installed but version mismatch. Current: $current_version, Expected: $TREE_SITTER_VERSION"
        log_info "Use --force to reinstall"
    fi
fi
