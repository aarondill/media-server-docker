# Jellyfin

A docker configuration for running Jellyfin in a container.

1. Install Docker and docker-compose: [Instructions](https://docs.docker.com/engine/install/)
2. Set environment variables in `.env`
3. Run `docker-compose up -d`

## Backup

The configuration and database are stored in `./config/`. To back up or replicate, copy this directory.

## Cache

The Jellyfin cache is stored in `./cache/`. To clear the cache, delete this directory.
