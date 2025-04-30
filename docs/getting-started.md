# Getting Started with Your Raspberry Pi Homelab

This guide will walk you through setting up your Raspberry Pi homelab using this template.

## Prerequisites

Before you begin, ensure you have:

- A Raspberry Pi 3 or newer (Pi 4 with 2GB+ RAM recommended)
- Raspberry Pi OS installed (Lite version is sufficient)
- Internet connection
- A microSD card with at least 16GB capacity
- Power supply appropriate for your Raspberry Pi model
- Optional: Ethernet cable (recommended for stability)

## Initial Setup

### 1. Set Up Your Raspberry Pi

1. Flash the latest Raspberry Pi OS to your microSD card using the Raspberry Pi Imager
2. Insert the microSD card into your Raspberry Pi and power it on
3. Complete the initial setup process (setting locale, password, etc.)
4. Update your system:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

### 2. Clone This Repository

1. Install Git if not already installed:
   ```bash
   sudo apt install git -y
   ```

2. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/raspberry-pi-homelab-template.git
   cd raspberry-pi-homelab-template
   ```

### 3. Run the Setup Scripts

1. Make the scripts executable:
   ```bash
   chmod +x scripts/*.sh
   ```

2. Run the system setup script:
   ```bash
   sudo ./scripts/setup-system.sh
   ```

3. Run the Docker setup script:
   ```bash
   sudo ./scripts/setup-docker.sh
   ```

4. Reboot your Raspberry Pi:
   ```bash
   sudo reboot
   ```

## Configuring Your Services

### Pi-hole Setup

1. Navigate to the docker directory:
   ```bash
   cd ~/raspberry-pi-homelab-template/docker
   ```

2. Edit the docker-compose.yml file to set your Pi-hole password and timezone:
   ```bash
   nano docker-compose.yml
   ```
   Change the following values:
   - `WEBPASSWORD`: Set a secure password
   - `TZ`: Set to your timezone (e.g., 'America/New_York')
   - `ServerIP`: Set to your Raspberry Pi's static IP address

3. Start Pi-hole:
   ```bash
   docker compose up -d
   ```

4. Access Pi-hole admin interface at `http://your-pi-ip:8080/admin`

### Nginx Configuration

1. The template includes a basic Nginx configuration to get you started
2. You can modify the configuration files in `docker/nginx/conf.d/`
3. To add a new site configuration, create a file in the conf.d directory:
   ```bash
   nano docker/nginx/conf.d/mysite.conf
   ```

4. After making changes, restart Nginx:
   ```bash
   docker restart nginx
   ```

## Setting Up a Static IP (Recommended)

For a homelab server, it's recommended to use a static IP address:

1. Edit the dhcpcd.conf file:
   ```bash
   sudo nano /etc/dhcpcd.conf
   ```

2. Add the following (adjust according to your network):
   ```
   interface eth0
   static ip_address=192.168.1.100/24
   static routers=192.168.1.1
   static domain_name_servers=1.1.1.1 8.8.8.8
   ```

3. Reboot for changes to take effect:
   ```bash
   sudo reboot
   ```

## Accessing Your Homelab

- Pi-hole admin: `http://your-pi-ip:8080/admin`
- Nginx default page: `http://your-pi-ip`
- Pi-hole through Nginx: `http://your-pi-ip/pihole/`

## Next Steps

Now that you have the basic infrastructure set up, consider:

1. Setting up HTTPS with Let's Encrypt
2. Adding more services to your docker-compose.yml
3. Configuring automatic backups
4. Setting up a VPN for remote access

Refer to the ROADMAP.md file for planned features that you might want to implement.

## Maintenance Tips

- Use the provided utility scripts in the `scripts` directory for common maintenance tasks
- Keep your system updated regularly:
  ```bash
  sudo apt update && sudo apt upgrade -y
  ```
- Update your Docker containers:
  ```bash
  cd ~/raspberry-pi-homelab-template/docker
  docker compose pull
  docker compose up -d
  ```
