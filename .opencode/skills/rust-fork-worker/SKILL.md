---
name: rust-fork-worker
description: Import grok-build into do as a local fork, initialize git, and smoke-check xai-grok-pager-bin. Never edit pi-ness or grok-build source trees.
---

# rust-fork-worker

You own **fork import and build smoke** for mission **do** (M0). You do not write product docs or do-harness extensions unless a path fix for `cargo check` requires a one-line import correction inside **do only**.

## Constraints (hard)

- Working directory: `/home/datht/code/do`
- **NEVER modify** `/home/datht/code/pi-ness` or `/home/datht/code/grok-build`
- Import by **copy** only (rsync/cp) into do
- Preserve `LICENSE`, `THIRD-PARTY-NOTICES`, and Apache-2.0 notices
- Prefer `cargo check -p xai-grok-pager-bin` only — not full workspace unless required
- No OpenTUI port; no process kills of unrelated services

## Work Procedure

1. **Read context** — `mission.md`, `architecture.md`, `AGENTS.md`, your feature’s `fulfills` in `validation-contract.md`, `services.yaml`.
2. **Inventory source** — Confirm `/home/datht/code/grok-build` has `Cargo.toml`, `crates/`, pager-bin package name `xai-grok-pager-bin` (or document exact package name if different).
3. **Import into do** — Copy grok-build tree into `/home/datht/code/do` without deleting unrelated do-only dirs (`.opencode/`, `plans/`). Exclude bulky/irrelevant paths if needed (`target/`, `.git/` from source). Preserve licenses and THIRD-PARTY-NOTICES.
4. **Git init** — If do is not yet a git repo: `git init`, initial commit of imported tree + preserve notices. Do not rewrite history of grok-build.
5. **Smoke build** — From `/home/datht/code/do`, run `cargo check -p xai-grok-pager-bin`. Fix **only** import/path/toolchain issues inside do. Quote errors exactly in handoff if blocked.
6. **Verify VAL claims** — For F-FORK-001: git repo + workspace tree present; for F-FORK-002: check exits 0. Record commands and exit codes.
7. **Handoff** — Call `end_feature_run` with verification commands, no silent assumptions.

## Acceptance criteria

| Feature | Done when |
|---------|-----------|
| F-FORK-001 | do is a git repo; Cargo workspace + crates/codegen/pager-bin present; grok-build and pi-ness untouched |
| F-FORK-002 | `cargo check -p xai-grok-pager-bin` exits 0 from do |

## Example Handoff JSON

```json
{
  "successState": "success",
  "returnToOrchestrator": true,
  "validatorsPassed": true,
  "handoff": {
    "salientSummary": "Imported grok-build into do as a git repo; cargo check -p xai-grok-pager-bin passed.",
    "whatWasImplemented": "rsync import, git init, initial commit, cargo check smoke.",
    "whatWasLeftUndone": "None for F-FORK-00x scope.",
    "verification": {
      "commandsRun": [
        {
          "command": "test -d /home/datht/code/do/.git && test -f /home/datht/code/do/Cargo.toml",
          "exitCode": 0,
          "observation": "git repo and workspace Cargo.toml present"
        },
        {
          "command": "cargo check -p xai-grok-pager-bin",
          "exitCode": 0,
          "observation": "pager-bin typechecks"
        }
      ]
    },
    "tests": { "added": [], "coverage": "N/A — cargo check only" },
    "discoveredIssues": [],
    "skillFeedback": {
      "followedProcedure": true,
      "deviations": [],
      "suggestedChanges": []
    }
  }
}
```

## When to Return to Orchestrator

- Source tree missing expected packages or licenses
- `cargo check` fails for reasons beyond import/path (missing system deps, protoc, network-only crates) after one reasonable fix attempt
- Would need to modify `/home/datht/code/grok-build` or `/home/datht/code/pi-ness`
- Would need full-workspace patch campaign or TUI/auth rewrite outside M0
