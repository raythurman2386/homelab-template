#!/bin/bash
# Step_2_Setup_Static_IP.sh
# Configure a static IP address on your Raspberry Pi
# This script will automatically detect your system configuration and use the appropriate method

set -e

# Default values
IP_ADDRESS="192.168.1.100/24"
GATEWAY="192.168.1.1"
DNS="1.1.1.1,8.8.8.8"

# Colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Display usage information
show_usage() {
    echo -e "${BLUE}Raspberry Pi Static IP Configuration${NC}"
    echo
    echo "This script will help you configure a static IP address for your Raspberry Pi."
    echo "It automatically detects whether to use NetworkManager (64-bit OS) or dhcpcd (32-bit OS)."
    echo
    echo -e "${YELLOW}Usage:${NC} $0 [options]"
    echo
    echo "Options:"
    echo "  -i, --ip IP_ADDRESS      IP address with subnet (default: $IP_ADDRESS)"
    echo "  -g, --gateway GATEWAY    Gateway address (default: $GATEWAY)"
    echo "  -d, --dns DNS_SERVERS    DNS servers, comma-separated (default: $DNS)"
    echo "  -h, --help              Show this help message"
    echo 
    echo -e "${YELLOW}Example:${NC}"
    echo "  $0 --ip 192.168.1.100/24 --gateway 192.168.1.1 --dns 1.1.1.1,8.8.8.8"
    echo
    echo -e "${YELLOW}Note:${NC}"
    echo "  - Run this script with sudo"
    echo "  - Make sure you're connected to your network before running"
    echo "  - Your Pi will need to be rebooted after the change"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--ip)
            IP_ADDRESS="$2"
            shift 2
            ;;
        -g|--gateway)
            GATEWAY="$2"
            shift 2
            ;;
        -d|--dns)
            DNS="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Error: Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${YELLOW}This script must be run as root. Please use sudo.${NC}"
    exit 1
fi

# Get primary interface
PRIMARY_INTERFACE=$(ip -o -4 route show to default | awk '{print $5}' | head -n 1)
if [ -z "$PRIMARY_INTERFACE" ]; then
    PRIMARY_INTERFACE="eth0"
    echo -e "${YELLOW}Warning: Could not detect primary interface, using $PRIMARY_INTERFACE${NC}"
else
    echo -e "${GREEN}Detected primary interface: $PRIMARY_INTERFACE${NC}"
fi

echo -e "\n${BLUE}Current Configuration:${NC}"
echo "  Interface: $PRIMARY_INTERFACE"
echo "  IP Address: $IP_ADDRESS"
echo "  Gateway: $GATEWAY"
echo "  DNS Servers: $DNS"
echo

# Detect OS architecture and preferred network manager
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo -e "${BLUE}System Information:${NC}"
    echo "  OS: $PRETTY_NAME"
    if command -v arch >/dev/null 2>&1; then
        ARCH=$(arch)
        echo "  Architecture: $ARCH"
    fi
fi

# Function to configure using NetworkManager (preferred for 64-bit)
configure_networkmanager() {
    echo -e "\n${BLUE}Configuring using NetworkManager...${NC}"
    
    # Get connection name for the interface
    CON_NAME=$(nmcli -g NAME connection show | grep "$PRIMARY_INTERFACE" | head -n 1)
    
    if [ -z "$CON_NAME" ]; then
        echo "Creating new connection for $PRIMARY_INTERFACE..."
        CON_NAME="static-$PRIMARY_INTERFACE"
        nmcli con add con-name "$CON_NAME" ifname "$PRIMARY_INTERFACE" type ethernet
    else
        echo "Using existing connection: $CON_NAME"
    fi
    
    # Configure the connection with static IP
    echo "Setting static IP configuration..."
    nmcli con mod "$CON_NAME" ipv4.addresses "$IP_ADDRESS" ipv4.gateway "$GATEWAY" ipv4.dns "$DNS" ipv4.method manual
    nmcli con up "$CON_NAME"
}

# Function to ensure dhcpcd is installed and configured
ensure_dhcpcd() {
    if ! command -v dhcpcd >/dev/null 2>&1; then
        echo -e "${YELLOW}dhcpcd is not installed. Installing dhcpcd5...${NC}"
        apt-get update
        apt-get install -y dhcpcd5
        
        # Enable and start dhcpcd service
        systemctl enable dhcpcd
        systemctl start dhcpcd
    fi

    # Create dhcpcd.conf if it doesn't exist
    if [ ! -f "/etc/dhcpcd.conf" ]; then
        echo -e "${YELLOW}Creating /etc/dhcpcd.conf...${NC}"
        touch /etc/dhcpcd.conf
        echo "# Default dhcpcd.conf created by homelab setup script" > /etc/dhcpcd.conf
    fi
}

# Function to configure using dhcpcd (preferred for 32-bit)
configure_dhcpcd() {
    echo -e "${BLUE}Configuring using dhcpcd...${NC}"
    
    # Ensure dhcpcd is installed and configured
    ensure_dhcpcd

    # Backup existing configuration
    if [ -f "/etc/dhcpcd.conf" ]; then
        cp /etc/dhcpcd.conf /etc/dhcpcd.conf.backup
        echo -e "${GREEN}Backed up existing configuration to /etc/dhcpcd.conf.backup${NC}"
    fi

    # Remove any existing static IP configuration for this interface
    sed -i "/^interface $PRIMARY_INTERFACE/,/^[[:space:]]*$/d" /etc/dhcpcd.conf

    # Add new static IP configuration
    {
        echo
        echo "interface $PRIMARY_INTERFACE"
        echo "static ip_address=$IP_ADDRESS"
        echo "static routers=$GATEWAY"
        echo "static domain_name_servers=$DNS"
    } >> /etc/dhcpcd.conf

    # Restart dhcpcd service
    systemctl restart dhcpcd

    echo -e "${GREEN}Static IP configuration complete!${NC}"
    echo -e "${YELLOW}Note: Your Pi will need to be rebooted for changes to take effect${NC}"
    echo -e "${YELLOW}After reboot, your new IP address will be: ${IP_ADDRESS%/*}${NC}"
}

# Choose configuration method based on system
if command -v nmcli >/dev/null 2>&1 && [[ "$ARCH" == "aarch64" || -n "${USE_NMCLI}" ]]; then
    configure_networkmanager
else
    configure_dhcpcd
fi

# Verify configuration
echo -e "\n${BLUE}Verifying configuration:${NC}"
ip addr show $PRIMARY_INTERFACE | grep -w inet

echo -e "\n${GREEN}Static IP configuration complete!${NC}"
echo -e "${YELLOW}Important:${NC}"
echo "1. Your new IP address will be: ${IP_ADDRESS%/*}"
echo "2. You may need to reconnect to your Raspberry Pi"
echo "3. It's recommended to reboot your Pi to ensure changes take effect"
echo
echo -e "To reboot now, run: ${BLUE}sudo reboot${NC}"
