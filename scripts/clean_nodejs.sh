#!/bin/bash
# Complete Node.js removal script for Amazon Linux 2023
# This script removes Node.js installed via dnf, nvm, or manual installation

set -e

echo "================================================"
echo "Node.js Complete Removal Script"
echo "Amazon Linux 2023"
echo "================================================"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check current Node.js installation
echo -e "\n[1/7] Checking current Node.js installation..."
if command_exists node; then
    echo "Node.js version found: $(node -v)"
    echo "Node.js location: $(which node)"
else
    echo "No active Node.js installation detected"
fi

if command_exists npm; then
    echo "npm version found: $(npm -v)"
    echo "npm location: $(which npm)"
fi

# Remove DNF-installed Node.js packages
echo -e "\n[2/7] Removing Node.js packages installed via DNF..."
# Remove all Node.js versions (18, 20, 22) and their npm packages
sudo dnf remove -y nodejs nodejs-npm nodejs18 nodejs18-npm nodejs20 nodejs20-npm nodejs22 nodejs22-npm 2>/dev/null || echo "No DNF packages found"

# Clean up DNF cache
sudo dnf clean all

# Remove NVM-installed Node.js
echo -e "\n[3/7] Removing NVM (Node Version Manager) installations..."
if [ -d "$HOME/.nvm" ]; then
    echo "NVM installation found at $HOME/.nvm"
    
    # Load NVM if it exists
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Uninstall all Node.js versions managed by NVM
    if command_exists nvm; then
        echo "Uninstalling all NVM-managed Node.js versions..."
        nvm ls | grep -oP 'v\d+\.\d+\.\d+' | while read version; do
            echo "Removing $version..."
            nvm uninstall "$version" 2>/dev/null || true
        done
    fi
    
    # Remove NVM directory
    echo "Removing NVM directory..."
    rm -rf "$HOME/.nvm"
    echo "NVM removed successfully"
else
    echo "No NVM installation found"
fi

# Remove manually installed Node.js binaries
echo -e "\n[4/7] Removing manually installed Node.js binaries..."
sudo rm -f /usr/local/bin/node
sudo rm -f /usr/local/bin/npm
sudo rm -f /usr/local/bin/npx
sudo rm -f /usr/bin/node
sudo rm -f /usr/bin/npm
sudo rm -f /usr/bin/npx

# Remove namespaced binaries from AL2023
sudo rm -f /usr/bin/node-*
sudo rm -f /usr/bin/npm-*

# Remove Node.js libraries and modules
echo -e "\n[5/7] Removing Node.js libraries and global modules..."
sudo rm -rf /usr/local/lib/node
sudo rm -rf /usr/local/lib/node_modules
sudo rm -rf /usr/lib/node_modules
sudo rm -rf /usr/local/include/node

# Remove user-specific npm data
echo -e "\n[6/7] Removing user-specific npm data..."
rm -rf "$HOME/.npm"
rm -rf "$HOME/.node_gyp"
rm -rf "$HOME/.node-gyp"
rm -rf "$HOME/.npmrc"

# Clean up shell configuration files
echo -e "\n[7/7] Cleaning up shell configuration files..."
# Remove NVM lines from bash profile
sed -i '/NVM_DIR/d' "$HOME/.bashrc" 2>/dev/null || true
sed -i '/nvm.sh/d' "$HOME/.bashrc" 2>/dev/null || true
sed -i '/bash_completion/d' "$HOME/.bashrc" 2>/dev/null || true
sed -i '/NVM_DIR/d' "$HOME/.bash_profile" 2>/dev/null || true
sed -i '/nvm.sh/d' "$HOME/.bash_profile" 2>/dev/null || true

# Remove from zsh if exists
if [ -f "$HOME/.zshrc" ]; then
    sed -i '/NVM_DIR/d' "$HOME/.zshrc" 2>/dev/null || true
    sed -i '/nvm.sh/d' "$HOME/.zshrc" 2>/dev/null || true
fi

# Remove alternatives configuration (AL2023 specific)
echo -e "\n[EXTRA] Removing alternatives configuration..."
sudo alternatives --remove-all node 2>/dev/null || echo "No node alternatives found"
sudo alternatives --remove-all npm 2>/dev/null || echo "No npm alternatives found"

# Clean up autoremove
echo -e "\n[CLEANUP] Running autoremove..."
sudo dnf autoremove -y

echo -e "\n================================================"
echo "Node.js removal completed!"
echo "================================================"

# Verification
echo -e "\nVerification:"
if command_exists node; then
    echo "⚠️  WARNING: Node.js is still detected at $(which node)"
    echo "   Version: $(node -v)"
else
    echo "✓ Node.js successfully removed"
fi

if command_exists npm; then
    echo "⚠️  WARNING: npm is still detected at $(which npm)"
else
    echo "✓ npm successfully removed"
fi

echo -e "\n================================================"
echo "Please restart your terminal or run: source ~/.bashrc"
echo "================================================"

