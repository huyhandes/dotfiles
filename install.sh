#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Simulate symlink creation for dry-run mode
simulate_symlink() {
    local source="$1"
    local target="$2"
    local force_relink="${3:-true}"
    local conflicts=()
    
    log_dry_run "Would create symlink: $source -> $target"
    
    # Check parent directory
    local target_dir
    target_dir="$(dirname "$target")"
    if [[ ! -d "$target_dir" ]]; then
        log_dry_run "Would create directory: $target_dir"
        # Check if we can create the parent directory
        if [[ ! -w "$(dirname "$target_dir" 2>/dev/null)" ]]; then
            conflicts+=("Cannot create parent directory: $target_dir (permission denied)")
        fi
    fi
    
    # Check for existing files/links
    if [[ -L "$target" ]]; then
        if [[ "$force_relink" == "true" ]]; then
            log_dry_run "Would remove existing symlink: $target"
        else
            log_dry_run "Symlink already exists: $target (would skip)"
            return 0
        fi
    elif [[ -e "$target" ]]; then
        if [[ "$force_relink" == "true" ]]; then
            local backup_file="${target}.backup.$(date +%Y%m%d_%H%M%S)"
            log_dry_run "Would backup existing file to: $backup_file"
        else
            conflicts+=("File exists and is not a symlink: $target")
        fi
    fi
    
    # Check if source exists
    if [[ ! -e "$source" ]]; then
        conflicts+=("Source file/directory does not exist: $source")
    fi
    
    # Report conflicts
    if [[ ${#conflicts[@]} -gt 0 ]]; then
        for conflict in "${conflicts[@]}"; do
            log_conflict "$conflict"
        done
        return 1
    fi
    
    return 0
}

# Function to create symlink with proper error handling
create_symlink() {
    local source="$1"
    local target="$2"
    local force_relink="${3:-true}"
    
    # Make target absolute if it's relative
    if [[ ! "$target" =~ ^/ ]]; then
        target="$HOME/$target"
    fi
    
    # If dry-run mode, simulate instead of creating
    if [[ "$DRY_RUN" == "true" ]]; then
        simulate_symlink "$source" "$target" "$force_relink"
        return $?
    fi
    
    # Create parent directory if it doesn't exist
    local target_dir
    target_dir="$(dirname "$target")"
    if [[ ! -d "$target_dir" ]]; then
        log_info "Creating directory: $target_dir"
        mkdir -p "$target_dir"
    fi
    
    # Handle existing files/links
    if [[ -L "$target" ]]; then
        if [[ "$force_relink" == "true" ]]; then
            log_warning "Removing existing symlink: $target"
            rm "$target"
        else
            log_warning "Symlink already exists: $target"
            return 0
        fi
    elif [[ -e "$target" ]]; then
        if [[ "$force_relink" == "true" ]]; then
            # Backup existing file before replacing
            local backup_file="${target}.backup.$(date +%Y%m%d_%H%M%S)"
            log_warning "File exists, backing up to: $backup_file"
            mv "$target" "$backup_file"
        else
            log_error "File exists and is not a symlink: $target"
            return 1
        fi
    fi
    
    # Create the symlink
    log_info "Linking: $source -> $target"
    ln -s "$source" "$target"
    
    if [[ $? -eq 0 ]]; then
        log_success "Successfully linked: $target"
    else
        log_error "Failed to create symlink: $target"
        return 1
    fi
}

# Function to link top-level directories only
link_config_directories() {
    local source_dir="$1"
    local target_dir="$2"
    
    if [[ ! -d "$source_dir" ]]; then
        log_error "Source directory does not exist: $source_dir"
        return 1
    fi
    
    log_info "Linking top-level directories from $source_dir to $target_dir"
    
    # Create target directory if it doesn't exist
    if [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir"
    fi
    
    # Link only top-level directories and files in config/
    for item in "$source_dir"/*; do
        if [[ -e "$item" ]]; then
            local basename_item
            basename_item="$(basename "$item")"
            local target_path="$target_dir/$basename_item"
            
            create_symlink "$item" "$target_path"
        fi
    done
}

# Function to clean broken symlinks (only specific dotfiles-related ones)
clean_broken_dotfiles_symlinks() {
    log_info "Cleaning broken dotfiles-related symlinks..."
    
    # Only clean specific symlinks that we manage
    local dotfiles_symlinks=(
        "$HOME/.zshrc"
        "$HOME/.zimrc"
        "$HOME/.aliases"
        "$HOME/.exports"
        "$HOME/.functions"
        "$HOME/.config/rclone"
    )
    
    for symlink in "${dotfiles_symlinks[@]}"; do
        if [[ -L "$symlink" ]] && [[ ! -e "$symlink" ]]; then
            log_warning "Removing broken dotfiles symlink: $symlink"
            rm "$symlink"
        fi
    done
    
    # Clean broken symlinks in ~/.config (but only one level deep to avoid going into subdirs)
    if [[ -d "$HOME/.config" ]]; then
        find "$HOME/.config" -maxdepth 1 -type l ! -exec test -e {} \; -print0 | while IFS= read -r -d '' broken_link; do
            log_warning "Removing broken symlink: $broken_link"
            rm "$broken_link"
        done
    fi
}

# Function to check if we're on macOS
is_macos() {
    [[ "$(uname)" == "Darwin" ]]
}

# Main installation function
main() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Dry-run mode: Simulating dotfiles installation..."
    else
        log_info "Starting dotfiles installation..."
    fi
    
    cd "$BASEDIR"
    
    # Clean broken symlinks first
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry_run "Would clean broken dotfiles-related symlinks"
    else
        clean_broken_dotfiles_symlinks
    fi
    
    # Link config directories to ~/.config/
    if [[ -d "$BASEDIR/config" ]]; then
        link_config_directories "$BASEDIR/config" "$HOME/.config"
    else
        log_error "Config directory not found: $BASEDIR/config"
        exit 1
    fi
    
    # Link shell configuration files
    log_info "Linking shell configuration files..."
    
    local shell_files=(
        "shell/.zshrc:.zshrc"
        "shell/.zimrc:.zimrc" 
        "shell/.aliases:.aliases"
        "shell/.exports:.exports"
        "shell/.functions:.functions"
    )
    
    for file_mapping in "${shell_files[@]}"; do
        local source_file="${file_mapping%:*}"
        local target_file="${file_mapping#*:}"
        
        if [[ -f "$BASEDIR/$source_file" ]]; then
            create_symlink "$BASEDIR/$source_file" "$HOME/$target_file"
        else
            log_warning "Shell file not found: $BASEDIR/$source_file"
        fi
    done
    
    # macOS-specific linking
    if is_macos; then
        log_info "Detected macOS, linking rclone config..."
        local rclone_source="$HOME/Documents/rclone"
        local rclone_target="$HOME/.config/rclone"
        
        if [[ -d "$rclone_source" ]]; then
            create_symlink "$rclone_source" "$rclone_target"
        else
            log_warning "rclone source directory not found: $rclone_source"
        fi
    fi
    
    # Post-installation commands
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry_run "Would run post-installation commands:"
        log_dry_run "Would update git submodules"
        log_dry_run "Would build bat cache (if bat is available)"
        
        log_success "Dry-run completed successfully! No conflicts detected."
        log_info "Run without --dry-run to perform the actual installation"
    else
        log_info "Running post-installation commands..."
        
        # Update git submodules
        log_info "Updating git submodules..."
        if git submodule update --init --recursive; then
            log_success "Git submodules updated successfully"
        else
            log_error "Failed to update git submodules"
        fi
        
        # Build bat cache
        log_info "Building bat cache..."
        if command -v bat >/dev/null 2>&1; then
            if bat cache --build; then
                log_success "Bat cache built successfully"
            else
                log_warning "Failed to build bat cache"
            fi
        else
            log_warning "bat command not found, skipping cache build"
        fi
        
        log_success "Dotfiles installation completed successfully!"
    fi
}

# Show help
show_help() {
    cat << EOF
Usage: $0 [OPTIONS] [COMMAND]

Install dotfiles by creating symlinks and running setup commands.

COMMANDS:
    (none)          Install dotfiles configuration (default)
    tools [ARGS]    Install development tools (see tools --help)

OPTIONS:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output (default)
    -d, --dry-run   Simulate dotfiles installation without making changes
    
This script will:
1. Clean broken dotfiles-related symlinks only
2. Link config/* directories to ~/.config/ (top-level only)
3. Link shell configuration files from shell/ to home directory
4. Link rclone config on macOS (if available)
5. Update git submodules
6. Build bat cache

For tool management:
    $0 tools --help         Show tools help
    $0 tools                Install all development tools
    $0 tools go neovim      Install specific tools
    $0 tools --dry-run      Simulate tool installation
    $0 tools --list         List available tools

Examples:
    $0                      Install dotfiles configuration
    $0 --dry-run           Simulate dotfiles installation
    $0 tools --dry-run go  Simulate installing specific tool

EOF
}

# Parse command line arguments
COMMAND=""
REMAINING_ARGS=()
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            # Already verbose by default
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        tools)
            COMMAND="tools"
            shift
            REMAINING_ARGS=("$@")
            break
            ;;
        -*)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            log_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
done

# Tools installation functions
install_tools() {
    local tools_to_install=("$@")
    local available_tools
    local force=false
    local dry_run=false
    local list_only=false
    
    # Parse arguments
    local tool_args=()
    for arg in "${tools_to_install[@]}"; do
        case "$arg" in
            --force|-f)
                force=true
                ;;
            --dry-run|-d)
                dry_run=true
                ;;
            --list|-l)
                list_only=true
                ;;
            --help|-h)
                show_tools_help
                return 0
                ;;
            *)
                tool_args+=("$arg")
                ;;
        esac
    done
    
    # Get available tools from scripts directory
    available_tools=()
    for script in "$BASEDIR/scripts"/*.sh; do
        local script_name=$(basename "$script" .sh)
        # Skip install-tools.sh (legacy)
        if [[ "$script_name" != "install-tools" ]]; then
            available_tools+=("$script_name")
        fi
    done
    
    if [[ "$list_only" == "true" ]]; then
        log_info "Available tools:"
        for tool in "${available_tools[@]}"; do
            echo "  $tool"
        done
        return 0
    fi
    
    # If no specific tools requested, install all
    if [[ ${#tool_args[@]} -eq 0 ]]; then
        tool_args=("${available_tools[@]}")
    fi
    
    if [[ "$dry_run" == "true" ]]; then
        log_info "Dry-run mode: Would install tools: ${tool_args[*]}"
        return 0
    fi
    
    log_info "Installing tools: ${tool_args[*]}"
    
    local failed_tools=()
    for tool in "${tool_args[@]}"; do
        local script_path="$BASEDIR/scripts/$tool.sh"
        
        if [[ ! -f "$script_path" ]]; then
            log_warning "Unknown tool: $tool (script not found: $script_path)"
            continue
        fi
        
        if [[ ! -x "$script_path" ]]; then
            log_warning "Tool script not executable: $script_path"
            continue
        fi
        
        log_info "Running $tool installation..."
        
        if [[ "$force" == "true" ]]; then
            if ! "$script_path" --force; then
                failed_tools+=("$tool")
            fi
        else
            if ! "$script_path"; then
                failed_tools+=("$tool")
            fi
        fi
    done
    
    if [[ ${#failed_tools[@]} -gt 0 ]]; then
        log_error "Failed to install: ${failed_tools[*]}"
        return 1
    fi
    
    log_success "All tools installed successfully!"
}

show_tools_help() {
    cat << EOF
Usage: $0 tools [OPTIONS] [TOOLS...]

Install development tools using individual installation scripts.

OPTIONS:
    -h, --help      Show this help message
    -l, --list      List available tools
    -f, --force     Force reinstall even if already installed
    -d, --dry-run   Simulate installation without making changes
    
TOOLS:
    Space-separated list of tools to install.
    If no tools specified, installs all available tools.

Examples:
    $0 tools                    # Install all tools
    $0 tools go neovim         # Install specific tools
    $0 tools --force go        # Force reinstall go
    $0 tools --dry-run         # Simulate installation of all tools
    $0 tools --list            # List available tools

EOF
}

# Execute command
case "$COMMAND" in
    tools)
        # Run simplified tools installer
        install_tools "${REMAINING_ARGS[@]}"
        ;;
    "")
        # Default: run main dotfiles installation
        main
        ;;
esac