#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
cmd=(up -d)
if [[ "$0" == *"stop.sh" ]]; then
  cmd=(down)
fi

files=(./*/compose.yaml)
if [[ "${#files[@]}" -eq 0 ]]; then
  echo "No compose files found" >&2
  exit 1
fi

for file in "${files[@]}"; do
  dir="$(dirname -- "$file")"
  pushd "$dir" >/dev/null || continue
  docker compose "${cmd[@]}"
  popd >/dev/null
done
