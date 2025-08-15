#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASEDIR="$(dirname "$SCRIPT_DIR")"
TOOLS_CONFIG="$BASEDIR/tools.yaml"
TOOLS_LOCK="$BASEDIR/tools.lock"

# Log functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_dry_run() {
    echo -e "${YELLOW}[DRY-RUN]${NC} $1"
}

log_conflict() {
    echo -e "${RED}[CONFLICT]${NC} $1"
}

log_check() {
    echo -e "${BLUE}[CHECK]${NC} $1"
}

# Platform detection
detect_platform() {
    local os_type
    local arch
    
    os_type=$(uname -s | tr '[:upper:]' '[:lower:]')
    arch=$(uname -m)
    
    case "$os_type" in
        darwin) os_type="darwin" ;;
        linux) os_type="linux" ;;
        *) log_error "Unsupported OS: $os_type"; exit 1 ;;
    esac
    
    case "$arch" in
        x86_64|amd64) arch="amd64" ;;
        arm64|aarch64) arch="arm64" ;;
        *) log_error "Unsupported architecture: $arch"; exit 1 ;;
    esac
    
    echo "${os_type}-${arch}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for file/directory conflicts
check_conflicts() {
    local tool="$1"
    local platform="$2"
    local conflicts=()
    local install_path
    local symlink_target
    
    install_path=$(get_tool_config "$tool" "install_path" "$platform")
    symlink_target=$(get_tool_config "$tool" "symlink_target" "$platform")
    
    if [[ -n "$install_path" ]]; then
        install_path=$(eval echo "$install_path")
        if [[ -e "$install_path" && ! -L "$install_path" ]]; then
            conflicts+=("File/directory exists at install path: $install_path")
        fi
        
        local parent_dir
        parent_dir=$(dirname "$install_path")
        if [[ ! -d "$parent_dir" && ! -w "$(dirname "$parent_dir" 2>/dev/null)" ]]; then
            conflicts+=("Cannot create parent directory: $parent_dir (permission denied)")
        fi
    fi
    
    if [[ -n "$symlink_target" ]]; then
        symlink_target=$(eval echo "$symlink_target")
        if [[ -e "$symlink_target" && ! -L "$symlink_target" ]]; then
            conflicts+=("File exists at symlink target: $symlink_target")
        fi
    fi
    
    # Check for homebrew conflicts
    local homebrew_name
    homebrew_name=$(get_tool_config "$tool" "homebrew" "$platform")
    if [[ -n "$homebrew_name" && "$platform" == darwin* ]]; then
        if command_exists brew && brew list "$homebrew_name" >/dev/null 2>&1; then
            conflicts+=("Tool already installed via homebrew: $homebrew_name")
        fi
    fi
    
    printf '%s\n' "${conflicts[@]}"
}

# Check system dependencies
check_dependencies() {
    local tool="$1"
    local platform="$2"
    local warnings=()
    
    # Check for required commands based on install method
    local url
    local install_script
    local homebrew_name
    
    url=$(get_tool_config "$tool" "url" "$platform")
    install_script=$(get_tool_config "$tool" "install_script" "$platform")
    homebrew_name=$(get_tool_config "$tool" "homebrew" "$platform")
    
    if [[ -n "$url" ]]; then
        if ! command_exists curl && ! command_exists wget; then
            warnings+=("Neither curl nor wget available for downloading")
        fi
        
        if ! command_exists tar; then
            warnings+=("tar not available for extracting archives")
        fi
    fi
    
    if [[ -n "$install_script" ]]; then
        if ! command_exists curl; then
            warnings+=("curl not available for install script")
        fi
    fi
    
    if [[ -n "$homebrew_name" && "$platform" == darwin* ]]; then
        if ! command_exists brew; then
            warnings+=("Homebrew not installed (install from https://brew.sh)")
        fi
    fi
    
    # Check disk space (basic check)
    local install_path
    install_path=$(get_tool_config "$tool" "install_path" "$platform")
    if [[ -n "$install_path" ]]; then
        install_path=$(eval echo "$install_path")
        local parent_dir
        parent_dir=$(dirname "$install_path")
        local available_space
        if available_space=$(df "$parent_dir" 2>/dev/null | awk 'NR==2 {print $4}'); then
            # If less than 100MB available, warn
            if [[ $available_space -lt 100000 ]]; then
                warnings+=("Low disk space in $parent_dir ($(( available_space / 1024 ))MB available)")
            fi
        fi
    fi
    
    printf '%s\n' "${warnings[@]}"
}

# Simulate installation without making changes
simulate_install() {
    local tool="$1"
    local platform="$2"
    local install_method=""
    local details=""
    
    log_dry_run "Simulating installation of $tool"
    
    # Check current status
    local current_version
    current_version=$(check_tool_version "$tool")
    if [[ $? -eq 0 ]]; then
        local expected_version
        expected_version=$(get_tool_config "$tool" "version")
        if [[ -n "$expected_version" && "$current_version" == *"$expected_version"* ]]; then
            log_check "$tool is already installed with correct version: $current_version"
            return 0
        else
            log_check "$tool is installed but version mismatch. Current: $current_version, Expected: $expected_version"
        fi
    else
        log_check "$tool is not currently installed"
    fi
    
    # Determine install method
    local prefer_homebrew
    prefer_homebrew=$(grep "^settings_prefer_homebrew=" <<< "$YAML_CONFIG" | cut -d'=' -f2)
    
    local homebrew_name
    local url
    local install_script
    
    homebrew_name=$(get_tool_config "$tool" "homebrew" "$platform")
    url=$(get_tool_config "$tool" "url" "$platform")
    install_script=$(get_tool_config "$tool" "install_script" "$platform")
    
    if [[ "$prefer_homebrew" == "true" && "$platform" == darwin* && -n "$homebrew_name" ]]; then
        install_method="homebrew"
        details="brew install $homebrew_name"
    elif [[ -n "$url" ]]; then
        install_method="url_download"
        local version
        version=$(get_tool_config "$tool" "version")
        local final_url="${url//\{version\}/$version}"
        details="Download from $final_url"
    elif [[ -n "$install_script" ]]; then
        install_method="install_script"
        details="Execute script from $install_script"
    elif [[ -n "$homebrew_name" && "$platform" == darwin* ]]; then
        install_method="homebrew_fallback"
        details="brew install $homebrew_name (fallback)"
    else
        install_method="none"
        details="No installation method available"
    fi
    
    log_dry_run "Would install $tool via $install_method: $details"
    
    # Check for conflicts
    local conflicts
    conflicts=$(check_conflicts "$tool" "$platform")
    if [[ -n "$conflicts" ]]; then
        while IFS= read -r conflict; do
            log_conflict "$conflict"
        done <<< "$conflicts"
        return 1
    fi
    
    # Check dependencies and warn
    local warnings
    warnings=$(check_dependencies "$tool" "$platform")
    if [[ -n "$warnings" ]]; then
        while IFS= read -r warning; do
            log_warning "$warning"
        done <<< "$warnings"
    fi
    
    # Show what would be created/modified
    local install_path
    local symlink_source
    local symlink_target
    
    install_path=$(get_tool_config "$tool" "install_path" "$platform")
    symlink_source=$(get_tool_config "$tool" "symlink_source" "$platform")
    symlink_target=$(get_tool_config "$tool" "symlink_target" "$platform")
    
    if [[ -n "$install_path" ]]; then
        install_path=$(eval echo "$install_path")
        log_dry_run "Would create/modify: $install_path"
    fi
    
    if [[ -n "$symlink_source" && -n "$symlink_target" ]]; then
        symlink_source=$(eval echo "$symlink_source")
        symlink_target=$(eval echo "$symlink_target")
        log_dry_run "Would create symlink: $symlink_source -> $symlink_target"
    fi
    
    return 0
}

# Parse YAML (basic implementation for our needs)
parse_yaml() {
    local file="$1"
    local prefix="$2"
    local s='[[:space:]]*' w='[a-zA-Z0-9_-]*' fs=$(echo @|tr @ '\034')
    
    sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$file" |
    awk -F$fs '{
        indent = length($1)/2;
        # Convert hyphens to underscores in key names
        key = $2; gsub(/-/, "_", key);
        vname[indent] = key;
        for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s=%s\n", "'$prefix'",vn, key, $3);
        }
    }'
}

# Get tool configuration
get_tool_config() {
    local tool="$1"
    local key="$2"
    local platform="$3"
    
    if [[ -n "$platform" ]]; then
        # Try platform-specific first
        grep "^tools_${tool}_platforms_${platform//-/_}_${key}=" <<< "$YAML_CONFIG" | head -1 | cut -d'=' -f2-
        if [[ $? -eq 0 && -n "$(grep "^tools_${tool}_platforms_${platform//-/_}_${key}=" <<< "$YAML_CONFIG" | head -1 | cut -d'=' -f2-)" ]]; then
            return 0
        fi
        
        # Try OS-only (without arch)
        local os_only="${platform%-*}"
        grep "^tools_${tool}_platforms_${os_only}_${key}=" <<< "$YAML_CONFIG" | head -1 | cut -d'=' -f2-
        if [[ $? -eq 0 && -n "$(grep "^tools_${tool}_platforms_${os_only}_${key}=" <<< "$YAML_CONFIG" | head -1 | cut -d'=' -f2-)" ]]; then
            return 0
        fi
        
        # Try 'all' platform
        grep "^tools_${tool}_platforms_all_${key}=" <<< "$YAML_CONFIG" | head -1 | cut -d'=' -f2-
        if [[ $? -eq 0 && -n "$(grep "^tools_${tool}_platforms_all_${key}=" <<< "$YAML_CONFIG" | head -1 | cut -d'=' -f2-)" ]]; then
            return 0
        fi
    fi
    
    # Try tool-level config
    grep "^tools_${tool}_${key}=" <<< "$YAML_CONFIG" | head -1 | cut -d'=' -f2-
}

# Check if tool is installed and get version
check_tool_version() {
    local tool="$1"
    local check_command
    local version_regex
    local current_version
    
    check_command=$(get_tool_config "$tool" "check_command")
    version_regex=$(get_tool_config "$tool" "check_version_regex")
    
    if [[ -z "$check_command" ]]; then
        return 1
    fi
    
    if ! command_exists "${check_command%% *}"; then
        return 1
    fi
    
    if [[ -n "$version_regex" ]]; then
        current_version=$($check_command 2>&1 | grep -oE "$version_regex" | head -1)
        if [[ -n "$current_version" ]]; then
            echo "$current_version"
            return 0
        fi
    fi
    
    return 1
}

# Download file with retry
download_file() {
    local url="$1"
    local output="$2"
    local retries=3
    
    for ((i=1; i<=retries; i++)); do
        if curl -sSL "$url" -o "$output"; then
            return 0
        fi
        log_warning "Download attempt $i failed, retrying..."
        sleep 1
    done
    
    log_error "Failed to download: $url"
    return 1
}

# Install tool via URL download
install_via_url() {
    local tool="$1"
    local platform="$2"
    local url
    local version
    local install_path
    local extract
    local temp_file
    
    url=$(get_tool_config "$tool" "url" "$platform")
    version=$(get_tool_config "$tool" "version")
    install_path=$(get_tool_config "$tool" "install_path" "$platform")
    extract=$(get_tool_config "$tool" "extract" "$platform")
    
    if [[ -z "$url" || -z "$install_path" ]]; then
        return 1
    fi
    
    # Substitute version in URL
    url="${url//\{version\}/$version}"
    install_path=$(eval echo "$install_path")
    
    log_info "Installing $tool from $url"
    
    temp_file=$(mktemp)
    if ! download_file "$url" "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi
    
    # Create install directory
    mkdir -p "$(dirname "$install_path")"
    
    if [[ "$extract" == "true" ]]; then
        # Extract archive
        case "$url" in
            *.tar.gz|*.tgz)
                tar -xzf "$temp_file" -C "$(dirname "$install_path")"
                ;;
            *.tar.xz)
                tar -xJf "$temp_file" -C "$(dirname "$install_path")"
                ;;
            *.zip)
                unzip -q "$temp_file" -d "$(dirname "$install_path")"
                ;;
            *)
                log_error "Unsupported archive format: $url"
                rm -f "$temp_file"
                return 1
                ;;
        esac
        
        # Handle specific extract files
        local extract_files
        extract_files=$(get_tool_config "$tool" "extract_files" "$platform")
        if [[ -n "$extract_files" ]]; then
            # Copy specific files to install path
            local files_array
            IFS=',' read -ra files_array <<< "${extract_files//[\[\]]/}"
            for file in "${files_array[@]}"; do
                file=$(echo "$file" | tr -d ' ' | tr -d '"')
                # Find the extracted file and copy it to the install path
                find "$(dirname "$install_path")" -name "$file" -type f -exec cp {} "$install_path/" \;
                # Make executable if it's a binary
                if [[ -f "$install_path/$file" ]]; then
                    chmod +x "$install_path/$file"
                fi
            done
        fi
    else
        # Direct file copy
        cp "$temp_file" "$install_path"
        chmod +x "$install_path"
    fi
    
    rm -f "$temp_file"
    
    # Handle symlinks
    local symlink_source
    local symlink_target
    symlink_source=$(get_tool_config "$tool" "symlink_source" "$platform")
    symlink_target=$(get_tool_config "$tool" "symlink_target" "$platform")
    
    if [[ -n "$symlink_source" && -n "$symlink_target" ]]; then
        symlink_source=$(eval echo "$symlink_source")
        symlink_target=$(eval echo "$symlink_target")
        
        rm -f "$symlink_target"
        ln -s "$symlink_source" "$symlink_target"
    fi
    
    return 0
}

# Install tool via homebrew
install_via_homebrew() {
    local tool="$1"
    local platform="$2"
    local homebrew_name
    
    homebrew_name=$(get_tool_config "$tool" "homebrew" "$platform")
    
    if [[ -z "$homebrew_name" ]] || ! command_exists brew; then
        return 1
    fi
    
    log_info "Installing $tool via homebrew: $homebrew_name"
    brew install "$homebrew_name"
    return 0
}

# Install tool via install script
install_via_script() {
    local tool="$1"
    local platform="$2"
    local script_url
    local install_args
    
    script_url=$(get_tool_config "$tool" "install_script" "$platform")
    install_args=$(get_tool_config "$tool" "install_args" "$platform")
    
    if [[ -z "$script_url" ]]; then
        return 1
    fi
    
    log_info "Installing $tool via install script: $script_url"
    
    if [[ -n "$install_args" ]]; then
        # Parse install args (basic implementation)
        install_args=$(echo "$install_args" | tr -d '[]' | tr ',' ' ')
        install_args=$(eval echo "$install_args")
        curl -sSL "$script_url" | sh -s -- $install_args
    else
        curl -sSL "$script_url" | sh
    fi
    
    return 0
}

# Install single tool
install_tool() {
    local tool="$1"
    local platform="$2"
    local force="${3:-false}"
    
    # If dry-run mode, simulate instead of installing
    if [[ "$DRY_RUN" == "true" ]]; then
        simulate_install "$tool" "$platform"
        return $?
    fi
    
    log_info "Processing tool: $tool"
    
    # Check if already installed (unless forced)
    if [[ "$force" != "true" ]]; then
        local current_version
        current_version=$(check_tool_version "$tool")
        if [[ $? -eq 0 ]]; then
            local expected_version
            expected_version=$(get_tool_config "$tool" "version")
            if [[ -n "$expected_version" && "$current_version" == *"$expected_version"* ]]; then
                log_success "$tool is already installed with correct version: $current_version"
                return 0
            fi
        fi
    fi
    
    # Try different installation methods in order of preference
    local prefer_homebrew
    prefer_homebrew=$(grep "^settings_prefer_homebrew=" <<< "$YAML_CONFIG" | cut -d'=' -f2)
    
    if [[ "$prefer_homebrew" == "true" && "$platform" == darwin* ]]; then
        if install_via_homebrew "$tool" "$platform"; then
            log_success "Successfully installed $tool via homebrew"
            return 0
        fi
    fi
    
    if install_via_url "$tool" "$platform"; then
        log_success "Successfully installed $tool via URL"
        return 0
    fi
    
    if install_via_script "$tool" "$platform"; then
        log_success "Successfully installed $tool via install script"
        return 0
    fi
    
    if [[ "$prefer_homebrew" != "true" && "$platform" == darwin* ]]; then
        if install_via_homebrew "$tool" "$platform"; then
            log_success "Successfully installed $tool via homebrew"
            return 0
        fi
    fi
    
    log_error "Failed to install $tool"
    return 1
}

# Main installation function
install_tools() {
    local tools_to_install=("$@")
    local platform
    local available_tools
    
    if [[ ! -f "$TOOLS_CONFIG" ]]; then
        log_error "Tools configuration file not found: $TOOLS_CONFIG"
        exit 1
    fi
    
    log_info "Loading tools configuration..."
    YAML_CONFIG=$(parse_yaml "$TOOLS_CONFIG")
    
    platform=$(detect_platform)
    log_info "Detected platform: $platform"
    
    # Get list of available tools
    available_tools=$(grep "^tools_[^_]*_description=" <<< "$YAML_CONFIG" | cut -d'_' -f2 | sort -u)
    
    if [[ ${#tools_to_install[@]} -eq 0 ]]; then
        tools_to_install=($available_tools)
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Dry-run mode: Simulating installation of tools: ${tools_to_install[*]}"
        echo
    else
        log_info "Installing tools: ${tools_to_install[*]}"
    fi
    
    local failed_tools=()
    for tool in "${tools_to_install[@]}"; do
        if ! echo "$available_tools" | grep -q "^$tool$"; then
            log_warning "Unknown tool: $tool"
            continue
        fi
        
        if ! install_tool "$tool" "$platform"; then
            failed_tools+=("$tool")
        fi
        
        # Add spacing between tools in dry-run mode for readability
        if [[ "$DRY_RUN" == "true" ]]; then
            echo
        fi
    done
    
    if [[ ${#failed_tools[@]} -gt 0 ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_error "Dry-run detected issues with: ${failed_tools[*]}"
            log_info "Fix the above conflicts before running the actual installation"
            exit 1
        else
            log_error "Failed to install: ${failed_tools[*]}"
            exit 1
        fi
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_success "Dry-run completed successfully! No conflicts detected."
        log_info "Run without --dry-run to perform the actual installation"
    else
        log_success "All tools installed successfully!"
    fi
}

# Show help
show_help() {
    cat << EOF
Usage: $0 [OPTIONS] [TOOLS...]

Install development tools based on tools.yaml configuration.

OPTIONS:
    -h, --help      Show this help message
    -l, --list      List available tools
    -f, --force     Force reinstall even if already installed
    -u, --update    Update all tools to latest versions
    -d, --dry-run   Simulate installation without making changes
    
TOOLS:
    Space-separated list of tools to install.
    If no tools specified, installs all configured tools.

Examples:
    $0                    # Install all tools
    $0 go neovim         # Install specific tools
    $0 --force go        # Force reinstall go
    $0 --dry-run         # Simulate installation of all tools
    $0 --dry-run go      # Simulate installation of specific tool
    $0 --list            # List available tools

EOF
}

# List available tools
list_tools() {
    if [[ ! -f "$TOOLS_CONFIG" ]]; then
        log_error "Tools configuration file not found: $TOOLS_CONFIG"
        exit 1
    fi
    
    log_info "Available tools:"
    YAML_CONFIG=$(parse_yaml "$TOOLS_CONFIG")
    
    while IFS= read -r line; do
        local tool description version
        tool=$(echo "$line" | cut -d'_' -f2)
        description=$(echo "$line" | cut -d'=' -f2)
        version=$(grep "^tools_${tool}_version=" <<< "$YAML_CONFIG" | cut -d'=' -f2)
        
        printf "  %-15s %s" "$tool" "$description"
        if [[ -n "$version" ]]; then
            printf " (v%s)" "$version"
        fi
        echo
    done <<< "$(grep "^tools_[^_]*_description=" <<< "$YAML_CONFIG" | sort)"
}

# Parse command line arguments
FORCE=false
UPDATE=false
DRY_RUN=false
TOOLS_TO_INSTALL=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -l|--list)
            list_tools
            exit 0
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -u|--update)
            UPDATE=true
            FORCE=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -*)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            TOOLS_TO_INSTALL+=("$1")
            shift
            ;;
    esac
done

# Run installation
install_tools "${TOOLS_TO_INSTALL[@]}"