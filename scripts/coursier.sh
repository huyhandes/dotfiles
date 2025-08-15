#!/usr/bin/env bash

# Coursier installer script
# Installs Coursier (Scala application and artifact manager) to ~/opt/coursier

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect platform and architecture
detect_platform() {
    case "$(uname -s)" in
        Darwin)
            case "$(uname -m)" in
                arm64)
                    echo "darwin-arm64"
                    ;;
                x86_64)
                    echo "darwin-amd64"
                    ;;
                *)
                    print_error "Unsupported macOS architecture: $(uname -m)"
                    exit 1
                    ;;
            esac
            ;;
        Linux)
            case "$(uname -m)" in
                x86_64)
                    echo "linux-amd64"
                    ;;
                *)
                    print_error "Unsupported Linux architecture: $(uname -m)"
                    exit 1
                    ;;
            esac
            ;;
        *)
            print_error "Unsupported operating system: $(uname -s)"
            exit 1
            ;;
    esac
}

# Check if coursier is already installed
check_existing() {
    if command -v cs >/dev/null 2>&1; then
        local version
        version=$(cs version 2>/dev/null || echo "unknown")
        print_warning "Coursier is already installed (version: $version)"
        read -p "Do you want to continue with installation? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Installation cancelled"
            exit 0
        fi
    fi
}

# Install coursier
install_coursier() {
    local platform
    platform=$(detect_platform)
    
    local install_dir="$HOME/opt/coursier"
    local bin_dir="$HOME/.local/bin"
    
    print_status "Installing Coursier for platform: $platform"
    
    # Create directories
    mkdir -p "$install_dir"
    mkdir -p "$bin_dir"
    
    # Determine download URL
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
        *)
            print_error "No binary available for platform: $platform"
            exit 1
            ;;
    esac
    
    print_status "Downloading from: $url"
    
    # Download and extract
    if command -v curl >/dev/null 2>&1; then
        curl -fL "$url" | gunzip > "$install_dir/cs"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- "$url" | gunzip > "$install_dir/cs"
    else
        print_error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi
    
    # Make executable
    chmod +x "$install_dir/cs"
    
    # Create symlink in PATH
    ln -sf "$install_dir/cs" "$bin_dir/cs"
    
    print_success "Coursier installed to $install_dir"
    print_success "Symlinked to $bin_dir/cs"
}

# Verify installation
verify_installation() {
    if command -v cs >/dev/null 2>&1; then
        local version
        version=$(cs version 2>/dev/null || echo "unknown")
        print_success "Coursier installation verified (version: $version)"
        print_status "You can now run 'cs setup' to install Scala development tools"
    else
        print_error "Coursier installation failed or binary not in PATH"
        print_status "Make sure $HOME/.local/bin is in your PATH"
        exit 1
    fi
}

# Main installation flow
main() {
    print_status "Coursier installer"
    print_status "This will install Coursier to ~/opt/coursier"
    
    check_existing
    install_coursier
    verify_installation
    
    print_success "Installation complete!"
}

# Run main function
main "$@"