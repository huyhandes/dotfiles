#!/bin/bash

# Set the installation directory
INSTALL_DIR="$HOME/.local/bin"

# Set the kubectl version
KUBECTL_VERSION="v1.32.0"  # You can change this to the desired version

# Check if the installation directory exists, create it if it doesn't
if [ ! -d "$INSTALL_DIR" ]; then
  mkdir -p "$INSTALL_DIR"
fi

# Download kubectl
echo "Downloading kubectl..."
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

# Make kubectl executable
echo "Making kubectl executable..."
chmod +x kubectl

# Move kubectl to the installation directory
echo "Moving kubectl to $INSTALL_DIR..."
mv kubectl "$INSTALL_DIR"
