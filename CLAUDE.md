# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository that manages development environment configurations using a custom shell script installer. The repository follows a modular architecture with platform-specific installations and cross-platform configuration management.

## Common Commands

### Initial Setup
```bash
./install.sh             # Link dotfiles using custom shell script (primary installer)
./install.sh tools       # Install all development tools from tools.yaml
macos/install.sh         # Install macOS packages via Homebrew (optional)
linux/install.sh        # Install Linux packages via individual scripts (optional)
```

### Development Tools Management
```bash
./install.sh tools --list        # List all available tools
./install.sh tools               # Install all tools from tools.yaml
./install.sh tools go neovim     # Install specific tools
./install.sh tools --force go    # Force reinstall a tool
./install.sh tools --update      # Update all tools to latest versions
./install.sh tools --dry-run     # Simulate installation to detect conflicts
./install.sh tools --dry-run go  # Simulate specific tool installation
```

### Legacy Individual Tool Installation (Deprecated)
```bash
scripts/starship.sh      # Install Starship shell prompt
scripts/docker.sh        # Install Docker and related tools
scripts/go.sh           # Install Go programming language
scripts/zoxide.sh       # Install zoxide directory jumper
scripts/tpm.sh          # Install Tmux Plugin Manager
```

### Configuration Management
```bash
# Re-link configurations after changes
./install.sh

# Simulate changes before applying (dry-run mode)
./install.sh --dry-run

# Update git submodules (shell configs)
git submodule update --init --recursive

# Rebuild bat cache after theme changes
bat cache --build
```

### Dry-Run Mode & Safety Features
```bash
./install.sh --dry-run           # Simulate dotfiles installation
./install.sh tools --dry-run     # Simulate tools installation

# Dry-run mode provides:
# - Conflict detection for existing files/installations
# - Dependency validation and warnings
# - Disk space and permission checks
# - Preview of all changes before execution
```

## Architecture & Structure

### Core Components

**Custom Shell Script Installer (`install.sh`)**
- Handles automated symlinking of all configuration files
- Creates necessary directories and manages cleanup
- Links `config/*` to `~/.config/` (top-level directories only)
- Manages shell configurations from git submodule
- Provides colored output and error handling
- Backs up existing files before replacing them
- Integrates with unified development tools installer

**Development Tools Management (`tools.yaml` + `scripts/install-tools.sh`)**
- Centralized configuration for all development tools and versions
- Cross-platform support with automatic platform/architecture detection
- Version management and update capabilities
- Support for multiple installation methods (homebrew, direct downloads, install scripts)
- Comprehensive dry-run mode with conflict detection and dependency validation
- Integrated with main install.sh for unified workflow

**Platform-Specific Setup**
- `macos/`: Homebrew-based package management via Brewfile
- `linux/`: Script-based installations for various distributions
- `scripts/`: Cross-platform tool installers

**Configuration Organization**
- `config/nvim/`: Neovim configuration using lazy.nvim plugin manager
- `config/kitty/`: Modular terminal emulator configuration
- `config/tmux/`: Terminal multiplexer setup
- `config/starship/`: Shell prompt customization
- `shell/`: Git submodule containing shell configurations (.zshrc, .aliases, etc.)

### Neovim Architecture

**Plugin Management**
- Uses lazy.nvim for plugin management
- Plugins organized in `config/nvim/lua/plugins/` with one plugin per file
- Core configuration in `config/nvim/lua/core/`
- Auto-imports all plugins from plugins directory

**Key Configuration Files**
- `init.lua`: Bootstraps lazy.nvim and loads core configuration
- `core/options.lua`: Editor options and settings
- `core/keymaps.lua`: Key mappings
- `plugins/`: Individual plugin configurations

**Notable Plugins**
- LSP configuration via `lsp-config.lua`
- Code formatting with `conform.lua`
- Git integration through `gitsigns.lua`
- AI assistance with `claudecode.lua` and `snacks.lua`
- Syntax highlighting via `nvim-treesitter.lua`

### Development Workflow

1. **Making Configuration Changes**: Edit files in `config/` directory
2. **Apply Changes**: Run `./install.sh` to re-link configurations
3. **Platform Updates**: Modify `macos/Brewfile` or `linux/scripts/` for package changes
4. **Shell Configuration**: Changes to shell configs require submodule updates

### Key Files to Understand

- `install.sh`: Custom shell script installer defining all symlinks and setup tasks
- `tools.yaml`: Configuration file defining all development tools, versions, and installation methods
- `scripts/install-tools.sh`: Unified development tools installer with platform detection
- `macos/Brewfile`: Complete list of macOS packages and applications  
- `config/nvim/init.lua`: Neovim entry point and plugin loader
- `shell/` submodule: Contains actual shell configuration files

### Dependencies

**System Requirements**
- Git (for submodules)
- Bash (for install script)
- Platform-specific package managers (Homebrew on macOS)

**Key Tools Managed**
- Neovim with extensive Lua configuration
- Kitty terminal with custom themes and keybindings
- Tmux with plugin management
- Modern CLI tools (bat, eza, ripgrep, fd, fzf)
- Development tools (Docker, Go, Kubernetes CLI)