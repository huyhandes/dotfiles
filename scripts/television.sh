#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

TELEVISION_VERSION="0.15.6"

install_television() {
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
            url="https://github.com/alexpasmantier/television/releases/download/${TELEVISION_VERSION}/tv-${TELEVISION_VERSION}-aarch64-apple-darwin.tar.gz"
            ;;
        darwin-amd64)
            url="https://github.com/alexpasmantier/television/releases/download/${TELEVISION_VERSION}/tv-${TELEVISION_VERSION}-x86_64-apple-darwin.tar.gz"
            ;;
        linux-amd64)
            url="https://github.com/alexpasmantier/television/releases/download/${TELEVISION_VERSION}/tv-${TELEVISION_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
            ;;
        linux-arm64)
            url="https://github.com/alexpasmantier/television/releases/download/${TELEVISION_VERSION}/tv-${TELEVISION_VERSION}-aarch64-unknown-linux-gnu.tar.gz"
            ;;
        *)
            log_error "Unsupported platform for television: $platform"
            return 1
            ;;
    esac

    log_info "Installing television $TELEVISION_VERSION for $platform"

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

    # Find tv binary (archive may extract to subdir or flat)
    local tv_bin
    tv_bin=$(find "$temp_dir" -maxdepth 3 -type f -name "tv" | head -1)

    if [[ -z "$tv_bin" || ! -f "$tv_bin" ]]; then
        log_error "tv binary not found in extracted archive"
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    fi

    mkdir -p "$install_dir"
    cp "$tv_bin" "$install_dir/tv"
    chmod +x "$install_dir/tv"

    # Install man page if present
    local man_page
    man_page=$(find "$temp_dir" -maxdepth 4 -type f -name "tv.1" | head -1)
    if [[ -n "$man_page" ]]; then
        mkdir -p "$HOME/.local/share/man/man1"
        cp "$man_page" "$HOME/.local/share/man/man1/"
    fi

    # Install zsh completion if present
    local zsh_comp
    zsh_comp=$(find "$temp_dir" -maxdepth 4 -type f -name "_tv" | head -1)
    if [[ -n "$zsh_comp" ]]; then
        mkdir -p "$HOME/.local/share/zsh/completions"
        cp "$zsh_comp" "$HOME/.local/share/zsh/completions/_tv"
    fi

    rm -f "$temp_file"
    rm -rf "$temp_dir"

    log_success "television $TELEVISION_VERSION installed successfully"
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists tv; then
    install_television
elif command_exists tv; then
    current_version=$(tv --version 2>/dev/null | head -1 | awk '{print $2}')
    if [[ "$current_version" == "$TELEVISION_VERSION" ]]; then
        log_success "television $TELEVISION_VERSION is already installed"
    else
        log_warning "television is installed but version mismatch. Current: $current_version, Expected: $TELEVISION_VERSION"
        log_info "Use --force to reinstall"
    fi
fi
