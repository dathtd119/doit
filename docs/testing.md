# Testing standards

## Run

```sh
# Fast package list (agents should prefer targeted crates)
cargo test -p xai-tool-protocol -- --list
cargo test -p xai-tool-protocol

# Nextest with timing + flaky retries (CI profile)
cargo nextest run -p xai-tool-protocol --profile ci
```

## Performance tracking

- Nextest prints **slow** tests (`status-level = slow` in CI).
- JUnit report: `target/nextest-junit.xml` (uploaded / available for analytics).
- Prefer fixing tests that repeatedly appear in the slow list.

## Flaky tests

Config: `.config/nextest.toml`

- Default profile retries once with 1s delay.
- CI profile retries twice; `final-status-level = flaky` surfaces unstable tests.
- Quarantine policy: mark known flakes with `#[ignore = "flake: <ticket>"]` and file `type:bug` + `priority:P2`.

## Coverage thresholds

CI enforces a **40% line coverage floor** on `xai-tool-protocol` via `cargo llvm-cov` (see `.github/workflows/ci.yml`). Raise package floors over time rather than lowering.
