#!/bin/bash
# setup-docker.sh
# Script to install Docker and Docker Compose on a Raspberry Pi

set -e

# Colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${BLUE}[STATUS] $1${NC}"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

# Function to print warning messages
print_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Function to print error messages
print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# Function to check command status and exit if failed
check_status() {
    if [ $? -ne 0 ]; then
        print_error "$1"
        exit 1
    fi
}

# Function to check if a package is installed
is_package_installed() {
    dpkg -l "$1" &> /dev/null
    return $?
}

# Function to remove old Docker installations
remove_old_docker() {
    print_status "Checking for old Docker installations..."
    local old_packages=(
        "docker"
        "docker-engine"
        "docker.io"
        "containerd"
        "runc"
    )
    
    for pkg in "${old_packages[@]}"; do
        if is_package_installed "$pkg"; then
            print_warning "Removing old package: $pkg"
            apt-get remove -y "$pkg" > /dev/null 2>&1
        fi
    done
}

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    print_error "This script must be run as root. Please use sudo."
    exit 1
fi

echo -e "${BLUE}===== Raspberry Pi Docker Setup Script =====${NC}"
echo "This script will install Docker and Docker Compose on your Raspberry Pi."
echo "----------------------------------------------"

# Detect architecture
ARCH=$(dpkg --print-architecture)
print_status "Detected architecture: $ARCH"

# Remove old Docker installations
remove_old_docker

# Update package lists
print_status "Updating package lists..."
apt-get update > /dev/null 2>&1
check_status "Failed to update package lists"

# Install prerequisites
print_status "Installing prerequisites..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release > /dev/null 2>&1
check_status "Failed to install prerequisites"

# Add Docker's official GPG key
print_status "Adding Docker's GPG key..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
check_status "Failed to add Docker's GPG key"

# Set up the stable repository
print_status "Setting up Docker repository..."
echo \
  "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
check_status "Failed to set up Docker repository"

# Update apt package index
print_status "Updating package index with Docker repository..."
apt-get update > /dev/null 2>&1
check_status "Failed to update package index"

# Install Docker CE
print_status "Installing Docker CE..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null 2>&1
check_status "Failed to install Docker CE"

# Enable and start Docker service
print_status "Enabling and starting Docker service..."
systemctl enable docker > /dev/null 2>&1
systemctl start docker
check_status "Failed to enable/start Docker service"

# Add current user to docker group
if [ -n "$SUDO_USER" ]; then
    print_status "Adding user $SUDO_USER to docker group..."
    usermod -aG docker $SUDO_USER
    check_status "Failed to add user to docker group"
fi

# Verify installations
DOCKER_VERSION=$(docker --version 2>/dev/null)
COMPOSE_VERSION=$(docker compose version 2>/dev/null)

echo -e "\n${GREEN}Installation Complete!${NC}"
echo -e "${BLUE}----------------------------------------------${NC}"
if [ -n "$DOCKER_VERSION" ]; then
    echo -e "${GREEN}Docker: $DOCKER_VERSION${NC}"
else
    echo -e "${RED}Docker installation could not be verified${NC}"
fi
if [ -n "$COMPOSE_VERSION" ]; then
    echo -e "${GREEN}Docker Compose: Installed${NC}"
else
    echo -e "${RED}Docker Compose installation could not be verified${NC}"
fi
echo -e "${BLUE}----------------------------------------------${NC}"

# Print next steps
echo -e "\n${YELLOW}Next Steps:${NC}"
echo "1. Log out and log back in for the docker group changes to take effect"
echo "2. Test your installation with:"
echo "   docker run hello-world"
echo -e "${BLUE}----------------------------------------------${NC}"

# Add Docker daemon configuration for better container security
print_status "Setting up Docker daemon configuration..."
mkdir -p /etc/docker
cat > /etc/docker/daemon.json << EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "default-address-pools": [
    {
      "base": "172.17.0.0/16",
      "size": 24
    }
  ]
}
EOF
check_status "Failed to create Docker daemon configuration"

# Restart Docker to apply daemon configuration
print_status "Restarting Docker service to apply configuration..."
systemctl restart docker
check_status "Failed to restart Docker service"

print_success "Docker installation and configuration complete!"
