#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf 'Usage: %s [--check] [--prune]\n' "$(basename "$0")" >&2
}

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
codex_home="${CODEX_HOME:-$HOME/.codex}"
skills_dir="$codex_home/skills"
backup_root="$codex_home/skill-backups/$(date +%Y%m%d-%H%M%S)"
check=false
prune=false

for arg in "$@"; do
  case "$arg" in
    --check)
      check=true
      ;;
    --prune)
      prune=true
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

if [ "$check" = false ]; then
  mkdir -p "$skills_dir"
fi

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
    if [ "$check" = true ]; then
      printf 'would backup %s -> %s\n' "$skill_name" "$backup_root/$skill_name"
    else
      mkdir -p "$backup_root"
      mv "$target_path" "$backup_root/$skill_name"
      printf 'backup %s -> %s\n' "$skill_name" "$backup_root/$skill_name"
    fi
    backup_count=$((backup_count + 1))
  fi

  if [ "$check" = true ]; then
    printf 'would link %s -> %s\n' "$skill_name" "$skill_path"
  else
    ln -s "$skill_path" "$target_path"
    printf 'link  %s -> %s\n' "$skill_name" "$skill_path"
  fi
  linked_count=$((linked_count + 1))
done

if [ "$prune" = true ] && [ -d "$skills_dir" ]; then
  for target_path in "$skills_dir"/*; do
    [ -L "$target_path" ] || continue
    resolved_target="$(readlink "$target_path")"
    case "$resolved_target" in
      "$repo_root"/*)
        if [ ! -d "$resolved_target" ] || [ ! -f "$resolved_target/SKILL.md" ]; then
          if [ "$check" = true ]; then
            printf 'would prune %s\n' "$(basename "$target_path")"
          else
            rm "$target_path"
            printf 'prune %s\n' "$(basename "$target_path")"
          fi
          pruned_count=$((pruned_count + 1))
        fi
        ;;
    esac
  done
fi

printf '\nDone. linked=%d skipped=%d backups=%d pruned=%d\n' \
  "$linked_count" "$skipped_count" "$backup_count" "$pruned_count"

if [ "$check" = true ]; then
  printf 'Check mode only: no Codex skill links were changed.\n'
else
  printf 'Restart Codex to pick up newly added skills.\n'
fi
