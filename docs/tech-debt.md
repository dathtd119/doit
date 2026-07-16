# Technical debt markers

## Policy

Bare `TODO` / `FIXME` / `HACK` comments are not allowed in production code.

**Required form:**

```rust
// TODO(TICKET-123): explain the debt
// FIXME(https://github.com/org/repo/issues/45): link preferred
```

## Enforcement

```sh
bash scripts/check-tech-debt.sh
```

Hooked from:

- `.pre-commit-config.yaml` (`tech-debt-markers`)
- CI Quality gates (`.github/workflows/ci.yml`)

## Tracking

- Prefer GitHub issues with labels `type:chore` + area label for debt work.
- Milestone docs (`CHANGELOGS.md`, `docs/future-plan.md`) hold longer parking-lot debt that is not line comments.
