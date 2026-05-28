#!/usr/bin/env bash
# Original Source: https://medium.com/@svenvanginkel/automating-dependabot-for-docker-compose-13acdff61133
set -euC

tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT
# File Header
cat >|"$tmpfile" <<'YAML'
# This is a generated file. Please do not edit it directly. Edit ./generate-dependabot.sh instead.
version: 2
updates:
  - package-ecosystem: "gitsubmodule"
    schedule:
      interval: "daily"
    directory: "/"
YAML

# Find and sort all docker-compose.yml directories
readarray -t -d '' composes < <(find . -regex '.*/\(docker-\)?compose\(-[\w]+\)?\(?>\.[\w-]+\)?\.ya?ml' -print0)
if [ "${#composes[@]}" -gt 0 ]; then
  # Header
  cat <<'YAML'
  - package-ecosystem: "docker-compose"
    schedule:
      interval: "daily"
    directories:
YAML
  for file in "${composes[@]}"; do
    d=$(dirname -- "$file")
    printf '      - "%s"\n' "/${d#"./"}" # remove leading ./; replace with /
  done | sort
fi >>"$tmpfile"

# Find and sort all Dockerfile directories
readarray -t -d '' dockerfiles < <(find . -iname 'Dockerfile' -print0)
if [ "${#dockerfiles[@]}" -gt 0 ]; then
  # Header
  cat <<'YAML'
  - package-ecosystem: "docker"
    schedule:
      interval: "daily"
    directories:
YAML
  for file in "${dockerfiles[@]}"; do
    d=$(dirname -- "$file")
    printf '      - "%s"\n' "/${d#"./"}" # remove leading ./; replace with /
  done | sort
fi >>"$tmpfile"

if [ "${#composes[@]}" -eq 0 ] && [ "${#dockerfiles[@]}" -eq 0 ]; then
  echo "ℹ️ No docker-compose.yml or Dockerfile files found."
  echo >|"$tmpfile"
fi

# Install if changed
if ! [ -f .github/dependabot.yml ] || ! cmp -s "$tmpfile" .github/dependabot.yml; then
  mv "$tmpfile" .github/dependabot.yml
  echo "✅ Updated .github/dependabot.yml!"
else
  echo "ℹ️ No changes to .github/dependabot.yml."
fi
