#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
destination="${AGENT_SKILLS_DIR:-$HOME/.agents/skills}"

mkdir -p "$destination"

while IFS= read -r -d '' skill_md; do
  source_dir="$(dirname "$skill_md")"
  skill_name="$(basename "$source_dir")"
  target="$destination/$skill_name"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "error: $target exists and is not a symlink" >&2
    exit 1
  fi

  ln -sfn "$source_dir" "$target"
  echo "linked $skill_name -> $source_dir"
done < <(find "$repo/skills" -name SKILL.md -not -path "*/node_modules/*" -print0)
