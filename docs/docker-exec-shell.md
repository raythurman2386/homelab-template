# Docker Exec & Shell Access

Use `docker exec` to run commands inside a running container.

## Interactive Shell

```bash
# Bash shell
docker exec -it <container_name> /bin/bash

# Alpine containers
docker exec -it <container_name> /bin/sh
```

## Run One-Off Commands

```bash
docker exec <container_name> <command>
# e.g.
docker exec myapp ls -al /app
```

## Running as Specific User

```bash
docker exec -u root -it <container_name> /bin/bash
```

## Copy Files Between Host and Container

```bash
docker cp <container_name>:/path/in/container /path/on/host
docker cp /path/on/host <container_name>:/path/in/container
```

## Exiting the Shell

Type `exit` or press `Ctrl+D`.

## Tips

- Use `--privileged` if you need elevated permissions.
- Combine `docker logs` and `docker exec` to debug services.
- In CI/CD, use `docker exec` to run migrations or tests inside containers.
