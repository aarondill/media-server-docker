# Media Server Setup W/ Docker

An attempt to containerize my media server setup.

See [rpi-docker](https://github.com/aarondill/rpi-docker) for my Raspberry Pi setup. Note that these could be used on the same machine, but make sure not to run the Tailscale container twice.

## Setup

1. Install Docker and Docker Compose
2. Clone this repo: `git clone --recurse-submodules https://github.com/aarondill/media-server-docker.git`
3. Set environment variables in `.env.local`. See `.env.schema` for a list of variables. You can also run `./env.sh` and it will tell you what is missing.
   - You can either set each stack's variables in `stack/.env.local` or set them in the root `.env.local`
   - Stack level variables will override root level variables
4. Install [`varlock`](https://varlock.dev/getting-started/installation/) (or npm/pnpm) for environment variable management
5. Run `./env.sh` to set up the environment variables for each stack (re-run this if you change a variable!)
6. Run `./start.sh` to start all the containers
   - You can also run `docker-compose up` in each directory to start each of the containers

## Manual Setup

### Note

Some containers might need additional setup (i.e. Tailscale). Check the README in each directory for more information.

### Important!

Read extra setup in each directory's README.

## See Also

Enable wifi on startup: https://gist.github.com/aarondill/b0448c5482c706eb56b311caf1fdd261
Start tmux on ssh login: https://gist.github.com/aarondill/6378184559e6590a0ba31ec3733efb95
