# Runbook: Release / deploy impact

**do** ships as a local CLI binary (no multi-tenant server deploy). "Deploy" here means a **tagged GitHub Release** produced by `.github/workflows/release.yml`.

## Before ship

1. Green CI Quality gates on `main`.
2. Smoke: `cargo check -p xai-grok-pager-bin`.
3. Review `CHANGELOGS.md` / generated release notes.

## After ship

Check impact surfaces (document your dashboard URLs for your environment):

| Surface | What to watch | Where |
|---------|---------------|--------|
| Sentry | New error spike after tag | Sentry project issues stream |
| Mixpanel | Unexpected drop/spike in session events | Mixpanel boards |
| CI artifacts | Coverage / jscpd / nextest junit | Actions → Quality gates artifacts |
| GitHub Release | Assets + notes published | repo Releases page |

Workflow `.github/workflows/deploy-observability.yml` runs on `release` and uploads a post-ship checklist artifact so agents have a deterministic pointer.

## Rollback

1. Advise users to pin the previous release tag binary.
2. Revert the bad commit on `main` and cut a patch tag (`vX.Y.Z+1`).
3. If config regression: restore prior `~/.config/doit/config.toml` model pins (never restore secrets from git).
