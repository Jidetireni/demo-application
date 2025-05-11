#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Attempting to install Taskfile..."

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed. Please install curl first."
    echo "On Debian/Ubuntu: sudo apt update && sudo apt install curl"
    echo "On Fedora: sudo dnf install curl"
    echo "On macOS (with Homebrew): brew install curl"
    exit 1
fi

# Run the official Taskfile installation script
# This will attempt to install to /usr/local/bin
# You might be prompted for your sudo password if /usr/local/bin requires it.
echo "Running the official Taskfile installer..."
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

echo ""
echo "Taskfile installation script finished."
echo "-------------------------------------------------------------------"
echo "To verify the installation, try running:"
echo "  task --version"
echo ""
echo "If '/usr/local/bin' is not in your PATH, you might need to add it."
echo "You can typically do this by adding the following to your shell profile"
echo "(e.g., ~/.bashrc, ~/.zshrc, ~/.profile):"
echo "  export PATH=\"/usr/local/bin:\$PATH\""
echo "Then, source your profile (e.g., source ~/.bashrc) or open a new terminal."
echo "-------------------------------------------------------------------"
