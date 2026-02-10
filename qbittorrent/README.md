# Qbittorrent with Gluetun

This is a docker compose file for running qbittorrent with gluetun.

It's been tested with ProtonVPN, but should work with any VPN given slight modifications.

You should set your webui password in the settings

1. Go to Settings > Web UI
2. Input your new password in the "WebUI Password" field
3. Check "Bypass authentication for clients on localhost" (required for gluetun)
4. Disable authentication (optional)
   1. Check "Bypass authentication for clients in whitelisted IP subnets"
   2. Input 172.16.0.0/12 in the "Whitelisted IP subnets" field
   3. NOTE: This disables authentication for all IPs, since qbittorrent just sees the docker network!

### VueTorrent

This docker compose uses the VueTorrent mod, so you'll need to enable it in your qBittorrent settings.

1. Go to Settings > Web UI
2. Check "Use Alternative Web UI"
3. Input "/vuetorrent" in the "Alternative Web UI Path" field
