#!/bin/bash
set -e

echo "Setting up dependencies for CS2Panel on Ubuntu 24.04..."

# --- Update package list ---
sudo apt update

# --- Install Docker and Docker Compose ---
echo "Installing Docker and Docker Compose..."
sudo apt install -y docker.io
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo usermod -aG docker $USER
echo "Docker and Docker Compose installed. You might need to log out and log back in for the docker group changes to take effect."

# --- Install Java (OpenJDK 17) ---
echo "Installing Java..."
sudo apt install -y openjdk-17-jdk

# --- Install Maven ---
echo "Installing Maven..."
sudo apt install -y maven

# --- Install Node.js and npm (using nvm) ---
echo "Installing Node.js and npm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install 18
nvm use 18
nvm alias default 18

# --- Install Go ---
echo "Installing Go..."
sudo apt install -y golang-go

# --- Install PostgreSQL client ---
echo "Installing PostgreSQL client..."
sudo apt install -y postgresql-client

echo "--------------------------------------------------"
echo "All dependencies installed successfully!"
echo "Please log out and log back in to apply the Docker group changes."
echo "After that, you can run either start-infra.sh or start-no-docker.sh."
echo "--------------------------------------------------"
