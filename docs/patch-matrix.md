# Patch matrix (L1–L13)

**Status:** M0 — L13 sealed under **F-MODEL-001**. L1–L12 order/risk aligned with architecture; **F-DOC-002** may refine evidence and sequencing after F-GROK-001 inventory.

**Path vocabulary:** `plugin` | `hook` | `agent` | `skill` | `tool_pack` | `crate_patch` | `defer` | `config` (includes do YAML overlays + stock TOML)

| Order | ID | Preferred path | Risk | Notes |
|------:|----|----------------|------|-------|
| 1 | L10 | `config` + docs (`FORK.md`) | Low | Fork hygiene first; never modify sibling source trees |
| 2 | **L13** | **`config` (do YAML) + `agent`** | **Low** | Multi-model **exists**; fill assignment UX only. Template: `do-harness/config.models.yaml`. Map to `[model.*]` + role/agent `model`. **Avoid crate_patch** unless pins cannot be expressed. M1 wire. Design: [models-and-config.md](./models-and-config.md) |
| 3 | L1 | `agent` + `config` (+ optional `crate_patch` for Tab lock) | Medium | Role roster + **post-first-message lock** (M1). Prefer session/shell seams before deep TUI |
| 4 | L6 | `hook` (+ small `crate_patch` only if gate format needs tools-api) | Low–Medium | Guided blocks `[GATE:…]` + Do this instead; proof in F-EXT-002 |
| 5 | L8 | `agent` | Low | Intake default role profile first; dual-stream UI deferred |
| 6 | L9 | `config` + docs | Low | Map `.do/` or reuse `.grok/` session layout |
| 7 | L2 | `plugin` / prompts + optional `crate_patch` | Medium | L0–L6 mapping onto grok inject points |
| 8 | L4 | `config` + optional `crate_patch` | Medium | Progressive skill/MCP catalog |
| 9 | L5 | `hook` / SessionActor first; coordinator crate if needed | High if crate | Continuation priority lanes |
| 10 | L3 | `plugin` + `hook` + `tool_pack` | Medium | No TS factories; use Rust seams |
| 11 | L7 | `plugin` / MCP; optional `tool_pack` later | Medium | CodeGraph lean tools |
| 12 | L11 | `defer` deep TUI | High | Accept ratatui; plugins before pager fork |
| 13 | L12 | process: document every `crate_patch` here | Ongoing | Minimize core diffs |

## L13 row (expanded)

| Field | Value |
|-------|--------|
| **Gap** | Assignment UX / role→model policy (not missing multi-model registry) |
| **Preferred path** | `config` (YAML overlay) → `agent` / role frontmatter; stock TOML remains runtime registry |
| **Avoid** | Second runtime registry; early `crate_patch` for assignment |
| **Risk** | Low if overlay-only; Medium if operators expect auto-wire before M1 |
| **Milestone** | M0 template + docs; M1 wire assignment into agents |
| **Validators** | VAL-MODEL-001, VAL-MODEL-002 |

## Rules

1. Prefer extension (`config` / `agent` / `hook` / `plugin` / `skill`) before `tool_pack` before `crate_patch`.  
2. Every actual crate patch must add a dated entry here with crate path + reason.  
3. Dual config for models: do YAML policy + `~/.grok/config.toml` runtime — do not fight the base.

## Related

- [limitations.md](./limitations.md)  
- [models-and-config.md](./models-and-config.md)  
- [architecture.md](./architecture.md)  
- [grok-build/extension-seams.md](./grok-build/extension-seams.md)  
- [grok-build/hard-limits.md](./grok-build/hard-limits.md)  
