#!/bin/bash
# setup-system.sh
# Script to configure Raspberry Pi system settings for optimal homelab performance

set -e

echo "===== Raspberry Pi System Setup Script ====="
echo "This script will configure system settings for optimal homelab performance."
echo "----------------------------------------------"

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Update and upgrade packages
echo "[1/8] Updating and upgrading packages..."
apt-get update
apt-get upgrade -y

# Install essential tools
echo "[2/8] Installing essential tools..."
apt-get install -y \
    git \
    nano \
    vim \
    htop \
    iotop \
    iftop \
    nmap \
    fail2ban \
    unattended-upgrades \
    net-tools \
    ufw

# Configure firewall (UFW)
echo "[3/8] Configuring firewall..."
ufw default deny incoming
ufw default allow outgoing
# SSH
ufw allow 22/tcp
# HTTP
ufw allow 80/tcp
# HTTPS
ufw allow 443/tcp
# Pi-hole Web Interface
ufw allow 8080/tcp
# Pi-hole DNS
ufw allow 53/tcp
ufw allow 53/udp
# Enable firewall
echo "y" | ufw enable

# Configure automatic updates
echo "[4/8] Configuring automatic updates..."
cat > /etc/apt/apt.conf.d/20auto-upgrades << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
EOF

# Set up swap file if not already present
echo "[5/8] Setting up swap file..."
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    echo 'vm.swappiness=10' >> /etc/sysctl.conf
    echo 'vm.vfs_cache_pressure=50' >> /etc/sysctl.conf
    sysctl -p
fi

# Set up log rotation
echo "[6/8] Setting up log rotation..."
cat > /etc/logrotate.d/docker << EOF
/var/lib/docker/containers/*/*.log {
    rotate 7
    daily
    compress
    size=10M
    missingok
    delaycompress
    copytruncate
}
EOF

# Network configuration
echo "[7/8] Setting up network configuration..."

# Get current primary interface
PRIMARY_INTERFACE=$(ip -o -4 route show to default | awk '{print $5}' | head -n 1)
[ -z "$PRIMARY_INTERFACE" ] && PRIMARY_INTERFACE="eth0"
echo "- Detected primary interface: $PRIMARY_INTERFACE"
echo "- Current IP address: $(ip -4 addr show $PRIMARY_INTERFACE | grep -oP '(?<=inet\s)\d+(\.\d+){3}')"
echo 
echo "To configure a static IP address, use the Step_2_Setup_Static_IP.sh script:"
echo "  sudo ./Step_2_Setup_Static_IP.sh --ip 192.168.1.100/24 --gateway 192.168.1.1 --dns 1.1.1.1,8.8.8.8"
echo
echo "Run './Step_2_Setup_Static_IP.sh --help' for more options."

# Disable unnecessary services to save resources
echo "[8/8] Optimizing system services..."
systemctl disable bluetooth.service
systemctl disable avahi-daemon.service
systemctl disable triggerhappy.service

# Set hostname (uncomment and modify as needed)
# hostnamectl set-hostname homelab-pi

echo "----------------------------------------------"
echo "System setup complete!"
echo "Some changes may require a reboot to take effect."
echo "Consider rebooting with: sudo reboot"
echo "----------------------------------------------"
