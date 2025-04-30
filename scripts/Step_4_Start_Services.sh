#!/bin/bash
# Step_4_Start_Services.sh
# Script to start all the Docker services in the homelab

set -e

echo "===== Starting Homelab Services ====="
echo "This script will start all the Docker services for your Raspberry Pi homelab."
echo "----------------------------------------------"

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Navigate to the docker directory
cd "$(dirname "$0")/../docker" || exit 1

# Check if docker is running
if ! systemctl is-active --quiet docker; then
    echo "Docker is not running. Starting Docker..."
    systemctl start docker
fi

# Pull latest images
echo "[1/3] Pulling latest Docker images..."
docker compose pull

# Start services
echo "[2/3] Starting services..."
docker compose up -d

# Check services
echo "[3/3] Checking service status..."
docker compose ps

# Display access information
echo "----------------------------------------------"
echo "All services have been started!"
echo 
echo "You can access your services at the following URLs:"
echo "• Pi-hole: http://$(hostname -I | awk '{print $1}'):8080/admin"
echo "  Default password: 'raspberry' (change this in docker-compose.yml)"
echo 
echo "• Portainer: http://$(hostname -I | awk '{print $1}'):9000"
echo "  Set up admin credentials on first access"
echo 
echo "• OpenSpeedTest: http://$(hostname -I | awk '{print $1}'):3000"
echo 
echo "• Nginx Dashboard: http://$(hostname -I | awk '{print $1}'"
echo 
echo "If you've configured a static IP, replace '$(hostname -I | awk '{print $1}')' with your static IP."
echo "For more information, see the README.md file."
echo "----------------------------------------------"
