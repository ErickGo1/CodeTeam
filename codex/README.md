# dev-team for OpenAI Codex

GENERATED — do not edit these files. Edit the canonical roles in `../agents/` and run `../sync.sh`.

Codex has no subagents; each role ships as a custom prompt that makes Codex adopt that role for the current task.

## Install

Per project:
```bash
cp codex/prompts/*.md /path/to/project/.codex/prompts/
```
Or globally (all projects):
```bash
cp codex/prompts/*.md ~/.codex/prompts/
```

Invoke in Codex as `/tech-lead`, `/code-reviewer`, `/db-engineer`, etc.

## Requirement

Every role reads `.devteam/PROJECT.md` in the target repo before working, and stops if it's missing. Create it with `/dev-team:team-init` from Claude Code, or by hand from `../templates/PROJECT.template.md` (see `../examples/PROJECT.example-pos.md`).

Tip: add one line to the project's `AGENTS.md` so Codex always knows about the brief:
`Project brief for dev-team roles: .devteam/PROJECT.md`
