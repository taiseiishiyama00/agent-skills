#!/usr/bin/env sh
set -eu

codex_target="${1:-"$HOME/.agent-skills"}"
claude_target="${2:-"$HOME/.claude/skills"}"
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
repo_root="$(CDPATH= cd -- "$script_dir/.." && pwd)"

install_skills_link() {
  name="$1"
  target="$2"
  parent_dir="$(dirname -- "$target")"

  printf '%s target: %s\n' "$name" "$target"

  if [ ! -d "$parent_dir" ]; then
    mkdir -p "$parent_dir"
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ -L "$target" ]; then
      rm "$target"
    else
      backup="$target.backup-$(date +%Y%m%d-%H%M%S)"
      mv "$target" "$backup"
      printf 'Backed up existing %s target to: %s\n' "$name" "$backup"
    fi
  fi

  ln -s "$repo_root" "$target"
  printf 'Installed %s skills link.\n' "$name"
}

printf 'Source: %s\n' "$repo_root"
install_skills_link "Codex" "$codex_target"
install_skills_link "Claude Code" "$claude_target"
printf 'Restart Codex and Claude Code so they reload skills.\n'
