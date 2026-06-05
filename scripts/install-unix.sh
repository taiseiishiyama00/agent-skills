#!/usr/bin/env sh
set -eu

target="${1:-"$HOME/.agent-skills"}"
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
repo_root="$(CDPATH= cd -- "$script_dir/.." && pwd)"

printf 'Source: %s\n' "$repo_root"
printf 'Target: %s\n' "$target"

if [ -e "$target" ] || [ -L "$target" ]; then
  if [ -L "$target" ]; then
    rm "$target"
  else
    backup="$target.backup-$(date +%Y%m%d-%H%M%S)"
    mv "$target" "$backup"
    printf 'Backed up existing target to: %s\n' "$backup"
  fi
fi

ln -s "$repo_root" "$target"
printf 'Installed Agent Skills link.\n'
printf 'Restart Codex or the target AI agent so it reloads skills.\n'
