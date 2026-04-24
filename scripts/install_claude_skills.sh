#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf 'Usage: %s [--check] [--prune]\n' "$(basename "$0")" >&2
}

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
generated_dir="$repo_root/generated/claude-commands"
claude_home="${CLAUDE_HOME:-$HOME/.claude}"
commands_dir="$claude_home/commands"
backup_root="$claude_home/command-backups/$(date +%Y%m%d-%H%M%S)"
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
  mkdir -p "$commands_dir"
fi

linked_count=0
skipped_count=0
backup_count=0
pruned_count=0

if [ -d "$generated_dir" ]; then
  for command_path in "$generated_dir"/*.md; do
    [ -e "$command_path" ] || continue

    command_name="$(basename "$command_path")"
    target_path="$commands_dir/$command_name"

    if [ -L "$target_path" ]; then
      resolved_target="$(readlink "$target_path")"
      if [ "$resolved_target" = "$command_path" ]; then
        printf 'skip  %s already linked\n' "$command_name"
        skipped_count=$((skipped_count + 1))
        continue
      fi
    fi

    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
      if [ "$check" = true ]; then
        printf 'would backup %s -> %s\n' "$command_name" "$backup_root/$command_name"
      else
        mkdir -p "$backup_root"
        mv "$target_path" "$backup_root/$command_name"
        printf 'backup %s -> %s\n' "$command_name" "$backup_root/$command_name"
      fi
      backup_count=$((backup_count + 1))
    fi

    if [ "$check" = true ]; then
      printf 'would link %s -> %s\n' "$command_name" "$command_path"
    else
      ln -s "$command_path" "$target_path"
      printf 'link  %s -> %s\n' "$command_name" "$command_path"
    fi
    linked_count=$((linked_count + 1))
  done
fi

if [ "$prune" = true ] && [ -d "$commands_dir" ]; then
  for target_path in "$commands_dir"/*.md; do
    [ -L "$target_path" ] || continue
    resolved_target="$(readlink "$target_path")"
    case "$resolved_target" in
      "$generated_dir"/*)
        if [ ! -f "$resolved_target" ]; then
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
  printf 'Check mode only: no Claude command links were changed.\n'
else
  printf 'Restart Claude Code to pick up newly added commands if needed.\n'
fi
