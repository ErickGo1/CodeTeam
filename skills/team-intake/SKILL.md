---
name: team-intake
description: Process a client requirements document into user stories and post them to the project tracker (Jira, GitHub Issues, etc). Use when the user says "intake this document", "turn this into stories", "the client sent requirements", or provides a business-requirements doc to plan from. Argument - path to the document (pdf, docx, or markdown).
---

# team-intake — client document to tracked stories

Pipeline: extract → analyze → user approves → post to tracker → record. The user approval gate is mandatory: stories land in a client-visible tracker, nothing is posted without explicit sign-off.

## Steps

1. **Read the document.** Argument or conversation names the file. PDFs and Word docs: extract the text first (use the pdf/docx skills). Read it fully — don't summarize-and-skim a client contract.
2. **Precondition**: `.devteam/PROJECT.md` must exist (run `/dev-team:team-init` first if not). Note the brief's "Tracker" section — project key, issue types, story format, connection method, posting policy.
3. **Analyze** — delegate to `product-analyst` with the full document text. It returns numbered business rules (BR-x), stories with acceptance criteria, a traceability table, open questions with recommended defaults, and explicit out-of-scope.
4. **Approval gate (mandatory).** Present to the user: the story list (titles + size hints), the open questions, and any conflicts product-analyst flagged. Use AskUserQuestion where the choices are concrete. Do NOT post anything until the user approves the set. Open questions the client must answer stay attached to their stories as blockers, not silently resolved.
5. **Post to the tracker**, per the brief's Tracker section, in this resolution order:
   - **Connected MCP tools** (Atlassian/Jira, GitHub, Linear...): use ToolSearch to find them; create one issue per story — summary, description (story + acceptance criteria + BR references), labels/components/issue type from the brief.
   - **REST fallback**: if the brief names an API base URL + credential env var, post via curl (e.g. Jira `POST /rest/api/3/issue`). Never echo the credential.
   - **No connection**: emit an import-ready artifact instead — Jira CSV or a markdown block per story ready to paste — and say that's what happened.
   - Report every created issue key/URL. On partial failure, report exactly which stories posted and which didn't — never retry blindly into duplicates; check before re-posting.
6. **Record** — delegate to `doc-keeper`: business rules land in the docs location (they are what test-writer traces tests back to), client open questions go to the open-questions ledger with owner = client, and the analysis file is linked from wherever the brief keeps specs.

## Final report

Issue keys created (or the import artifact), open questions awaiting the client, conflicts flagged against the brief, and the path to the analysis artifact. The next step after client answers arrive is normal `/dev-team:team` per story — say so.
