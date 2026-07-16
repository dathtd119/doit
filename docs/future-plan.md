# Future plan (parking lot)

Long-lived ideas for **do**. Root `AGENTS.md` **Future Plan** stays short; promote items into **Next steps** when they become near-term work.

## Harness control (pi-ness lineage)

- Goal-as-mission full runner: validators + structured handoffs on grok continuum (`update_goal` / plan / todo)
- Side-ask dual stream / intake productization (L8)
- Progressive skill/MCP BM25 `skill_search` / `skill_load` parity with pi-ness (L4; M2 sealed progressive/curated defaults without BM25 crate)
- Explicit L0–L6 fragment registry with maxBytes budgets (L2)
- **M2 continuation hooks (done):** priority lanes + PostToolUse nudge thrash-safe — sealed F-M2-SHIP / VAL-M2-CONT-001. Optional crate coordinator only if multi-lane races reappear
- **M2 guided blocks (done):** product standard + path-policy + env-expose packs beyond dangerous-shell — sealed F-M2-SHIP / VAL-M2-GATE-001. Remaining: any future denials must keep the shape
- **M2 role floors (done):** five-agent allow/deny floors + guided-gate alignment — sealed F-M2-SHIP / VAL-M2-PERM-001. Remaining: OpenCode-parity permission rules YAML surface
- **M1 role lock (done):** Tab/Shift+Tab only pre-message; lock + toast after first user message; model re-resolve only while switch allowed — sealed F-M1-SHIP. Remaining polish: proactive first-message toast

## Models & config

- **M1 YAML apply (done):** `apply-models.py` maps assignment → agent frontmatter; validate mode; re-pin only while unlocked
- Optional richer `do models validate|apply` CLI that diffs against `~/.config/doit/config.toml`
- Effort / reasoning level pins per role when backends support them
- OpenCode-parity permission rules surface in do YAML (beyond model assignment)
- Multi-provider auth beyond stock grok paths (deeper redesign; BYOK skip-OAuth shipped PRIV)
- Project-local model overrides (workspace config) without breaking user home registry

## Native power tools

- **Done (F-M3-CG / VAL-M3-CG-001):** CodeGraph MCP-first product surface wrapping `xai-codebase-graph` explore/impact — sealed F-M3-SHIP
- **Done (F-M3-HASH / VAL-M3-HASH-001):** Hashline product default edit policy (`file_toolset = "hashline"` overlay + agent floors + rollback) — sealed F-M3-SHIP
- Optional later: CodeGraph in-process `tool_pack` if MCP latency/install friction forces it
- LSP-driven refactors as first-class workflows (still parking lot)

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

- **Done (F-CFG-HOME / P-CFG-HOME):** default user home **`~/.config/doit` only** (no `~/.grok` fallback); override `GROK_HOME`
- **Done (F-CFG-PROJECT / P-CFG-PROJECT + P-CFG-FIXTURES):** project discovery **`.doit/`**; test fixtures aligned
- **Done (F-CFG-SHIP / VAL-CFG-SHIP-001):** docs + CHANGELOGS + living next → M2
