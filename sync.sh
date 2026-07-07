#!/usr/bin/env bash
# Regenerates copilot/agents/ and codex/prompts/ from agents/ (the canonical source).
# Edit roles ONLY in agents/*.md, then run ./sync.sh.
# ./sync.sh --check : regenerate, then fail if generated files differ from git HEAD
#                     (catches stale exports AND hand-edited generated copies). Used by CI.
set -euo pipefail
cd "$(dirname "$0")"
CHECK=0
[ "${1:-}" = "--check" ] && CHECK=1

rm -rf copilot/agents codex/prompts
mkdir -p copilot/agents codex/prompts

for f in agents/*.md; do
  name=$(sed -n 's/^name: //p' "$f" | head -1)
  desc=$(sed -n 's/^description: //p' "$f" | head -1)
  # body = everything after the closing --- of the frontmatter
  body=$(awk '/^---$/{c++; next} c>=2' "$f")

  # GitHub Copilot custom agent (.github/agents/<name>.md)
  {
    printf -- '---\nname: %s\ndescription: %s\n---\n\n' "$name" "$desc"
    printf '%s\n' "$body"
  } > "copilot/agents/$name.md"

  # OpenAI Codex custom prompt (.codex/prompts/<name>.md, invoked as /<name>)
  {
    printf '# Role: %s\n\n' "$name"
    printf 'Adopt this role for the current task. %s\n\n' "$desc"
    printf '%s\n' "$body"
  } > "codex/prompts/$name.md"
done

count=$(ls agents/*.md | wc -l | tr -d ' ')
echo "Synced $count roles -> copilot/agents/ and codex/prompts/"

if [ "$CHECK" -eq 1 ]; then
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "--check requires a git repository" >&2
    exit 2
  fi
  if [ -n "$(git status --porcelain -- copilot/agents codex/prompts)" ]; then
    echo "DRIFT: generated files don't match agents/. Run ./sync.sh and commit the result:" >&2
    git status --porcelain -- copilot/agents codex/prompts >&2
    exit 1
  fi
  echo "Generated files in sync with agents/."
fi
