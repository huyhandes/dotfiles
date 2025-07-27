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

# Function to create symlink with proper error handling
create_symlink() {
    local source="$1"
    local target="$2"
    local force_relink="${3:-true}"
    
    # Make target absolute if it's relative
    if [[ ! "$target" =~ ^/ ]]; then
        target="$HOME/$target"
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
    log_info "Starting dotfiles installation..."
    
    cd "$BASEDIR"
    
    # Clean broken symlinks first
    clean_broken_dotfiles_symlinks
    
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
}

# Show help
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Install dotfiles by creating symlinks and running setup commands.

OPTIONS:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output (default)
    
This script will:
1. Clean broken dotfiles-related symlinks only
2. Link config/* directories to ~/.config/ (top-level only)
3. Link shell configuration files from shell/ to home directory
4. Link rclone config on macOS (if available)
5. Update git submodules
6. Build bat cache

EOF
}

# Parse command line arguments
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
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main function
main "$@"