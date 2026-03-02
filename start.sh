#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
cmd=(up -d "$@")
if [[ "$0" == *"stop.sh" ]]; then
  cmd=(down "$@")
fi

files=(./*/compose.yaml)
if [[ "${#files[@]}" -eq 0 ]]; then
  echo "No compose files found" >&2
  exit 1
fi

# Most services require caddy network, so create it first
if [ "${cmd[0]}" = up ]; then
  # Check if it exists first
  if ! docker network inspect caddy &>/dev/null; then
    echo "> Creating caddy network"
    docker network create caddy --ipv6
  fi
fi

for file in "${files[@]}"; do
  dir="$(dirname -- "$file")"
  pushd "$dir" >/dev/null || continue
  run=(docker compose "${cmd[@]}")
  echo "> $dir :->: ${run[*]@Q}"
  "${run[@]}"
  popd >/dev/null
done

if [ "${cmd[0]}" = down ]; then
  if docker network inspect caddy &>/dev/null; then
    echo "> Removing caddy network"
    docker network rm -f caddy 2>/dev/null
  fi
fi
