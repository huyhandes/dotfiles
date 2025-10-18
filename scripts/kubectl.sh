#!/bin/bash

# Source common functions
source "$(dirname "$0")/../shell/.functions"

KUBECTL_VERSION="1.34.1"

install_kubectl() {
    local platform
    platform=$(detect_platform)

    if [[ $? -ne 0 ]]; then
        return 1
    fi

    local url
    local temp_file=$(mktemp)
    local install_dir="$HOME/.local/bin"

    # Map platform names to kubectl's platform naming convention
    case "$platform" in
        darwin-arm64)
            url="https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/darwin/arm64/kubectl"
            ;;
        darwin-amd64)
            url="https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/darwin/amd64/kubectl"
            ;;
        linux-amd64)
            url="https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
            ;;
        linux-arm64)
            url="https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/arm64/kubectl"
            ;;
        *)
            log_error "Unsupported platform for kubectl: $platform"
            return 1
            ;;
    esac

    log_info "Installing kubectl v${KUBECTL_VERSION} for $platform"

    if ! download_file "$url" "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi

    mkdir -p "$install_dir"
    cp "$temp_file" "$install_dir/kubectl"
    chmod +x "$install_dir/kubectl"
    rm -f "$temp_file"

    log_success "kubectl v${KUBECTL_VERSION} installed successfully"

    # Install completions
    install_kubectl_completions
}

install_kubectl_completions() {
    local kubectl_path="$HOME/.local/bin/kubectl"

    if [[ -f "$kubectl_path" ]]; then
        # Install bash completion
        mkdir -p "$HOME/.local/share/bash-completion/completions"
        "$kubectl_path" completion bash > "$HOME/.local/share/bash-completion/completions/kubectl" 2>/dev/null || log_warning "Failed to generate bash completion for kubectl"

        # Install zsh completion
        mkdir -p "$HOME/.local/share/zsh/completions"
        "$kubectl_path" completion zsh > "$HOME/.local/share/zsh/completions/_kubectl" 2>/dev/null || log_warning "Failed to generate zsh completion for kubectl"

        log_info "kubectl completions installed"
    fi
}

# Check if already installed (unless forced)
if [[ "$1" == "--force" ]] || ! command_exists kubectl; then
    install_kubectl
elif command_exists kubectl; then
    current_version=$(kubectl version --client --short 2>/dev/null | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 | cut -c2-)
    if [[ "$current_version" == "$KUBECTL_VERSION" ]]; then
        log_success "kubectl v${KUBECTL_VERSION} is already installed"
    else
        log_warning "kubectl is installed but version mismatch. Current: v${current_version}, Expected: v${KUBECTL_VERSION}"
        log_info "Use --force to reinstall"
    fi
fi