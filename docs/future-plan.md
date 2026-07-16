# Future plan (parking lot)

Long-lived ideas for **do**. Root `AGENTS.md` **Future Plan** stays short; promote items into **Next steps** when they become near-term work.

## Harness control (pi-ness lineage)

- Goal-as-mission full runner: validators + structured handoffs on grok continuum (`update_goal` / plan / todo)
- Side-ask dual stream / intake productization (L8)
- Progressive skill/MCP catalog dynamic mode parity with pi-ness (L4)
- Explicit L0–L6 fragment registry with maxBytes budgets (L2)
- Unified continuation coordinator priority stack (L5)
- Guided-block standard across all denials (L6)
- **M1 role lock (done):** Tab/Shift+Tab only pre-message; lock + toast after first user message; model re-resolve only while switch allowed — sealed F-M1-SHIP. Remaining polish: proactive first-message toast

## Models & config

- **M1 YAML apply (done):** `apply-models.py` maps assignment → agent frontmatter; validate mode; re-pin only while unlocked
- Optional richer `do models validate|apply` CLI that diffs against `~/.grok/config.toml`
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
