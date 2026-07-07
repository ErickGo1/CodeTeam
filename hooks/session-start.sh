#!/usr/bin/env bash
# dev-team SessionStart hook.
# If the project has a .devteam/PROJECT.md brief, announce the team and warn on staleness.
# Silent in projects without a brief — no noise where the team isn't onboarded.
set -uo pipefail

BRIEF=".devteam/PROJECT.md"
[ -f "$BRIEF" ] || exit 0

updated=$(sed -n 's/^Last updated: *//p' "$BRIEF" | head -1)

echo "DEV-TEAM ACTIVE — project brief: $BRIEF (last updated: ${updated:-unknown})."
echo "Delegate specialist work to the dev-team agents (tech-lead plans; ux-designer/api-designer spec; ui/backend-implementer, db-engineer, devops-engineer, data-migration-engineer build; test-writer, code-reviewer, security-expert, performance-engineer verify; doc-keeper syncs docs; legacy-analyst answers legacy questions). Every agent reads the brief first."
echo "Skills: /dev-team:team (full pipeline), /dev-team:team-review (quick parallel review of the current diff), /dev-team:team-standup (project status digest), /dev-team:team-init (refresh the brief)."

# Per-module overrides, if any.
overrides=$(ls .devteam/*.md 2>/dev/null | grep -v 'PROJECT\.md$' || true)
if [ -n "$overrides" ]; then
  echo "Per-area brief overrides present: $(echo "$overrides" | tr '\n' ' ')— they win over the root brief for their area."
fi

# Staleness: many commits since the brief's date suggests drift.
if [ -n "${updated:-}" ] && git rev-parse --git-dir >/dev/null 2>&1; then
  commits=$(git rev-list --count --since="$updated 00:00" HEAD 2>/dev/null || echo 0)
  case "$commits" in (*[!0-9]*) commits=0 ;; esac
  if [ "$commits" -gt 30 ]; then
    echo "NOTE: $commits commits since the brief was last updated — it may be stale. Consider having doc-keeper sync it, or /dev-team:team-init to refresh."
  fi
fi
exit 0
