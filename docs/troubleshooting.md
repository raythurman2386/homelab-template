# Troubleshooting Guide

This guide covers common issues you might encounter with your Raspberry Pi homelab and how to resolve them.

## Docker Issues

### Container Won't Start

**Symptoms:** Docker container fails to start or exits immediately after starting.

**Solutions:**

1. Check container logs:
   ```bash
   docker logs [container_name]
   ```

2. Check for port conflicts:
   ```bash
   sudo netstat -tulpn | grep [port_number]
   ```

3. Check for disk space issues:
   ```bash
   df -h
   ```

4. Verify docker-compose file syntax:
   ```bash
   docker compose config
   ```

### Docker Service Not Starting

**Symptoms:** Docker service fails to start.

**Solutions:**

1. Check Docker service status:
   ```bash
   sudo systemctl status docker
   ```

2. Check system logs:
   ```bash
   sudo journalctl -u docker
   ```

3. Try restarting Docker:
   ```bash
   sudo systemctl restart docker
   ```

4. Reinstall Docker if necessary:
   ```bash
   sudo ./scripts/setup-docker.sh
   ```

## Network Issues

### Pi-hole Not Blocking Ads

**Symptoms:** Ads still appearing despite Pi-hole running.

**Solutions:**

1. Verify Pi-hole is running:
   ```bash
   docker ps | grep pihole
   ```

2. Check if your devices are using Pi-hole for DNS:
   - Configure your router to use Pi-hole as the DNS server, or
   - Manually set DNS on each device to your Raspberry Pi's IP

3. Check Pi-hole logs:
   ```bash
   docker logs pihole
   ```

4. Verify Pi-hole's blocklists are updated:
   - Go to Pi-hole admin interface
   - Go to Tools > Update Gravity

### Cannot Access Web Interfaces

**Symptoms:** Cannot access Pi-hole admin or other web interfaces.

**Solutions:**

1. Check container status:
   ```bash
   docker ps
   ```

2. Verify the ports are correctly mapped:
   ```bash
   docker port [container_name]
   ```

3. Check firewall settings:
   ```bash
   sudo ufw status
   ```

4. Try accessing via IP address directly rather than hostname

## System Issues

### Raspberry Pi Running Slowly

**Symptoms:** System response is sluggish or services take a long time to respond.

**Solutions:**

1. Check system load:
   ```bash
   top
   ```

2. Check for overheating:
   ```bash
   vcgencmd measure_temp
   ```

3. Check for memory issues:
   ```bash
   free -h
   ```

4. Consider adding or increasing swap space:
   ```bash
   sudo ./scripts/setup-system.sh
   ```

### Raspberry Pi Won't Boot

**Symptoms:** Pi doesn't boot up correctly, no display or network access.

**Solutions:**

1. Check power supply - ensure it provides enough power for your Pi model
2. Inspect the SD card for physical damage
3. Try re-imaging the SD card with Raspberry Pi OS
4. Check HDMI connection and try an alternative display

## Nginx Issues (If Using Nginx)

### 502 Bad Gateway Error

**Symptoms:** Nginx shows a 502 Bad Gateway error when trying to access services.

**Solutions:**

1. Check if the upstream service is running:
   ```bash
   docker ps
   ```

2. Verify the upstream service name and port in Nginx configuration:
   ```bash
   cat docker/nginx/conf.d/*.conf
   ```

3. Check Nginx logs:
   ```bash
   docker logs nginx
   ```

4. Ensure containers are on the same network:
   ```bash
   docker network inspect homelab
   ```

## Cloudflare Tunnel Issues

### Tunnel Not Connecting

**Symptoms:** Cloudflare tunnel fails to start or connect.

**Solutions:**

1. Check tunnel token:
   ```bash
   echo $TUNNEL_TOKEN
   ```

2. Verify tunnel credentials:
   ```bash
   docker logs cloudflare-tunnel
   ```

3. Check Cloudflare dashboard for tunnel status
4. Ensure your domain DNS is configured correctly

### Services Not Accessible via Cloudflare

**Symptoms:** Services work locally but not through Cloudflare domain.

**Solutions:**

1. Check tunnel logs:
   ```bash
   docker logs cloudflare-tunnel
   ```

2. Verify DNS records in Cloudflare dashboard
3. Ensure tunnel configuration matches your services
4. Check if services are running on correct ports

### SSL Certificate Issues (If Using Nginx)

**Symptoms:** SSL warnings or errors in browser.

**Solutions:**

1. Check if certificates exist:
   ```bash
   ls -la docker/nginx/ssl/
   ```

2. Verify certificate permissions:
   ```bash
   chmod 644 docker/nginx/ssl/*.pem
   ```

3. Check certificate expiration:
   ```bash
   openssl x509 -enddate -noout -in docker/nginx/ssl/cert.pem
   ```

4. Renew certificates if needed:
   ```bash
   certbot renew
   ```

**Note:** If using Cloudflare Tunnel, SSL is handled automatically by Cloudflare.

## Backup and Recovery

### Backing Up Pi-hole Settings

To back up Pi-hole settings:

```bash
source scripts/utilities.sh
backup_volumes
```

### Recovering Pi-hole Settings

To restore Pi-hole settings from backup:

```bash
source scripts/utilities.sh
restore_volume pihole_config /path/to/backup/pihole_config-date.tar.gz
```

## Getting Help

If you encounter issues not covered in this guide:

1. Check the project's GitHub issue tracker
2. Search the Raspberry Pi forums
3. Check Docker documentation for container-specific issues
4. Check Pi-hole, Nginx (if used), or Cloudflare documentation for service-specific issues

Remember to provide detailed information when seeking help, including:
- Error messages
- Container logs
- System specifications
- Steps you've already tried
