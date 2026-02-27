#!/usr/bin/env bash
set -euo pipefail
set -x
output_file="${1:?You must provide an output file}"
interval="${2:-30}"

DOMAIN_LABEL="caddy"
INTERFACE=tailscale0

# Needs: docker, ip, awk, cut, bash

go() {
  ids=()
  if ! read -r -a ids -d '' < <(docker container ls --filter "label=$DOMAIN_LABEL" --format '{{ .ID }}' --no-trunc); then
    printf "%s\n" 'No containers found with label %s' "$DOMAIN_LABEL" >&2
    return 1
  fi
  # Get ip, then remove subnet from the end
  ips=()
  if ! read -r -a ips -d '' < <(ip addr show dev "$INTERFACE" scope global | awk '/inet[0-9]*/{print $2}' | cut -d/ -f1); then
    printf '%s\n' 'No IPs found for %s' "$INTERFACE" >&2
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
  # write all at once to avoid dnsmasq reading partial files
  printf '%s\n' "$contents" >"$output_file"
  sleep "$interval"
done
