# dev-team

A portable senior development team of AI agents — tech lead, UX designer, UI & backend implementers, DB engineer, QA, code reviewer, doc keeper, legacy analyst — that you carry to any project.

**The core idea:** roles are permanent, projects are not. Each agent carries only the craft of its role (how a reviewer reviews, what a DB engineer never skips). Everything project-specific — *this* project uses Metronic, *that* one forbids physical deletes — lives in one file per project, `.devteam/PROJECT.md`, which every agent reads before touching anything. Generated once per project by `/dev-team:team-init`, kept current by `doc-keeper`.

## The team

| Agent | Does | Never does |
|---|---|---|
| `product-analyst` | Client requirements docs → numbered rules, stories, open questions | Inventing requirements |
| `tech-lead` | Plans, decomposes, assigns, makes architecture calls | Writes code (read-only) |
| `ux-designer` | Flows, screen layouts, component specs | Production code |
| `ui-implementer` | Frontend, inside the project's design system | Backend, DB, tests |
| `backend-implementer` | Domain logic, services, APIs | Schema, frontend, tests |
| `db-engineer` | Schema, migrations, seeds, query performance | Anything outside the DB dir |
| `test-writer` | Business-rule, state-machine, isolation, money tests | Weakening tests to pass |
| `code-reviewer` | Gatekeeping with severity + verdict | Editing files (read-only) |
| `security-expert` | Threat models + security audits with attack paths | Fixing code (read-only) |
| `api-designer` | Endpoint contracts so backend+frontend build in parallel | Implementing them |
| `devops-engineer` | CI/CD, Docker, IaC, environments, releases | Application code |
| `performance-engineer` | Profiling, query plans, budgets — findings with numbers | Optimizing on vibes |
| `data-migration-engineer` | Legacy→new ETL with mandatory reconciliation | Schema design |
| `doc-keeper` | Keeps decision logs, ledgers, and the brief in sync | Inventing decisions |
| `legacy-analyst` | Archaeology on the old system being replaced | Architecture proposals |

Every builder role follows the [ponytail](https://github.com/DietrichGebert/ponytail) discipline: climb the ladder (needs to exist? already in the codebase? stdlib? native platform? installed dependency? one line?) before writing new code, mark deliberate shortcuts with `ponytail:` comments naming their ceiling, and never simplify away validation, data-loss handling, security, or accessibility. The reviewer flags over-engineering as MAJOR; doc-keeper harvests `ponytail:` debt so "later" doesn't become "never".

## Claude Code (primary)

```bash
claude plugin marketplace add CharlyApps/CodeTeam
claude plugin install dev-team@carlosbastida
```

Then, in any project:

1. `/dev-team:team-init` — scans the repo, asks only what it can't detect, writes `.devteam/PROJECT.md`. Monorepos can add `.devteam/<area>.md` overrides (only the sections that differ) that win over the root brief for their area.
2. Use agents directly ("have code-reviewer look at this diff") — Claude also delegates to them automatically based on their descriptions.
3. `/dev-team:team <feature>` — runs the full pipeline: plan → design → implement (parallel) → test → review (with fix loop) → document.
4. `/dev-team:team-review [base]` — quick parallel code-reviewer + security-expert pass on your current diff, one merged verdict.
5. `/dev-team:team-standup` — read-only digest: what needs a decision, recent work, `ponytail:` debt, open questions.
6. `/dev-team:team-intake <doc>` — client requirements document → business rules + stories with acceptance criteria → (after your approval) posted to the tracker the brief names (Jira via MCP/REST, or an import-ready artifact).

A SessionStart hook announces the team in any project that has a brief (and warns when the brief looks stale). Projects without a brief get no noise.

**No-brief mode:** the agents work in any repo even without a brief — like ponytail, the methodology travels by itself. Without `.devteam/PROJECT.md` they infer conventions from the repo (CLAUDE.md, AGENTS.md, README, the code's own patterns), apply their universal role rules, and flag their reports as running without project-specific enforcement. The brief is optional sharpening, not required setup. Two exceptions that still require a brief: `legacy-analyst` and `data-migration-engineer` — without configured legacy sources they'd be guessing with someone's data, so they decline instead.

## Codex & Copilot

The same roles ship for both, generated from the same source — see [codex/README.md](codex/README.md) and [copilot/README.md](copilot/README.md). All three tools read the same `.devteam/PROJECT.md`, so one `team-init` serves the whole toolchain.

## Repo layout

```
agents/              canonical role definitions (Claude Code subagents) — EDIT HERE
skills/team-init/    onboarding skill: generates .devteam/PROJECT.md
skills/team/         orchestration skill: the full pipeline
skills/team-review/  standalone parallel review (code-reviewer + security-expert)
skills/team-standup/ read-only project status digest
skills/team-intake/  client requirements doc → stories → tracker
hooks/               SessionStart hook: announces the brief, warns on staleness
templates/           PROJECT.template.md — the brief's section contract
examples/            PROJECT.example-pos.md — a fully filled brief for a fictional POS product
copilot/agents/      GENERATED for GitHub Copilot (.github/agents/)
codex/prompts/       GENERATED for OpenAI Codex (.codex/prompts/)
sync.sh              regenerates copilot/ and codex/ from agents/ (--check = CI drift guard)
```

To change a role: edit `agents/<role>.md`, run `./sync.sh`. Never edit the generated copies.

To add a role: create `agents/<role>.md` with the same frontmatter shape and the standard briefing protocol (read the brief, stop if missing), add its section to `templates/PROJECT.template.md` if it needs project config, run `./sync.sh`.
