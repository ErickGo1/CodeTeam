---
name: team-standup
description: Read-only status digest of a dev-team project - recent work, open decisions, deliberate debt, unresolved questions. Use when the user asks "where were we", "standup", "project status", "what's pending", or returns to a project after time away. Changes nothing.
---

# team-standup — where the project stands

Produce a compact digest of project state from the artifacts the team already leaves behind. Read-only: no file changes, no agents that write.

## Gather (run the cheap commands directly; delegate to an Explore agent only if the repo is huge)

1. **Brief**: read `.devteam/PROJECT.md` (if missing → suggest `/dev-team:team-init` and stop). Note its "Last updated" date and the ledger paths in its "Docs" section.
2. **Recent work**: `git log --oneline --since=<brief's last-updated date>` (fallback: last 15 commits). Uncommitted changes: `git status --short`.
3. **Pending decisions**: `git grep -n "DECISION-PENDING"` — defaults implementers took that still need a human ruling.
4. **Deliberate debt**: `git grep -n "ponytail:"` (exclude `.devteam/` and docs) — shortcuts with stated ceilings.
5. **Open questions**: the OPEN entries in the ledger the brief's Docs section names, if any.

## Report

Four short sections, most actionable first:
- **Needs a decision** — each DECISION-PENDING marker and open ledger question, with `file:line` or ledger ID. This is the list a human must rule on; lead with it.
- **Recently done** — commit summary since the brief date, grouped by theme, plus uncommitted work in flight.
- **Deliberate debt** — each `ponytail:` marker with its stated ceiling; flag any whose ceiling looks reached (e.g. the comment names a row count or team size the project has visibly passed).
- **Housekeeping** — brief staleness (many commits since its date → suggest doc-keeper sync), markers with no ledger entry.

Empty sections say "None" in one line — don't pad. End with at most three suggested next actions, not a plan.
