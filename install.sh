#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
codex_home="${CODEX_HOME:-$HOME/.codex}"
skills_dir="$codex_home/skills"
backup_root="$codex_home/skill-backups/$(date +%Y%m%d-%H%M%S)"
prune=false

if [ "${1:-}" = "--prune" ]; then
  prune=true
elif [ "${1:-}" != "" ]; then
  printf 'Usage: %s [--prune]\n' "$(basename "$0")" >&2
  exit 1
fi

mkdir -p "$skills_dir"

linked_count=0
skipped_count=0
backup_count=0
pruned_count=0

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

if [ "$prune" = true ]; then
  for target_path in "$skills_dir"/*; do
    [ -L "$target_path" ] || continue
    resolved_target="$(readlink "$target_path")"
    case "$resolved_target" in
      "$repo_root"/*)
        if [ ! -e "$resolved_target" ]; then
          rm "$target_path"
          printf 'prune %s\n' "$(basename "$target_path")"
          pruned_count=$((pruned_count + 1))
        fi
        ;;
    esac
  done
fi

printf '\nDone. linked=%d skipped=%d backups=%d pruned=%d\n' \
  "$linked_count" "$skipped_count" "$backup_count" "$pruned_count"
printf 'Restart Codex to pick up newly added skills.\n'
