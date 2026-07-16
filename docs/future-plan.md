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
- Optional richer `do models validate|apply` CLI that diffs against `~/.config/do/config.toml`
- Effort / reasoning level pins per role when backends support them
- OpenCode-parity permission rules surface in do YAML (beyond model assignment)
- Multi-provider auth beyond stock grok paths (deeper redesign; BYOK skip-OAuth shipped PRIV)
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

## Privacy & offline auth

### Native no-telemetry (from grok-build-no-telemetry)

- **Done (F-PRIV-NOTEL / P-NOTEL-01..06, 2026-07-16):** fail-closed SpaceXAI analytics / Mixpanel / Sentry / internal OTLP / trace upload / feedback. External OTEL via `GROK_EXTERNAL_OTEL` preserved. Scout: [`plans/reports/scout-grok-build-no-telemetry-260716.md`](../plans/reports/scout-grok-build-no-telemetry-260716.md). Patch log: [patch-matrix.md](./patch-matrix.md).

### Custom-models-only / no forced Grok OAuth

- **Done (F-PRIV-AUTH / P-AUTH-01, 2026-07-16):** config-first BYOK + `[auth] preferred_method=api_key`; crate skips `workspace_start` `ensure_authenticated` when satisfied. See [models-and-config.md](./models-and-config.md) Auth section.
- **PRIV ship sealed** (F-PRIV-SHIP / VAL-PRIV-SHIP-001, 2026-07-16).
- Remaining parked: deeper multi-provider auth redesign / full offline product mode UX

## Config rebrand (CFG)

- **Done (F-CFG-HOME / P-CFG-HOME):** default user home **`~/.config/do` only** (no `~/.grok` fallback); override `GROK_HOME`
- **Done (F-CFG-PROJECT / P-CFG-PROJECT + P-CFG-FIXTURES):** project discovery **`.do/`**; test fixtures aligned
- **Done (F-CFG-SHIP / VAL-CFG-SHIP-001):** docs + CHANGELOGS + living next → M2
