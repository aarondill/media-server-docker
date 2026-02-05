# Media Server Setup W/ Docker

An attempt to containerize my media server setup.

See [rpi-docker](https://github.com/aarondill/rpi-docker) for my Raspberry Pi setup. Note that these could be used on the same machine, but make sure not to run the Tailscale container twice.

## Setup

1. Install Docker and Docker Compose
2. Clone this repo: `git clone --recurse-submodules https://github.com/aarondill/media-server-docker.git`
3. run `cp .env.example .env` and edit `.env`
4. Run `./start.sh` to start all the containers
   - You can also run `docker-compose up` in each directory to start each of the containers

## Manual Setup

### Note

Some containers might need additional setup (i.e. Tailscale). Check the README in each directory for more information.

### Important!

Read extra setup in each directory's README.

- [Tailscale](./tailscale/README.md)
