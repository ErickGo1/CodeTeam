---
name: team-init
description: Onboard the dev-team agents to the current project by generating .devteam/PROJECT.md, the project brief every agent reads before working. Use when starting to use dev-team in a new project, when the user says "init the team", "onboard the team", "set up dev-team", or when any dev-team agent reports the brief is missing. Also refreshes a stale brief.
---

# team-init — onboard the dev team to this project

Goal: produce `.devteam/PROJECT.md` so every dev-team agent knows this project's stack, conventions, and rules. Scan first, ask only what scanning can't answer, write the brief.

## Step 1 — Scan the repo (no questions yet)

Detect as much as possible yourself:
- **Stack**: package manifests (`package.json`, `*.csproj`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `composer.json`), lockfiles, `Dockerfile`/`docker-compose`, CI configs. Extract build/lint/test commands from manifest scripts and CI.
- **Existing agent context**: root `CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`, `CONTRIBUTING.md`, `README.md`. These often already contain conventions and non-negotiables — harvest them, don't duplicate them; the brief may summarize and link.
- **Architecture**: top-level layout, module/package structure, how modules reference each other.
- **UI**: frontend framework, design system / component library in dependencies (Metronic, Tailwind, shadcn, MUI, Bootstrap...), i18n libraries, shared-component directories.
- **Database**: engine from config/connection strings, schema/migration directories, migration tool, seed scripts.
- **Testing**: test frameworks in dependencies, test directories, Testcontainers/docker usage in tests.
- **Docs**: `docs/` tree — look for decision logs, open-question ledgers, architecture docs.
- **Legacy**: SQL dumps, folders named legacy/old/migration source material.

If the repo is large, delegate the scan to an Explore agent and keep only conclusions.

## Step 2 — Ask only the gaps

Use AskUserQuestion for what scanning cannot reveal (typically 3–6 questions, never more than needed):
- Non-negotiables: security/compliance rules, "never do" list (these live in people's heads, not code).
- Security: compliance regime (PCI/GDPR/none), untrusted input surfaces, sensitive-data classes that must never be logged.
- UI: is custom CSS allowed, or design-system classes only? Which design doc is authoritative?
- Database: migration policy (edit canonical schema vs numbered migrations) and whether a schema freeze applies.
- Review: project-specific blockers beyond the universal checklist, and the base branch.
- Anything the scan found ambiguous (two test frameworks, two component libraries...).

Skip questions whose answers were found in Step 1. For a greenfield/small project accept "defaults are fine" and write sensible defaults.

## Step 3 — Write the brief

Copy the section structure from `${CLAUDE_PLUGIN_ROOT}/templates/PROJECT.template.md` (headers are contract — agents look sections up by name) and fill it with findings + answers. Write to `.devteam/PROJECT.md`.

Rules:
- Concrete over generic: "Metronic 8.2.6, no custom CSS, FA5 icons" not "follow the design system".
- Every command in the brief must be one you verified exists (found in scripts/CI), not guessed.
- Empty sections stay present with "None." — agents check them.
- If `CLAUDE.md` or `AGENTS.md` exists, add one pointer line to it: `Project brief for dev-team agents: .devteam/PROJECT.md` (ask before editing files you didn't create).
- An example of a fully filled brief: `${CLAUDE_PLUGIN_ROOT}/examples/PROJECT.example-pos.md`.
- Monorepos: when areas have genuinely divergent rules (e.g. a Vue app and a Python ETL folder), write `.devteam/<area>.md` overrides containing ONLY the sections that differ from the root brief — don't duplicate shared rules. Skip overrides entirely for single-stack repos.

## Step 4 — Optional cross-tool export

Ask the user if they also want the same team installed for other tools in this project:
- **GitHub Copilot**: copy `${CLAUDE_PLUGIN_ROOT}/copilot/agents/*.md` → `.github/agents/`
- **OpenAI Codex**: copy `${CLAUDE_PLUGIN_ROOT}/codex/prompts/*.md` → `.codex/prompts/` (or `~/.codex/prompts/` for global)

Both read the same `.devteam/PROJECT.md`, so one brief serves all three tools.

## Done

Report: sections filled vs left empty, questions answered, and remind the user that `doc-keeper` keeps the brief current from now on — re-run `/dev-team:team-init` only after major stack changes.
