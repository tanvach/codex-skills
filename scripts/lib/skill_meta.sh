# Shared frontmatter helpers for skill generators.
# Source from another script: . "$repo_root/scripts/lib/skill_meta.sh"

strip_frontmatter() {
  local input_file="$1"
  awk '
    NR == 1 && $0 == "---" { in_frontmatter = 1; next }
    in_frontmatter && $0 == "---" { in_frontmatter = 0; next }
    !in_frontmatter { print }
  ' "$input_file"
}

# Returns the description string from a SKILL.md frontmatter, supporting both
# the YAML folded scalar form (`description: >-` followed by indented lines)
# and the plain single-line form (`description: ...`). For the plain form,
# leading/trailing whitespace and surrounding single or double quotes are
# stripped.
extract_description() {
  local input_file="$1"
  awk '
    BEGIN { in_frontmatter = 0; collecting = 0; first = 1; value = "" }
    NR == 1 && $0 == "---" { in_frontmatter = 1; next }
    in_frontmatter && $0 == "---" {
      if (collecting) print value
      exit
    }
    !in_frontmatter { exit }
    /^description:[[:space:]]*>-[[:space:]]*$/ {
      collecting = 1
      next
    }
    /^description:/ && !collecting {
      line = $0
      sub(/^description:[[:space:]]*/, "", line)
      sub(/[[:space:]]+$/, "", line)
      if (length(line) >= 2) {
        first_char = substr(line, 1, 1)
        last_char = substr(line, length(line), 1)
        if ((first_char == "\"" && last_char == "\"") || (first_char == "\x27" && last_char == "\x27")) {
          line = substr(line, 2, length(line) - 2)
        }
      }
      print line
      exit
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
