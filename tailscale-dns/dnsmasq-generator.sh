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
    echo "No containers found with label $DOMAIN_LABEL"
    return
  fi
  # Get ip, then remove subnet from the end
  ips=()
  if ! read -r -a ips -d '' < <(ip addr show dev "$INTERFACE" scope global | awk '/inet[0-9]*/{print $2}' | cut -d/ -f1); then
    echo "No IPs found for $INTERFACE"
    return
  fi

  res=()
  for id in "${ids[@]}"; do
    domain=$(docker inspect "$id" -f "{{.Config.Labels.$DOMAIN_LABEL}}")
    for ip in "${ips[@]}"; do
      # append to res
      printf -v "res[${#res[@]}]" '%-26s\t%s' "$ip" "$domain"
    done
  done
  # write all at once to avoid dnsmasq reading partial files
  printf '%s\n' "${res[@]}" >"$output_file"
}

while true; do
  go
  sleep "$interval"
done
