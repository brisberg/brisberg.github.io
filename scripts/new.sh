#!/usr/bin/env bash
# usage: scripts/new.sh <blog|wiki|recipes> "<Title>"
set -euo pipefail
cd "$(dirname "$0")/.."

section="${1:?usage: scripts/new.sh <blog|wiki|recipes> \"<Title>\"}"
title="${2:?usage: scripts/new.sh <blog|wiki|recipes> \"<Title>\"}"

case "$section" in
  blog|wiki|recipes) ;;
  *) echo "error: section must be blog, wiki or recipes (got '$section')" >&2; exit 1 ;;
esac

slug=$(printf '%s' "$title" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')

if [ -z "$slug" ]; then
  echo "error: title '$title' produced an empty slug" >&2
  exit 1
fi

file="site/content/${section}/${slug}.md"
if [ -e "$file" ]; then
  echo "error: $file already exists" >&2
  exit 1
fi

hugo new -s site "content/${section}/${slug}.md" --kind "$section"

# The archetype title-cases the slug. Fix the title line in the editor if the
# result is wrong (e.g. "Deploying Ios Builds").
exec ${EDITOR:-code} "$file"
