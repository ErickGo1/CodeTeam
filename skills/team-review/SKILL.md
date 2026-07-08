---
name: team-review
description: Quick parallel review of the current diff by code-reviewer and security-expert, with one merged verdict. Use when the user says "team review", "review this with the team", wants a pre-merge check of their working changes, or before committing. Lighter than the full /dev-team:team pipeline - review only, no plan/implement stages. Optional argument - the base branch or ref to diff against.
---

# team-review — the review stage of the pipeline, standalone

Run the team's two gatekeepers on the current changes in parallel and merge their verdicts. Nothing gets fixed unless the user asks.

## Steps

1. **Precondition**: read `.devteam/PROJECT.md` if it exists. If not, proceed in no-brief mode — the reviewers apply their universal checklists (secrets, injection, authz, data loss, over-engineering) without project-specific blockers; note that in the final report and suggest `/dev-team:team-init` in one line.
2. **Determine scope**: the base is (in order) the argument passed to this skill, the base branch named in the brief's "Review" section, or the repo's default branch. Run `git diff --stat <base>` (include uncommitted changes) to get the changed-file list. Empty diff → report "nothing to review" and stop.
3. **Dispatch — both Agent calls in ONE message**:
   - `code-reviewer`: base ref + changed-file list; full checklist per its own definition.
   - `security-expert`: audit mode over the same diff.
   - Exception: if the diff is docs/comments-only (no code, config, or pipeline files), skip security-expert and say so.
4. **Merge into one report**:
   - All findings in one list, most severe first, each tagged `[review]` or `[security]` with `file:line`. Deduplicate: when both agents flag the same line, keep the security framing (it has the attack path) and note the overlap.
   - One overall verdict — the worst of the two: any security CRITICAL/HIGH or review BLOCKER → **REQUEST CHANGES**; only MAJORs/MEDIUMs → **APPROVE WITH CHANGES REQUESTED AS FOLLOW-UPS**; otherwise **APPROVE** (with minors listed).
5. **Stop there.** Report the merged result. If the user then asks to fix, route each finding to the owning implementer agent (ui/backend/db/devops) — never fix blockers inline yourself; re-run the relevant reviewer on the touched files after.

Keep the final report compact: verdict first, then findings, then what was skipped (e.g. "security audit skipped — docs-only diff").
