#!/usr/bin/env bash
# Create a new skill from templates/skill.
# Usage: scripts/new-skill.sh <skill-name> [plugin]   (plugin defaults to core)
set -euo pipefail

name="${1:-}"
plugin="${2:-core}"
repo="$(cd "$(dirname "$0")/.." && pwd)"

if [[ ! "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "Usage: $0 <skill-name> [plugin]  (name in kebab-case, e.g. pr-create)" >&2
  exit 1
fi

plugin_dir="$repo/plugins/$plugin"
if [[ ! -d "$plugin_dir" ]]; then
  echo "No plugin at plugins/$plugin" >&2
  exit 1
fi

dest="$plugin_dir/skills/$name"
if [[ -e "$dest" ]]; then
  echo "plugins/$plugin/skills/$name already exists" >&2
  exit 1
fi

# "pr-create" -> "Pr create"
title="$(echo "${name//-/ }" | awk '{ $1 = toupper(substr($1, 1, 1)) substr($1, 2); print }')"

cp -R "$repo/templates/skill" "$dest"
mv "$dest/SKILL.template.md" "$dest/SKILL.md"
find "$dest" -type f -print0 | while IFS= read -r -d '' f; do
  sed -i.bak -e "s/{{name}}/$name/g" -e "s/{{title}}/$title/g" "$f" && rm "$f.bak"
done

echo "Created plugins/$plugin/skills/$name:"
(cd "$dest" && find . -type f | sed 's|^\./|  |' | sort)
echo
echo "Next: write the description and steps in SKILL.md, delete REFERENCE.md and scripts/ if unused,"
echo "and add the skill to the table in README.md."
