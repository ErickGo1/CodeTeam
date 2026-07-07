# dev-team for GitHub Copilot

GENERATED — do not edit these files. Edit the canonical roles in `../agents/` and run `../sync.sh`.

## Install (per project)

Copy the agents into the target repo:

```bash
cp copilot/agents/*.md /path/to/project/.github/agents/
```

They become custom agents in Copilot coding agent / Copilot CLI / VS Code agent mode (`@tech-lead`, `@code-reviewer`, ...).

## Requirement

Every agent reads `.devteam/PROJECT.md` in the target repo before working, and stops if it's missing. Create it with `/dev-team:team-init` from Claude Code, or by hand from `../templates/PROJECT.template.md` (see `../examples/PROJECT.example-pos.md` for a filled example).

Tip: also add one line to `.github/copilot-instructions.md`:
`Project brief for dev-team agents: .devteam/PROJECT.md`
