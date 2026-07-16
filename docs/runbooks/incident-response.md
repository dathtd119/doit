# Runbook: Incident response

## Severity

| Level | Meaning | Response |
|-------|---------|----------|
| P0 | Data loss, auth break, unsafe tool execution | Page immediately; stop ship |
| P1 | Major harness regression (agent loop stuck, tool registry broken) | Respond within hours |
| P2 | Partial feature broken, workaround exists | Next business day |
| P3 | Cosmetic / docs | Backlog |

## Detection sources

1. **Sentry** — `SENTRY_DSN` / `SENTRY_ORG` / `SENTRY_PROJECT` (see `.env.example`). `send_default_pii` is off; inspect scrubbed stack traces.
2. **CI Quality gates** — failing smoke `cargo check -p doit` or clippy.
3. **User / agent report** — use `.github/ISSUE_TEMPLATE/bug_report.yml`.

## Immediate steps

1. Capture commit (`git rev-parse HEAD`) and session config (`~/.config/doit/config.toml` model names only — no secrets).
2. Reproduce with `cargo run -p doit` on a clean workspace if possible.
3. If a release is bad: tag a fix or point users to prior tag (see [deploy-impact](./deploy-impact.md)).
4. Open/update a GitHub issue with `type:bug` + `priority:P*`. The `error-to-issue` workflow can open issues from Sentry `repository_dispatch` events.

## Guided gates (safety)

If the incident involves a permission deny: results must use `[GATE: …]` + **Do this instead** (never bare "Permission denied"). See root `AGENTS.md` / product prompts.

## Escalation

- Security: `SECURITY.md` (HackerOne) — not public issues.
- Owner: see `.github/CODEOWNERS`.
