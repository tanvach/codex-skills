#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf 'Usage: %s [--check]\n' "$(basename "$0")" >&2
}

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output_dir="$repo_root/generated/claude-desktop-skills"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/claude-desktop-skills.XXXXXX")"
check=false

for arg in "$@"; do
  case "$arg" in
    --check)
      check=true
      ;;
    *)
      usage
      rm -rf "$tmp_dir"
      exit 1
      ;;
  esac
done

cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

if ! command -v zip >/dev/null 2>&1; then
  printf 'error: zip is required to package Claude Desktop skills\n' >&2
  exit 1
fi

created_count=0
updated_count=0
skipped_count=0
removed_count=0

for skill_path in "$repo_root"/*; do
  [ -d "$skill_path" ] || continue
  [ -f "$skill_path/SKILL.md" ] || continue

  skill_name="$(basename "$skill_path")"
  output_file="$tmp_dir/$skill_name.zip"

  (
    cd "$repo_root"
    zip -X -qr "$output_file" "$skill_name" \
      -x "$skill_name/.DS_Store" "$skill_name/**/.DS_Store"
  )

  dest_file="$output_dir/$skill_name.zip"
  if [ ! -e "$dest_file" ]; then
    if [ "$check" = true ]; then
      printf 'would create %s\n' "$dest_file"
    else
      mkdir -p "$output_dir"
      cp "$output_file" "$dest_file"
      printf 'create %s\n' "$dest_file"
    fi
    created_count=$((created_count + 1))
    continue
  fi

  if cmp -s "$output_file" "$dest_file"; then
    printf 'skip   %s unchanged\n' "$dest_file"
    skipped_count=$((skipped_count + 1))
    continue
  fi

  if [ "$check" = true ]; then
    printf 'would update %s\n' "$dest_file"
  else
    cp "$output_file" "$dest_file"
    printf 'update %s\n' "$dest_file"
  fi
  updated_count=$((updated_count + 1))
done

if [ -d "$output_dir" ]; then
  for existing_file in "$output_dir"/*.zip; do
    [ -e "$existing_file" ] || continue
    if [ ! -e "$tmp_dir/$(basename "$existing_file")" ]; then
      if [ "$check" = true ]; then
        printf 'would remove %s\n' "$existing_file"
      else
        rm "$existing_file"
        printf 'remove %s\n' "$existing_file"
      fi
      removed_count=$((removed_count + 1))
    fi
  done
fi

printf '\nDone. created=%d updated=%d skipped=%d removed=%d\n' \
  "$created_count" "$updated_count" "$skipped_count" "$removed_count"

if [ "$check" = true ]; then
  printf 'Check mode only: no Claude Desktop ZIP files were written.\n'
fi
