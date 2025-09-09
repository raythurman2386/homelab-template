# Nginx Configuration Guide

This guide explains how to organize and scale your Nginx configurations for multiple services in your Raspberry Pi homelab. **Note:** This template uses Cloudflare Tunnel by default for reverse proxy functionality. Nginx is provided as an optional alternative.

## Configuration Structure

The Nginx configuration in this template follows a modular approach:

- **Main Configuration**: `nginx.conf` contains global settings
- **Service Configurations**: Individual `.conf` files in `conf.d/` directory
- **Default Site**: `default.conf` serves as the fallback site

## When to Use Nginx vs Cloudflare Tunnel

- **Use Nginx** if you want full control over your reverse proxy and prefer local network access
- **Use Cloudflare Tunnel** (default) for secure remote access without exposing ports publicly

To switch to Nginx:
1. Comment out the `cloudflared` service in `docker-compose.yml`
2. Uncomment the `nginx` service in `docker-compose.yml`
3. Configure your DNS or hosts file for local access

## How It Works

When Nginx starts, it:

1. Reads the main `nginx.conf` file
2. Loads all `.conf` files from the `conf.d/` directory (alphabetically)
3. Each file can define one or more `server` blocks

## Benefits of This Approach

- **Modularity**: Each service has its own configuration file
- **Maintainability**: Easier to manage, backup, and version control
- **Scalability**: Add new services without modifying existing configurations
- **Organization**: Clear separation of concerns

## Adding a New Service

To add a new service to your Nginx configuration:

1. Copy the template: `cp service-template.conf.example yourservice.conf`
2. Edit the new file to configure your service
3. Restart Nginx: `docker restart nginx`

## Configuration Types

### 1. Path-Based Routing

Access services via URL paths (e.g., `http://your-pi-ip/service/`)

```nginx
server {
    listen 80;
    server_name _;
    
    location /yourservice/ {
        proxy_pass http://yourservice:8080/;
        # proxy settings...
    }
}
```

### 2. Domain-Based Routing

Access services via subdomains (e.g., `http://service.yourdomain.com`)

```nginx
server {
    listen 80;
    server_name yourservice.yourdomain.com;
    
    location / {
        proxy_pass http://yourservice:8080/;
        # proxy settings...
    }
}
```

## Example Files in This Template

- **default.conf**: Serves the main dashboard, handles default requests
- **pihole.conf**: Configuration for Pi-hole admin interface
- **service-template.conf.example**: Template for adding new services

## Common Proxy Settings

```nginx
# Basic proxy settings needed by most services
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;

# For WebSocket support
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";

# For long-running connections
proxy_read_timeout 3600s;
proxy_send_timeout 3600s;
```

## SSL/HTTPS Configuration

To add HTTPS support:

1. Obtain SSL certificates (e.g., using Let's Encrypt)
2. Mount certificates into Nginx container
3. Add SSL configuration to your server blocks:

```nginx
server {
    listen 80;
    server_name yourservice.yourdomain.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name yourservice.yourdomain.com;
    
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    
    location / {
        proxy_pass http://yourservice:8080/;
        # proxy settings...
    }
}
```

## Debugging Nginx Configurations

To test your Nginx configuration:

```bash
docker exec nginx nginx -t
```

To view Nginx logs:

```bash
docker logs nginx
```

## Further Customization

As your homelab grows, consider:

- Setting up a unified authentication system
- Implementing rate limiting for security
- Using Nginx caching for better performance
- Creating a more advanced dashboard with service status
