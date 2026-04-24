#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
codex_home="${CODEX_HOME:-$HOME/.codex}"
skills_dir="$codex_home/skills"
backup_root="$codex_home/skill-backups/$(date +%Y%m%d-%H%M%S)"

mkdir -p "$skills_dir"

linked_count=0
skipped_count=0
backup_count=0

for skill_path in "$repo_root"/*; do
  [ -d "$skill_path" ] || continue
  [ -f "$skill_path/SKILL.md" ] || continue

  skill_name="$(basename "$skill_path")"
  target_path="$skills_dir/$skill_name"

  if [ -L "$target_path" ]; then
    resolved_target="$(readlink "$target_path")"
    if [ "$resolved_target" = "$skill_path" ]; then
      printf 'skip  %s already linked\n' "$skill_name"
      skipped_count=$((skipped_count + 1))
      continue
    fi
  fi

  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    mkdir -p "$backup_root"
    mv "$target_path" "$backup_root/$skill_name"
    printf 'backup %s -> %s\n' "$skill_name" "$backup_root/$skill_name"
    backup_count=$((backup_count + 1))
  fi

  ln -s "$skill_path" "$target_path"
  printf 'link  %s -> %s\n' "$skill_name" "$skill_path"
  linked_count=$((linked_count + 1))
done

printf '\nDone. linked=%d skipped=%d backups=%d\n' \
  "$linked_count" "$skipped_count" "$backup_count"
printf 'Restart Codex to pick up newly added skills.\n'
