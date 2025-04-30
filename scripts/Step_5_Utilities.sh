#!/bin/bash
# Step_5_Utilities.sh
# Utility functions for maintaining your Raspberry Pi homelab

# Source this file to use the functions
# Example: source Step_5_Utilities.sh

# Function to check system status
check_system() {
    echo "===== System Status ====="
    echo "• CPU Temperature: $(vcgencmd measure_temp | cut -d= -f2)"
    echo "• Memory Usage: $(free -h | grep Mem | awk '{print $3 " used out of " $2}')"
    echo "• Disk Usage: $(df -h / | awk 'NR==2 {print $3 " used out of " $2 " (" $5 " used)"}')"
    echo "• Uptime: $(uptime -p)"
    echo "• Docker containers running: $(docker ps -q | wc -l)"
    echo "=========================="
}

# Function to backup all docker volumes
backup_volumes() {
    local BACKUP_DIR="/home/$(whoami)/homelab-backups"
    local DATE=$(date +%Y-%m-%d_%H-%M)
    
    mkdir -p $BACKUP_DIR
    
    echo "===== Backing up Docker volumes ====="
    
    # Get list of volumes
    volumes=$(docker volume ls -q)
    
    for volume in $volumes; do
        echo "Backing up volume: $volume"
        docker run --rm -v $volume:/source -v $BACKUP_DIR:/backup alpine sh -c "tar -czf /backup/$volume-$DATE.tar.gz -C /source ."
    done
    
    echo "Backups completed in $BACKUP_DIR"
    echo "====================================="
}

# Function to update all docker containers
update_services() {
    echo "===== Updating Docker containers ====="
    
    # Navigate to the docker directory
    cd "$(dirname "$0")/../docker" || exit 1
    
    # Pull new images
    echo "Pulling new images..."
    docker compose pull
    
    # Restart services
    echo "Restarting services..."
    docker compose up -d
    
    # Clean up
    echo "Removing unused images..."
    docker image prune -f
    
    echo "Services updated successfully!"
    echo "======================================"
}

# Function to check services status
check_services() {
    echo "===== Services Status ====="
    
    # Check Pi-hole
    if docker ps | grep -q pihole; then
        PIHOLE_STATUS="Running"
        PIHOLE_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' pihole)
        echo "• Pi-hole: $PIHOLE_STATUS ($PIHOLE_IP)"
    else
        echo "• Pi-hole: Not running"
    fi
    
    # Check Nginx
    if docker ps | grep -q nginx; then
        NGINX_STATUS="Running"
        NGINX_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx)
        echo "• Nginx: $NGINX_STATUS ($NGINX_IP)"
    else
        echo "• Nginx: Not running"
    fi
    
    # Check Portainer
    if docker ps | grep -q portainer; then
        PORTAINER_STATUS="Running"
        PORTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' portainer)
        echo "• Portainer: $PORTAINER_STATUS ($PORTAINER_IP)"
    else
        echo "• Portainer: Not running"
    fi
    
    # Check OpenSpeedTest
    if docker ps | grep -q openspeedtest; then
        SPEEDTEST_STATUS="Running"
        SPEEDTEST_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' openspeedtest)
        echo "• OpenSpeedTest: $SPEEDTEST_STATUS ($SPEEDTEST_IP)"
    else
        echo "• OpenSpeedTest: Not running"
    fi
    
    echo "==========================="
}

# Function to restart all services
restart_services() {
    echo "===== Restarting all services ====="
    
    # Navigate to the docker directory
    cd "$(dirname "$0")/../docker" || exit 1
    
    # Restart services
    docker compose restart
    
    echo "All services restarted!"
    echo "============================="
}

# Show help
show_help() {
    echo "===== Raspberry Pi Homelab Utilities ====="
    echo "Available commands:"
    echo "  check_system    - Display system information"
    echo "  check_services  - Check status of all services"
    echo "  backup_volumes  - Backup all Docker volumes"
    echo "  update_services - Update all Docker containers"
    echo "  restart_services - Restart all services"
    echo "  show_help       - Show this help message"
    echo
    echo "How to use:"
    echo "  1. First source this file: source Step_5_Utilities.sh"
    echo "  2. Then run any command, for example: check_system"
    echo "==============================================="
}

# If the script is executed rather than sourced, show help
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script should be sourced, not executed directly."
    echo "Please run: source $(basename $0)"
    echo
    show_help
fi
