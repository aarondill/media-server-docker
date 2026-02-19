#!/usr/bin/env bash
shopt -s nullglob
files=(*/compose.yaml)
args=()
for f in "${files[@]}"; do
  args+=(-f "$f")
done
docker compose "${args[@]}" pull
