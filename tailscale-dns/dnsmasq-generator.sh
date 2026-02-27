#!/usr/bin/env bash
output_file="${1:-$HOST_FILE}"
interval="${2:-30}"
if [ -z "$output_file" ]; then
  printf '%s\n' 'You must provide an output file or set the HOST_FILE environment variable' >&2
  exit 2
fi

DOMAIN_LABEL="caddy"
INTERFACE=tailscale0

# Needs: docker, ip, awk, cut, bash

go() {
  ids=()
  mapfile -t ids < <(docker container ls --filter "label=$DOMAIN_LABEL" --format "{{ .ID }}" --no-trunc)
  if [ "${#ids[@]}" -eq 0 ]; then
    printf 'No containers found with label %s\n' "$DOMAIN_LABEL" >&2
    return 1
  fi
  # Get ip, then remove subnet from the end
  ips=()
  mapfile -t ips < <(ip addr show dev "$INTERFACE" scope global | awk '/inet[0-9]*/{print $2}' | cut -d/ -f1)
  if [ "${#ips[@]}" -eq 0 ]; then
    printf 'No IPs found for %s\n' "$INTERFACE" >&2
    return 1
  fi
  for id in "${ids[@]}"; do
    domain=$(docker inspect "$id" -f "{{.Config.Labels.$DOMAIN_LABEL}}")
    for ip in "${ips[@]}"; do
      printf '%-26s\t%s\n' "$ip" "$domain"
    done
  done
}

while true; do
  # write even if it returns 1, since this means we don't want any entries
  contents=$(go) || true
  current=$(cat "$output_file" 2>/dev/null || true)
  if [ "$contents" != "$current" ]; then
    # write all at once to avoid dnsmasq reading partial files
    printf '%s\n' "$contents" >"$output_file"
    printf 'Wrote %s\n' "$output_file" >&2
  fi
  sleep "$interval"
done
