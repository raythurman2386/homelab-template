# Quick Setup Guide

This guide will walk you through setting up your Raspberry Pi homelab in just a few simple steps.

## Before You Begin

1. Make sure you have a Raspberry Pi with Raspberry Pi OS installed
2. Connect your Raspberry Pi to your home network
3. Log in to your Raspberry Pi via SSH or terminal

## Step-by-Step Setup

### Step 1: Initial System Setup

This step will configure your Raspberry Pi with optimized system settings.

```bash
sudo chmod +x scripts/Step_1_Setup_System.sh
sudo ./scripts/Step_1_Setup_System.sh
```

After running this script, your Raspberry Pi will have:
- Essential system tools installed
- Security settings configured
- Log rotation set up
- Unnecessary services disabled

### Step 2: Configure a Static IP (Recommended)

Setting a static IP makes it easier to access your homelab services.

```bash
sudo chmod +x scripts/Step_2_Setup_Static_IP.sh
sudo ./scripts/Step_2_Setup_Static_IP.sh
```

Or, to specify your own IP address:

```bash
sudo ./scripts/Step_2_Setup_Static_IP.sh --ip 192.168.1.100/24 --gateway 192.168.1.1 --dns 1.1.1.1,8.8.8.8
```

### Step 3: Install Docker

This step installs Docker and Docker Compose, which are required to run the services.

```bash
sudo chmod +x scripts/Step_3_Setup_Docker.sh
sudo ./scripts/Step_3_Setup_Docker.sh
```

After installation, you may need to log out and log back in for the group settings to take effect.

### Step 4: Start Services

This step starts all the homelab services (Pi-hole, Cloudflare Tunnel, Portainer, OpenSpeedTest).

```bash
sudo chmod +x scripts/Step_4_Start_Services.sh
sudo ./scripts/Step_4_Start_Services.sh
```

### Step 5: Utilities (Optional)

The utilities script provides helpful commands for maintaining your homelab.

```bash
sudo chmod +x scripts/Step_5_Utilities.sh
source ./scripts/Step_5_Utilities.sh
show_help
```

You can then use commands like:
- `check_system` - Display system information
- `check_services` - Check status of all services
- `backup_volumes` - Backup all Docker volumes
- `update_services` - Update all Docker containers

## Accessing Your Services

After completing these steps, you can access your services at:

| Service | Direct URL | Cloudflare URL | Description |
|---------|------------|----------------|-------------|
| Pi-hole | http://your-pi-ip:8080/admin | https://pihole.yourdomain.com | Network-wide ad blocker |
| Portainer | http://your-pi-ip:9000 | https://portainer.yourdomain.com | Docker management |
| OpenSpeedTest | http://your-pi-ip:3000 | https://speedtest.yourdomain.com | Network speed testing |
| Dashboard | http://your-pi-ip | https://homelab.yourdomain.com | Main dashboard |

Notes:
- Replace `your-pi-ip` with your Raspberry Pi's IP address
- The Cloudflare URLs require setting up a Cloudflare Tunnel (see below)
- If using Nginx instead, uncomment the nginx service in docker-compose.yml and configure accordingly

## Troubleshooting

If you encounter any issues:

1. Check that all scripts were run with `sudo`
2. Verify that your Raspberry Pi is connected to the network
3. Check service status with `check_services` from the utilities script
4. See the detailed troubleshooting guide in the `docs/troubleshooting.md` file

## Setting Up Cloudflare Tunnel (Recommended)

For secure remote access without exposing ports publicly:

1. Create a Cloudflare account and add your domain
2. Install cloudflared locally: `curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && sudo dpkg -i cloudflared.deb`
3. Login to Cloudflare: `cloudflared tunnel login`
4. Create a tunnel: `cloudflared tunnel create homelab-tunnel`
5. Create a config file:
   ```yaml
   tunnel: homelab-tunnel
   credentials-file: /root/.cloudflared/homelab-tunnel.json
   
   ingress:
     - hostname: pihole.yourdomain.com
       service: http://pihole:80
     - hostname: portainer.yourdomain.com
       service: http://portainer:9000
     - hostname: speedtest.yourdomain.com
       service: http://openspeedtest:3000
     - service: http_status:404
   ```
6. Get the tunnel token: `cloudflared tunnel token homelab-tunnel`
7. Set the TUNNEL_TOKEN environment variable in your docker-compose.yml
8. Start the services: `docker compose up -d`
