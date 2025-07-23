# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository that manages development environment configurations using the Dotbot framework. The repository follows a modular architecture with platform-specific installations and cross-platform configuration management.

## Common Commands

### Initial Setup
```bash
./install                 # Link dotfiles using Dotbot (primary installer)
macos/install.sh         # Install macOS packages via Homebrew
linux/install.sh        # Install Linux packages via individual scripts
```

### Individual Tool Installation
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
./install

# Update git submodules (shell configs)
git submodule update --init --recursive

# Rebuild bat cache after theme changes
bat cache --build
```

## Architecture & Structure

### Core Components

**Dotbot Framework (`install.conf.yaml`)**
- Handles automated symlinking of all configuration files
- Creates necessary directories and manages cleanup
- Links `config/*` to `~/.config/` recursively
- Manages shell configurations from git submodule

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
2. **Apply Changes**: Run `./install` to re-link configurations
3. **Platform Updates**: Modify `macos/Brewfile` or `linux/scripts/` for package changes
4. **Shell Configuration**: Changes to shell configs require submodule updates

### Key Files to Understand

- `install.conf.yaml`: Dotbot configuration defining all symlinks and setup tasks
- `macos/Brewfile`: Complete list of macOS packages and applications
- `config/nvim/init.lua`: Neovim entry point and plugin loader
- `shell/` submodule: Contains actual shell configuration files

### Dependencies

**System Requirements**
- Git (for submodules and Dotbot)
- Python (for Dotbot framework)
- Platform-specific package managers (Homebrew on macOS)

**Key Tools Managed**
- Neovim with extensive Lua configuration
- Kitty terminal with custom themes and keybindings
- Tmux with plugin management
- Modern CLI tools (bat, eza, ripgrep, fd, fzf)
- Development tools (Docker, Go, Kubernetes CLI)