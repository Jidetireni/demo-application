#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting Docker installation and configuration for user: $USER"

# 1. Update package lists
echo "Updating package lists..."
sudo apt-get update -y

# 2. Install prerequisite packages
echo "Installing prerequisite packages..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# 3. Add Docker's official GPG key
echo "Adding Docker's official GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 4. Set up Docker's stable repository
echo "Setting up Docker's stable repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Install Docker Engine
echo "Updating package lists again after adding Docker repo..."
sudo apt-get update -y
echo "Installing Docker Engine, CLI, and containerd..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. Create the docker group (if it doesn't already exist)
if ! getent group docker > /dev/null; then
    echo "Creating docker group..."
    sudo groupadd docker
else
    echo "Docker group already exists."
fi

# 7. Add the current user to the docker group
echo "Adding user $USER to the docker group..."
sudo usermod -aG docker $USER

echo "-------------------------------------------------------------------"
echo "Docker installation complete!"
echo "User $USER has been added to the 'docker' group."
echo ""
echo "IMPORTANT: For the group changes to take effect, you need to either:"
echo "1. Log out and log back in."
echo "2. Or, run the following command in your current shell (this might not work in all environments):"
echo "   newgrp docker"
echo "3. Or, reboot your system."
echo ""
echo "After that, you should be able to run Docker commands without sudo."
echo "You can test this by running: docker run hello-world"
echo "-------------------------------------------------------------------"
