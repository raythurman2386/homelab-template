# Raspberry Pi Homelab Template

A comprehensive template to quickly set up a Raspberry Pi homelab with essential services like Pi-hole for network-wide ad blocking, Nginx as a reverse proxy, Portainer for Docker management, and OpenSpeedTest for network speed testing.

## Overview

This template provides a foundation for setting up a Raspberry Pi as a homelab server with Docker containers. It includes:

- Sequential setup scripts for easy installation and configuration
- Ready-to-use Docker Compose configuration for multiple services
- Modular Nginx configuration with separate files for each service (optional)
- Cloudflare Tunnel support for secure remote access (alternative to Nginx)
- Documentation to help you get started and troubleshoot common issues

## Prerequisites

- Raspberry Pi 3 or newer (preferably Pi 4 with at least 2GB RAM)
- Raspberry Pi OS (32-bit or 64-bit) installed
- Internet connection
- Basic knowledge of Linux commands

## Quick Start

1. Clone this repository to your Raspberry Pi:
   ```bash
   git clone https://github.com/yourusername/raspberry-pi-homelab-template.git
   cd raspberry-pi-homelab-template
   ```

2. Run the setup scripts in order:
   ```bash
   ./scripts/Step_1_Setup_System.sh
   ./scripts/Step_2_Setup_Static_IP.sh
   ./scripts/Step_3_Setup_Docker.sh
   ./scripts/Step_4_Start_Services.sh
   ```

3. Access your services:
   - Pi-hole: http://your-pi-ip/pihole
   - Portainer: http://your-pi-ip/portainer
   - OpenSpeedTest: http://your-pi-ip/speedtest

4. Use the utilities script for maintenance:
   ```bash
   ./scripts/Step_5_Utilities.sh
   ```

## Directory Structure

```
raspberry-pi-homelab-template/
├── README.md - This file
├── ROADMAP.md - Future plans and enhancements
├── SETUP.md - Detailed setup instructions
├── PORTS.md - Port management documentation
├── scripts/ - Setup and utility scripts
│   ├── Step_1_Setup_System.sh - Initial system configuration
│   ├── Step_2_Setup_Static_IP.sh - Network configuration
│   ├── Step_3_Setup_Docker.sh - Docker installation
│   ├── Step_4_Start_Services.sh - Service deployment
│   └── Step_5_Utilities.sh - Maintenance utilities
├── docker/ - Docker-related configurations
│   ├── docker-compose.yml - Main compose file
│   ├── pihole/ - Pi-hole configuration
│   │   └── config/ - Pi-hole config files
│   └── nginx/ - Nginx configuration (optional)
│       ├── conf.d/ - Service configurations
│       │   ├── default.conf - Base configuration
│       │   ├── pihole.conf - Pi-hole proxy settings
│       │   ├── portainer.conf - Portainer proxy settings
│       │   ├── openspeedtest.conf - OpenSpeedTest proxy settings
│       │   └── service-template.conf - Template for new services
│       └── nginx.conf - Main Nginx config
└── docs/ - Additional documentation
    ├── getting-started.md - Detailed setup instructions
    └── troubleshooting.md - Common issues and solutions
```

## Services Included

### Pi-hole
Pi-hole provides network-wide ad blocking by acting as a DNS sinkhole. Access it through the web interface at `/pihole`.

### Nginx (Optional)
Nginx serves as a reverse proxy, allowing you to access multiple services through clean URLs. Each service has its own configuration file for easy management. This is commented out by default in favor of Cloudflare Tunnel.

### Cloudflare Tunnel
Cloudflare Tunnel provides secure remote access to your homelab services without exposing ports publicly. It creates encrypted tunnels to Cloudflare's edge network.

### Portainer
Portainer provides a web interface for managing Docker containers, images, and volumes. Access it at `/portainer`.

### OpenSpeedTest
A network speed testing tool that helps you measure your connection speed. Access it at `/speedtest`.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
