#!/bin/bash

# edit-json-in-yaml.sh
# Script to edit JSON files in YAML format and save back as JSON
# Requires yq and nvim to be installed

set -euo pipefail

# Declare temp file variable at script scope
temp_yaml=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print error message and exit
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Function to print warning message
warn() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

# Check if required tools are available
check_dependencies() {
    if ! command -v yq >/dev/null 2>&1; then
        error_exit "yq is not installed or not in PATH. Please install yq first."
    fi
    
    if ! command -v nvim >/dev/null 2>&1; then
        error_exit "nvim is not installed or not in PATH. Please install nvim first."
    fi
}

# Check if file exists and is a valid JSON
validate_json_file() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        error_exit "File '$file' does not exist."
    fi
    
    if [[ ! -r "$file" ]]; then
        error_exit "File '$file' is not readable."
    fi
    
    if ! yq eval '.' "$file" >/dev/null 2>&1; then
        error_exit "File '$file' is not a valid JSON file."
    fi
}

# Main function
main() {
    # Check dependencies
    check_dependencies
    
    # Check if file argument is provided
    if [[ $# -eq 0 ]]; then
        error_exit "Usage: $0 <json_file>"
    fi
    
    local json_file="$1"
    
    # Validate the JSON file
    validate_json_file "$json_file"
    
    # Generate temporary filename
    temp_yaml="/tmp/edit_json_$(date +%s)_$$.yaml"
    
    # Ensure temp file is cleaned up on exit
    trap 'if [[ -n "$temp_yaml" && -f "$temp_yaml" ]]; then rm -f "$temp_yaml"; fi' EXIT
    
    # Convert JSON to YAML
    echo -e "${GREEN}Converting JSON to YAML...${NC}"
    if ! yq --output-format yaml '.' "$json_file" > "$temp_yaml"; then
        error_exit "Failed to convert JSON to YAML."
    fi
    
    # Open YAML file in nvim for editing
    echo -e "${GREEN}Opening YAML file in nvim for editing...${NC}"
    nvim "$temp_yaml"
    
    # Check if the file was modified
    if [[ ! -s "$temp_yaml" ]]; then
        error_exit "YAML file is empty after editing. Aborting to prevent data loss."
    fi
    
    # Validate the edited YAML
    if ! yq eval '.' "$temp_yaml" >/dev/null 2>&1; then
        warn "The edited YAML file is not valid."
        read -p "Do you want to continue editing? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborting."
            exit 0
        fi
        nvim "$temp_yaml"
        # Re-validate after re-editing
        if ! yq eval '.' "$temp_yaml" >/dev/null 2>&1; then
            error_exit "YAML file is still invalid. Aborting."
        fi
    fi
    
    # Create backup of original file
    local backup_file="${json_file}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$json_file" "$backup_file"
    echo -e "${GREEN}Created backup: $backup_file${NC}"
    
    # Convert YAML back to JSON
    echo -e "${GREEN}Converting YAML back to JSON...${NC}"
    if ! yq --output-format json '.' "$temp_yaml" > "$json_file"; then
        error_exit "Failed to convert YAML back to JSON. Original file is preserved in backup."
    fi
    
    echo -e "${GREEN}Successfully updated $json_file${NC}"
}

# Run main function with all arguments
main "$@"