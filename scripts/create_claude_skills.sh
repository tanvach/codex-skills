#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf 'Usage: %s [--check]\n' "$(basename "$0")" >&2
}

strip_frontmatter() {
  local input_file="$1"
  awk '
    NR == 1 && $0 == "---" { in_frontmatter = 1; next }
    in_frontmatter && $0 == "---" { in_frontmatter = 0; next }
    !in_frontmatter { print }
  ' "$input_file"
}

extract_description() {
  local input_file="$1"
  awk '
    BEGIN { in_frontmatter = 0; collecting = 0; first = 1; value = "" }
    NR == 1 && $0 == "---" { in_frontmatter = 1; next }
    in_frontmatter && $0 == "---" { print value; exit }
    !in_frontmatter { exit }
    /^description:[[:space:]]*>-/ {
      collecting = 1
      next
    }
    collecting && /^[^[:space:]]/ {
      print value
      exit
    }
    collecting {
      line = $0
      sub(/^[[:space:]]+/, "", line)
      if (first) {
        value = line
        first = 0
      } else {
        value = value " " line
      }
    }
  ' "$input_file"
}

escape_yaml() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output_dir="$repo_root/generated/claude-commands"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/claude-skills.XXXXXX")"
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

generated_count=0
updated_count=0
skipped_count=0
removed_count=0

for skill_path in "$repo_root"/*; do
  [ -d "$skill_path" ] || continue
  [ -f "$skill_path/SKILL.md" ] || continue

  skill_name="$(basename "$skill_path")"
  source_file="$skill_path/SKILL.md"
  override_file="$skill_path/claude.override.md"
  output_file="$tmp_dir/$skill_name.md"
  description="$(extract_description "$source_file")"
  rel_source="${skill_path#$repo_root/}"

  {
    printf '%s\n' '---'
    printf 'description: "%s"\n' "$(escape_yaml "$description")"
    printf '%s\n\n' '---'
    printf '<!-- Generated from %s. Do not edit directly. -->\n\n' "$rel_source"

    if [ -f "$override_file" ]; then
      cat "$override_file"
    else
      strip_frontmatter "$source_file" | perl -pe 's/\$([A-Za-z0-9][A-Za-z0-9-]*)/\/$1/g'
    fi
  } >"$output_file"

  dest_file="$output_dir/$skill_name.md"
  if [ ! -e "$dest_file" ]; then
    if [ "$check" = true ]; then
      printf 'would create %s\n' "$dest_file"
    else
      mkdir -p "$output_dir"
      cp "$output_file" "$dest_file"
      printf 'create %s\n' "$dest_file"
    fi
    generated_count=$((generated_count + 1))
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
  for existing_file in "$output_dir"/*.md; do
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
  "$generated_count" "$updated_count" "$skipped_count" "$removed_count"

if [ "$check" = true ]; then
  printf 'Check mode only: no Claude command files were written.\n'
fi
