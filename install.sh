#!/usr/bin/env bash
# Install this repo's skills into agent skill directories.
# Usage: ./install.sh --to agents,claude [--dest DIR]
# Symlinks each skills/<name> into <dest>/.agents/skills/<name> and/or
# <dest>/.claude/skills/<name>. Never overwrites anything it did not create.
set -eu

repo=$(cd "$(dirname "$0")" && pwd)
to="agents"
dest="$PWD"

while [ $# -gt 0 ]; do
  case "$1" in
    --to) to="${2:-}"; shift 2 ;;
    --dest) dest="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,5p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

[ -d "$dest" ] || { echo "no such dest: $dest" >&2; exit 2; }

installed=0
for dir in "$repo"/skills/*/; do
  name=$(basename "$dir")
  src="${dir%/}"
  for target in $(echo "$to" | tr ',' ' '); do
    case "$target" in
      agents) sub=".agents/skills" ;;
      claude) sub=".claude/skills" ;;
      *) echo "unknown target: $target" >&2; exit 2 ;;
    esac
    link="$dest/$sub/$name"
    if [ -e "$link" ] || [ -L "$link" ]; then
      if [ -L "$link" ] && [ "$(readlink "$link")" = "$src" ]; then
        echo "ok $link"
        continue
      fi
      echo "refusing: $link exists" >&2
      exit 1
    fi
    mkdir -p "$dest/$sub"
    ln -s "$src" "$link"
    echo "linked $link"
    installed=$((installed+1))
  done
done

echo "$installed installed"
