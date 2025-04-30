# Docker Compose Tutorial

## Basic Structure

```yaml
version: '3.8'
services:
  app:
    image: your-image:latest
    build: ./app
    ports:
      - "8080:80"  # Host:Container
    environment:
      - ENV_VAR=value
    volumes:
      - ./data:/data
    networks:
      - your-net

networks:
  your-net:
    driver: bridge

volumes:
  data:
```

### Key Sections

- `services:`: Define each container (name, image/build, ports, env, volumes)
- `ports:`: Map host ports to container ports (`HOST:CONTAINER`)
- `volumes:`: Persist data and share files
- `networks:`: Isolate or connect services
- `depends_on:`: Control startup order

## Common Commands

```bash
# Start all services
docker compose up -d

# Stop all services
docker compose down

# View logs
docker compose logs -f

# Restart a service
docker compose restart <service>

# Run a one-off command
docker compose run --rm <service> <cmd>
```

## Tips & Tricks

- Use `profiles:` to conditionally enable services
- Leverage `.env` files for environment variables
- Keep `docker-compose.yml` DRY with `x-` anchors
- Use `healthcheck:` to ensure dependencies are ready

---
*This tutorial is part of your Homelab documentation.*
