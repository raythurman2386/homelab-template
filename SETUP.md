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

This step starts all the homelab services (Pi-hole, Nginx, Portainer, OpenSpeedTest).

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

| Service | Direct URL | Nginx URL | Description |
|---------|------------|-----------|-------------|
| Pi-hole | http://your-pi-ip:8080/admin | http://pihole.local | Network-wide ad blocker |
| Portainer | http://your-pi-ip:9000 | http://portainer.local | Docker management |
| OpenSpeedTest | http://your-pi-ip:3000 | http://speedtest.local | Network speed testing |
| Dashboard | http://your-pi-ip | http://your-pi-ip | Main dashboard |

Notes:
- Replace `your-pi-ip` with your Raspberry Pi's IP address
- The Nginx URLs require either:
  1. Setting up local DNS entries in your router for `.local` domains, or
  2. Adding entries to your computer's hosts file
- If you haven't set up DNS, you can also use path-based access:
  - Pi-hole: http://your-pi-ip/pihole/
  - Portainer: http://your-pi-ip/portainer/
  - OpenSpeedTest: http://your-pi-ip/speedtest/

## Troubleshooting

If you encounter any issues:

1. Check that all scripts were run with `sudo`
2. Verify that your Raspberry Pi is connected to the network
3. Check service status with `check_services` from the utilities script
4. See the detailed troubleshooting guide in the `docs/troubleshooting.md` file

## Next Steps

Now that your basic homelab is set up, consider:

1. Changing default passwords (especially for Pi-hole)
2. Setting up HTTPS for more security
3. Adding more services to your homelab
4. Creating regular backups of your configuration

For more information, see the README.md and documentation in the docs/ directory.
