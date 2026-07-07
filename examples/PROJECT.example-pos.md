# Project Brief — Northwind POS (fictional example)

<!-- Example of a fully filled brief for a fictional multi-tenant retail/POS platform.
     This is the level of specificity /dev-team:team-init should aim for. -->
Last updated: 2026-07-07

## Overview
Northwind POS is a multi-tenant retail and point-of-sale platform replacing a legacy VB6 + SQL Server system. Currently pre-M1 (schema not yet frozen). Runs in browser and Electron.

## Stack
.NET modular monolith + PostgreSQL 16 + Vue 3 SPAs. Electron desktop shell.
- Build: `dotnet build` (backend), frontend build per package.
- Test: `dotnet test` — integration tests via Testcontainers.

## Architecture & Boundaries
Modular monolith — no microservices or message brokers (D004). Modules communicate through contracts; never reach into another module's tables. Module ownership map: `docs/architecture/DOMAIN_MODEL.md`. Operating contract: root `AGENTS.md` (§6 business rules and §10 "what never to do" are non-negotiable).

## API
Internal REST between Vue SPAs and the monolith (`/api`). Contracts co-located with module specs in `docs/architecture/`. Standard error shape and pagination: follow existing endpoints; no public API yet — breaking changes are fine pre-M1 if both sides move in the same wave.

## Conventions
English-only identifiers everywhere (code and DB). UUID v7 PKs. Money: `numeric(18,6)` + currency code column; quantities: `numeric(18,4)`; never float/double. `timestamptz` UTC. snake_case in DB. FX snapshot required wherever multi-currency amounts are persisted.

## Non-negotiables
- Never store or log card numbers, expiry, or CVV — anywhere, under any name, including payment-processor response payloads (D012).
- Every query tenant-scoped via `tenant_id`.
- No physical deletes of business documents.
- Never hardcode permissions, thresholds, or report visibility — all database-driven (D030).
- Every critical action writes to `audit.audit_log` (D028).
- Secrets only via the cloud key vault.

## Security
Compliance: PCI-adjacent — card data never touches our storage (D012); payment-processor payloads are the highest-risk surface. Trust boundaries: the supplier portal is fully untrusted (cross-supplier isolation is as critical as cross-tenant); file uploads validated by type and size. Sensitive-data classes never in logs/errors: card data, tax registration IDs, credentials. AuthZ: permission codes from DB (D030) — any hardcoded role check is a finding. Dependency audit: `dotnet list package --vulnerable`, `npm audit` per frontend package.

## UI / Design System
Metronic 8 + Bootstrap 5 classes ONLY — no new CSS classes, no overrides, no inline hex/font styles; unmet needs are DESIGN ESCALATION. Authoritative pattern doc: `docs/architecture/DESIGN_SYSTEM.md` (binding: one primary button max, label-on-top forms, tables with right-aligned actions max 3 then dropdown, card-everything, destructive confirmations name the record, mandatory loading/empty/error states). FA icons; theme icon set sidebar-only. Prefer native Vue over the theme's jQuery plugins (Electron compat); wrap unavoidable ones. i18n via vue-i18n — no hardcoded user-visible literals. Shared components → `/packages/design-system`. Feature access via permission codes only.

## Database
PostgreSQL 16+. Authoritative DDL: `database/schema.sql`; conventions doc: `docs/architecture/DATABASE_MODEL.md` (§1 is law). Migration policy: pre-M1 freeze edit `schema.sql` directly (keep executable top-to-bottom in one transaction); post-freeze, numbered migrations in `database/migrations/` (`NNNN_short_description.sql`, transactional, header comment). Every table: correct schema placement, `tenant_id`, audit columns, and a DATABASE_MODEL.md entry in the same change. Statuses as CHECK constraints unless runtime-configurable. Seeds in `database/seeds/`, idempotent, per-tenant aware (currencies, VAT rates standard/reduced/zero, payment methods — only CASH `allowed_offline=true`, system roles, permission codes, walk-in customer). Validate against clean PostgreSQL via Docker/Testcontainers before done. Watch partitioning readiness on `audit.audit_log` and `inventory.inventory_movements`.

## Testing
xUnit; integration tests against REAL PostgreSQL via Testcontainers — never mock the repository layer. Test matrices live in module specs. Priorities: business rules from `AGENTS.md` §6 (enforcement + rejection), state machines (purchase-order lifecycle, publication flow, transfers — every illegal transition rejected), tenant/supplier isolation, exact-decimal money math with FX snapshot cases. Names: `Method_Scenario_ExpectedOutcome`.

## Performance
No formal SLOs yet. Watch: POS operations must feel instant on modest hardware (Electron); `inventory_movements` and `audit_log` are the high-volume tables. Report absolute numbers.

## Deployment
None yet — pre-M1, local Docker only. Cloud target planned; key vault already assumed for secrets.

## Review
Base branch: `main`. Project BLOCKERs beyond the universal list: card-data paths (D012), missing `tenant_id` scoping, hardcoded permissions/thresholds (D030), cross-module table access, physical deletes, status values not matching `schema.sql` CHECK constraints, §6 rules without enforcing code + tests, microservices/broker infrastructure (D004). MAJORs: missing audit writes, float money, missing FX snapshot, untested transitions, non-English identifiers, silently resolved open questions (check `docs/product/OPEN_QUESTIONS.md`).

## Docs
- `docs/product/OPEN_QUESTIONS.md` — living ledger; resolved items → RESOLVED table with date; new items get the next OQ number with owner + needed-by.
- `docs/product/DECISIONS.md` — next D-number; never renumber, never delete.
- `docs/product/BACKLOG.md` — Phase 2 items.
- `docs/architecture/DATABASE_MODEL.md` — must move with every schema change.
- Module specs in `docs/architecture/` — status notes only; substantive changes are orchestrator territory.

## Legacy
Legacy VB6 + SQL Server POS. Sources: `legacy_pos.sql` DDL dump (reference folder) — tables, stored procedures (average-cost function, document-folio generation, tax-ID validation). Coverage map: `docs/migration/LEGACY_COVERAGE.md` — check it before adding tables; some capabilities were consciously simplified. Known anti-patterns never to reintroduce: per-warehouse product rows, permission bit-flags, dual-currency column pairs.
