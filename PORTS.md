# Port Usage Reference Guide

This document helps you track which ports are in use by different services in your homelab. Maintaining this reference will help you avoid port conflicts when adding new services.

## Currently Used Ports in Template

| Port | Protocol | Service | Description |
|------|----------|---------|-------------|
| 53   | TCP/UDP  | Pi-hole | DNS service |
| 80   | TCP      | Nginx   | HTTP web server |
| 443  | TCP      | Nginx   | HTTPS web server (when configured) |
| 3000 | TCP      | OpenSpeedTest | Web interface (HTTP) |
| 3001 | TCP      | OpenSpeedTest | Web interface (HTTPS) |
| 8080 | TCP      | Pi-hole | Web administration interface |
| 9000 | TCP      | Portainer | Docker management interface |

## Common Reserved Ports

These ports are commonly used for specific services. Be aware of these when planning your homelab:

| Port Range | Common Usage |
|------------|--------------|
| 1-1023     | Well-known/system ports (require root privileges) |
| 22         | SSH server |
| 25         | SMTP (email) |
| 53         | DNS |
| 80         | HTTP |
| 123        | NTP (time synchronization) |
| 443        | HTTPS |
| 1194       | OpenVPN |
| 1433       | Microsoft SQL Server |
| 1723       | PPTP VPN |
| 3306       | MySQL/MariaDB |
| 3389       | Remote Desktop Protocol (RDP) |
| 5432       | PostgreSQL |
| 8080       | Alternative HTTP (often for proxies or admin interfaces) |
| 8443       | Alternative HTTPS |
| 9090-9093  | Prometheus metrics |
| 51820      | WireGuard VPN |

## Your Homelab Port Allocations

Use this table to track the ports you've allocated for your services. Update it whenever you add a new service:

| Port | Protocol | Service | Description | Date Added |
|------|----------|---------|-------------|------------|
| 53   | TCP/UDP  | Pi-hole | DNS service | (initial setup) |
| 80   | TCP      | Nginx   | HTTP web server | (initial setup) |
| 443  | TCP      | Nginx   | HTTPS web server | (initial setup) |
| 3000 | TCP      | OpenSpeedTest | Web interface (HTTP) | (initial setup) |
| 3001 | TCP      | OpenSpeedTest | Web interface (HTTPS) | (initial setup) |
| 8080 | TCP      | Pi-hole | Web administration interface | (initial setup) |
| 9000 | TCP      | Portainer | Docker management interface | (initial setup) |
| ...  | ...      | ...     | ... | ... |

## Port Assignment Best Practices

1. **Avoid Default Ports for Public Services**: If your services are exposed to the internet, consider using non-standard ports to reduce automated scanning traffic.

2. **Group Similar Services**: Assign ports in logical groups (e.g., 9000-9010 for development tools, 8000-8010 for web applications).

3. **Document Everything**: Always update this file when you add a new service or change a port.

4. **Check for Conflicts**: Before assigning a new port, verify it's not already in use:
   ```bash
   sudo netstat -tulpn | grep <port>
   ```

5. **Use Higher Port Numbers**: User-defined services should generally use ports above 1024 to avoid requiring elevated privileges.

6. **Consider Reserved Ranges**: Some applications reserve ranges of ports for internal use.

7. **Consistent Numbering Scheme**: Consider a pattern for your services, such as:
   - 3xxx for databases
   - 8xxx for web interfaces
   - 9xxx for monitoring

8. **Firewall Rules**: Remember to update your firewall rules when changing ports:
   ```bash
   sudo ufw allow <port>/tcp
   ```

## Docker Port Mapping References

When using Docker, remember that ports are specified as `HOST:CONTAINER`. For example:

```yaml
ports:
  - "8080:80"  # Maps port 80 in the container to port 8080 on the host
```

Example in docker-compose.yml:

```yaml
services:
  webapp:
    image: nginx
    ports:
      - "8080:80"   # Web on 8080
      - "8443:443"  # SSL on 8443
```

## Checking Ports in Use

To see which ports are currently in use on your Raspberry Pi:

```bash
# Show all listening TCP ports
sudo netstat -tuln

# Show all processes using ports
sudo netstat -tulpn

# Check if a specific port is in use
sudo netstat -tuln | grep <port>
```
