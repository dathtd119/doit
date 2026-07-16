# Feature flag lifecycle

## Source of truth

Feature flags enter the runtime via remote settings / env gates in crates such as:

- `crates/codegen/xai-grok-tools` (dispatch feature-flag bag)
- `crates/codegen/xai-grok-pager-bin` (dashboard and experimental gates)

## Lifecycle

| Stage | Rule |
|-------|------|
| Create | Name is snake_case; document owner and intended removal milestone |
| Ship | Default-off when risky; gate in one module |
| Measure | Use Mixpanel / Sentry tags where available |
| Clean | Remove dead flags promptly after full rollout |

## Dead flag detection

Run:

```sh
bash scripts/check-dead-feature-flags.sh
```

This scans for flag-like identifiers with a single code reference and writes `.quality/dead-feature-flags.txt`. CI runs the scan on every PR. Set `DEAD_FLAGS_FAIL=1` to hard-fail once the backlog is clean.

## Cleanup process

1. Weekly (or with Dependabot day): open `.quality/dead-feature-flags.txt` from CI artifacts.
2. For each candidate: confirm unused → delete declaration + any remote config key.
3. Document removals in `CHANGELOGS.md` under the milestone.
