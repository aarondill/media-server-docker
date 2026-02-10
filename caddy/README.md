## Reverse proxy

Be sure to set DNS records for the domain you're using.
If using pihole, you can add local _and_ tailscale entries and it will resolve the right one.
For external use, set the DNS record to the tailscale IP.

Note: for some reason, when building caddy-docker-proxy, it requires you set the docker min-api-version

```bash
echo '{ "min-api-version": "1.41" }' | sudo tee /etc/docker/daemon.json && sudo systemctl restart docker
```
