# Future plan (parking lot)

Long-lived ideas for **do**. Root `AGENTS.md` **Future Plan** stays short; promote items into **Next steps** when they become near-term work.

## Harness control (pi-ness lineage)

- Goal-as-mission full runner: validators + structured handoffs on grok continuum (`update_goal` / plan / todo)
- Side-ask dual stream / intake productization (L8)
- Progressive skill/MCP catalog dynamic mode parity with pi-ness (L4)
- Explicit L0–L6 fragment registry with maxBytes budgets (L2)
- Unified continuation coordinator priority stack (L5)
- Guided-block standard across all denials (L6)
- **M1 (binding):** Tab/Shift+Tab role cycle only at session start (empty transcript); **lock after first user message** — no mid-session role hop; model re-resolve from role only while switch allowed (see AGENTS + prompt-system Role lifecycle; ordered items in [backlog-m1-m3.md](./backlog-m1-m3.md))

## Models & config

- M1: apply `do-harness/config.models.yaml` assignment into agent frontmatter automatically (only when role switch still allowed for primary session) — see backlog M1-M01..M03
- Optional `do models validate|apply` CLI that diffs against `~/.grok/config.toml`
- Effort / reasoning level pins per role when backends support them
- OpenCode-parity permission rules surface in do YAML (beyond model assignment)
- `~/.do` rebrand when extension path is proven (keep `~/.grok` for M0)
- Multi-provider auth beyond stock grok paths
- Project-local model overrides (workspace config) without breaking user home registry

## Native power tools

- CodeGraph native tool pack or lean MCP (L7)
- Hashline default policy as product default
- LSP-driven refactors as first-class workflows

## Product / process

- Milestone seal automation (VAL checklist → CHANGELOGS stub)
- Plugin packaging for do-harness as installable bundle
- Rebase / sync playbook vs frozen grok-build snapshots
- Capability-map live sync from source indexes

## Explicitly deferred

- Full OpenTUI / Node port of pi-ness TUI
- Deep pager/TUI fork before extension seams exhausted
- Upstream PRs to xAI grok-build

## Privacy & offline auth (parked)

### Native no-telemetry (from grok-build-no-telemetry)

- Port 6 patches from `~/code/grok-build-no-telemetry` into do crates as **P-NOTEL-01..06**
- Scout: [`plans/reports/scout-grok-build-no-telemetry-260716.md`](../plans/reports/scout-grok-build-no-telemetry-260716.md)
- Fail-closed SpaceXAI analytics / Mixpanel / Sentry / internal OTLP / trace upload / feedback
- Keep `GROK_EXTERNAL_OTEL`

### Custom-models-only / no forced Grok OAuth

- Bypass startup grok.com OAuth when using custom `[model.*]` BYOK or product offline mode
- Key: `auth_method.rs`, `acp/mod.rs` `startup_auth_metadata`, pager-bin `workspace_start` `ensure_authenticated`
- Config-first then optional crate knob
