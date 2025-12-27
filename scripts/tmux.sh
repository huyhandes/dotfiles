#!/bin/bash
#
# tmux build and install script
# Supports cross-platform builds via Docker and native builds
#
# Usage:
#   ./scripts/tmux.sh                    # Build for current platform
#   ./scripts/tmux.sh --platform linux/amd64  # Build for specific platform
#   ./scripts/tmux.sh --platform linux/arm64  # Build for ARM64 Linux
#   ./scripts/tmux.sh --native           # Build natively (macOS recommended)
#   ./scripts/tmux.sh --install          # Build and install to ~/.local/bin
#   ./scripts/tmux.sh --force            # Force rebuild even if installed
#
# References:
#   - https://github.com/tmux/tmux/wiki/Installing
#   - https://github.com/pythops/tmux-linux-binary
#   - https://github.com/mjakob-gh/build-static-tmux

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/../shell/.functions"

# Configuration
TMUX_VERSION="${TMUX_VERSION:-3.5a}"
DOCKERFILE="$DOTFILES_DIR/build/Dockerfile.tmux"
OUTPUT_DIR="$DOTFILES_DIR/dist"
INSTALL_DIR="$HOME/.local/bin"

# Parse arguments
PLATFORM=""
NATIVE_BUILD=false
DO_INSTALL=false
FORCE=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Build tmux from source using Docker or native toolchain.

Options:
    -p, --platform PLATFORM   Target platform (linux/amd64, linux/arm64)
    -n, --native              Build natively (recommended for macOS)
    -i, --install             Install to ~/.local/bin after build
    -f, --force               Force rebuild even if already installed
    -v, --version VERSION     Specify tmux version (default: $TMUX_VERSION)
    -o, --output DIR          Output directory (default: $OUTPUT_DIR)
    -h, --help                Show this help message

Examples:
    $(basename "$0")                          # Auto-detect and build
    $(basename "$0") --platform linux/arm64   # Build for ARM64 Linux
    $(basename "$0") --native --install       # Native build + install (macOS)
    $(basename "$0") --install --force        # Rebuild and reinstall

Supported platforms:
    - linux/amd64    Debian, Ubuntu, Amazon Linux, etc. (x86_64)
    - linux/arm64    Amazon Linux 2023, Ubuntu ARM, etc. (aarch64)
    - darwin/arm64   macOS Apple Silicon (native build only)
    - darwin/amd64   macOS Intel (native build only)
EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        -n|--native)
            NATIVE_BUILD=true
            shift
            ;;
        -i|--install)
            DO_INSTALL=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -v|--version)
            TMUX_VERSION="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Auto-detect platform if not specified
detect_build_platform() {
    local platform
    platform=$(detect_platform)

    case "$platform" in
        darwin-arm64)
            echo "darwin/arm64"
            ;;
        darwin-amd64)
            echo "darwin/amd64"
            ;;
        linux-arm64)
            echo "linux/arm64"
            ;;
        linux-amd64)
            echo "linux/amd64"
            ;;
        *)
            log_error "Unsupported platform: $platform"
            exit 1
            ;;
    esac
}

# Check if tmux is already installed with correct version
check_existing_install() {
    if [[ "$FORCE" == "true" ]]; then
        return 1
    fi

    if command_exists tmux; then
        local current_version
        current_version=$(tmux -V | grep -oE '[0-9]+\.[0-9]+[a-z]?' | head -1)
        if [[ "$current_version" == "$TMUX_VERSION" ]]; then
            log_success "tmux $TMUX_VERSION is already installed"
            return 0
        else
            log_warning "tmux version mismatch. Current: $current_version, Expected: $TMUX_VERSION"
            return 1
        fi
    fi
    return 1
}

# Build tmux natively (for macOS or Linux without Docker)
build_native() {
    log_info "Building tmux $TMUX_VERSION natively..."

    local platform
    platform=$(detect_platform)

    # Check dependencies
    local missing_deps=()

    if [[ "$platform" == darwin-* ]]; then
        # macOS: Use Homebrew for dependencies
        if ! command_exists brew; then
            log_error "Homebrew is required for native macOS builds"
            log_info "Install with: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi

        log_info "Installing build dependencies via Homebrew..."
        brew install automake libevent ncurses pkg-config 2>/dev/null || true
    else
        # Linux: Check for required packages
        for cmd in gcc make autoconf automake pkg-config; do
            if ! command_exists "$cmd"; then
                missing_deps+=("$cmd")
            fi
        done

        if [[ ${#missing_deps[@]} -gt 0 ]]; then
            log_error "Missing build dependencies: ${missing_deps[*]}"
            log_info "On Debian/Ubuntu: sudo apt install build-essential autoconf automake pkg-config libevent-dev libncurses-dev bison"
            log_info "On RHEL/Amazon Linux: sudo dnf install gcc make autoconf automake pkg-config libevent-devel ncurses-devel bison"
            exit 1
        fi
    fi

    # Create build directory
    local build_dir
    build_dir=$(mktemp -d)
    trap "rm -rf $build_dir" EXIT

    cd "$build_dir"

    # Download tmux source
    log_info "Downloading tmux $TMUX_VERSION..."
    local url="https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
    curl -sSL "$url" -o tmux.tar.gz
    tar xzf tmux.tar.gz
    cd "tmux-${TMUX_VERSION}"

    # Configure and build
    log_info "Configuring..."
    if [[ "$platform" == darwin-* ]]; then
        # macOS: Use Homebrew paths
        local homebrew_prefix
        homebrew_prefix=$(brew --prefix)
        ./configure \
            --prefix="$HOME/.local" \
            PKG_CONFIG_PATH="${homebrew_prefix}/lib/pkgconfig" \
            CFLAGS="-I${homebrew_prefix}/include -I${homebrew_prefix}/include/ncurses" \
            LDFLAGS="-L${homebrew_prefix}/lib"
    else
        # Linux: Try static build
        ./configure \
            --enable-static \
            --prefix="$HOME/.local" \
            LDFLAGS="-static" 2>/dev/null || \
        ./configure --prefix="$HOME/.local"
    fi

    log_info "Building..."
    make -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu)"

    # Create output directory and copy binary
    mkdir -p "$OUTPUT_DIR"
    local binary_name="tmux-${TMUX_VERSION}-${platform}"
    cp tmux "$OUTPUT_DIR/$binary_name"

    # Strip the binary
    strip "$OUTPUT_DIR/$binary_name" 2>/dev/null || true

    log_success "Build complete: $OUTPUT_DIR/$binary_name"

    # Return the binary path for installation
    echo "$OUTPUT_DIR/$binary_name"
}

# Build tmux using Docker (for Linux targets)
build_docker() {
    local target_platform="${1:-linux/amd64}"

    log_info "Building tmux $TMUX_VERSION for $target_platform using Docker..."

    # Check Docker is available
    if ! command_exists docker; then
        log_error "Docker is required for cross-platform builds"
        log_info "Install Docker or use --native flag for native builds"
        exit 1
    fi

    # Check if buildx is available for multi-platform builds
    if ! docker buildx version &>/dev/null; then
        log_warning "Docker buildx not available, falling back to standard build"
        # For non-buildx, we can only build for current platform
        local current_arch
        current_arch=$(uname -m)
        case "$current_arch" in
            x86_64|amd64)
                if [[ "$target_platform" != "linux/amd64" ]]; then
                    log_error "Cannot build for $target_platform without Docker buildx"
                    exit 1
                fi
                ;;
            arm64|aarch64)
                if [[ "$target_platform" != "linux/arm64" ]]; then
                    log_error "Cannot build for $target_platform without Docker buildx"
                    exit 1
                fi
                ;;
        esac
    fi

    # Ensure output directory exists
    mkdir -p "$OUTPUT_DIR"

    # Determine output filename
    local arch_name
    case "$target_platform" in
        linux/amd64)
            arch_name="linux-amd64"
            ;;
        linux/arm64)
            arch_name="linux-arm64"
            ;;
        *)
            log_error "Unsupported Docker platform: $target_platform"
            exit 1
            ;;
    esac

    local binary_name="tmux-${TMUX_VERSION}-${arch_name}"

    # Build using Docker buildx
    log_info "Running Docker build..."

    if docker buildx version &>/dev/null; then
        # Use buildx for cross-platform support
        docker buildx build \
            --platform "$target_platform" \
            --build-arg "TMUX_VERSION=${TMUX_VERSION}" \
            --target export \
            --output "type=local,dest=$OUTPUT_DIR" \
            -f "$DOCKERFILE" \
            "$DOTFILES_DIR"

        # Rename the output binary
        if [[ -f "$OUTPUT_DIR/tmux" ]]; then
            mv "$OUTPUT_DIR/tmux" "$OUTPUT_DIR/$binary_name"
        fi
    else
        # Fallback: build and extract from container
        local image_name="tmux-builder:${TMUX_VERSION}"

        docker build \
            --build-arg "TMUX_VERSION=${TMUX_VERSION}" \
            --target runtime \
            -t "$image_name" \
            -f "$DOCKERFILE" \
            "$DOTFILES_DIR"

        # Extract binary from container
        local container_id
        container_id=$(docker create "$image_name")
        docker cp "$container_id:/usr/local/bin/tmux" "$OUTPUT_DIR/$binary_name"
        docker rm "$container_id"
    fi

    # Make executable and strip
    chmod +x "$OUTPUT_DIR/$binary_name"
    strip "$OUTPUT_DIR/$binary_name" 2>/dev/null || true

    log_success "Build complete: $OUTPUT_DIR/$binary_name"

    # Return the binary path for installation
    echo "$OUTPUT_DIR/$binary_name"
}

# Install the built binary
install_binary() {
    local binary_path="$1"

    if [[ ! -f "$binary_path" ]]; then
        log_error "Binary not found: $binary_path"
        exit 1
    fi

    log_info "Installing tmux to $INSTALL_DIR..."

    mkdir -p "$INSTALL_DIR"

    # Backup existing installation
    if [[ -f "$INSTALL_DIR/tmux" ]]; then
        local backup="$INSTALL_DIR/tmux.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backing up existing tmux to $backup"
        mv "$INSTALL_DIR/tmux" "$backup"
    fi

    cp "$binary_path" "$INSTALL_DIR/tmux"
    chmod +x "$INSTALL_DIR/tmux"

    # Verify installation
    if "$INSTALL_DIR/tmux" -V &>/dev/null; then
        log_success "tmux $TMUX_VERSION installed successfully to $INSTALL_DIR/tmux"
        log_info "Make sure $INSTALL_DIR is in your PATH"
    else
        log_error "Installation verification failed"
        exit 1
    fi
}

# Main
main() {
    log_info "tmux build script"
    log_info "Version: $TMUX_VERSION"

    # Check existing installation
    if ! $FORCE && check_existing_install; then
        exit 0
    fi

    # Auto-detect platform if not specified
    if [[ -z "$PLATFORM" ]]; then
        PLATFORM=$(detect_build_platform)
    fi

    log_info "Target platform: $PLATFORM"

    local binary_path=""

    # Determine build method
    case "$PLATFORM" in
        darwin/*)
            # macOS: Always use native build
            if [[ "$NATIVE_BUILD" == "false" ]]; then
                log_info "macOS detected, using native build (Docker not supported for macOS targets)"
            fi
            binary_path=$(build_native)
            ;;
        linux/*)
            if [[ "$NATIVE_BUILD" == "true" ]]; then
                binary_path=$(build_native)
            else
                binary_path=$(build_docker "$PLATFORM")
            fi
            ;;
        *)
            log_error "Unsupported platform: $PLATFORM"
            exit 1
            ;;
    esac

    # Install if requested
    if [[ "$DO_INSTALL" == "true" ]]; then
        install_binary "$binary_path"
    fi
}

main "$@"
