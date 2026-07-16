# Current status (expanded)

Date: **2026-07-16**  
Mission: Factory **M1 → PRIV → CFG → M2 → M3** (`mis_e0bdf86b`; prior history `mis_413072d4` / OpenCode `mis_3ce18e2a`)  
Compact status lives in root [AGENTS.md](../AGENTS.md) (may be gitignored); **this file is the committed living-status mirror**.

## Where we are

**do** is a private/local fork of Grok Build intended to absorb pi-ness harness-control ideas without porting OpenTUI. **M0, M1, PRIV, CFG, M2, and M3 are sealed.** Mission backlog [backlog-m1-m3.md](./backlog-m1-m3.md) exit criteria for M1–M3 are **checkable as done**.

### M0 sealed (summary)

- Fork import + `cargo check -p xai-grok-pager-bin` smoke
- Control plane (AGENTS + docs split + CHANGELOGS + README/FORK)
- Multi-model design (L13): stock multi-`[model.*]` facts + do YAML assignment template
- Role switch lock **policy** documented (implement later sealed in M1)
- Grok-build inventory, limitations L1–L13, patch-matrix, capability-map
- Proof extension: intake agent, guided dangerous-shell hook, `verify-discovery.sh`
- Ordered backlog `docs/backlog-m1-m3.md`

### M1 sealed (harness control v1)

| Surface | Evidence |
|---------|----------|
| Five product agents | `verify-roster.sh` — intake, orchestrator, explorer, worker, oracle |
| Role switch lock | `verify-role-lock.sh` — 10 `role_switch_policy` tests; Tab only pre-message |
| Lock UX toast | `c8bf39f` — locked-attempt toast points to new session (`role_switch_locked_toast`) |
| YAML → agent pins | `apply-models.py --validate` — 5 assignment pins; stock TOML remains runtime |
| Model re-pin gate | `verify-model-resolve.sh` — re-pin only while `role_switch_allowed` |
| L0–L6 + workspace | `docs/prompt-system.md` implementable; continuum contract non-stub |
| Progressive skills start | `verify-progressive-skills.sh` + `config.skills.yaml`; reduced firehose on intake/explorer/oracle |

M1 exit criteria in [backlog-m1-m3.md](./backlog-m1-m3.md) are **checked**. Full seal entry: [CHANGELOGS.md](../CHANGELOGS.md) F-M1-SHIP.

### PRIV sealed (privacy track)

| Surface | Evidence |
|---------|----------|
| Fail-closed SpaceXAI telemetry | `4458c69` — P-NOTEL-01..06 (analytics, Mixpanel, Sentry, internal OTLP, trace upload, feedback) |
| External OTEL preserved | `GROK_EXTERNAL_OTEL` + `OTEL_*`; `xai-grok-telemetry/src/external/` intact |
| BYOK / no forced OAuth | `11d8752` — P-AUTH-01; Auth docs in [models-and-config.md](./models-and-config.md) |
| Patch matrix | [patch-matrix.md](./patch-matrix.md) **applied** rows for P-NOTEL-01..06 + P-AUTH-01 |

Full seal entry: [CHANGELOGS.md](../CHANGELOGS.md) F-PRIV-SHIP.

### CFG sealed (config home + project discovery)

| Surface | Evidence |
|---------|----------|
| User home `~/.config/do` only | `12a5c20` — P-CFG-HOME (`default_grok_home` / `DEFAULT_USER_HOME_REL`); no silent `~/.grok` fallback; override `GROK_HOME` |
| Project discovery `.do/` | `9039f68` — P-CFG-PROJECT (agents/hooks/plan/config/skills/plugins product paths); do-harness verify/install → `.do/` |
| Fixture alignment | `53bf77b` — P-CFG-FIXTURES rewrite project fixtures to `.do/` |
| Harness verify | `verify-discovery.sh` + `verify-roster.sh` exit 0 against `.do/` |
| Docs | [FORK.md](../FORK.md) §4; [models-and-config.md](./models-and-config.md); [workspace.md](./workspace.md); patch-matrix **applied** P-CFG-* |

Full seal entry: [CHANGELOGS.md](../CHANGELOGS.md) F-CFG-SHIP.

### M2 sealed (continuity & safety)

| Surface | Evidence |
|---------|----------|
| Continuation priority | `1e523b2` — lanes interrupt→streak→goal→plan→workflow→todo; `verify-continuation.sh` VAL-M2-CONT-001 |
| Guided-block pack | `324c959` — path-policy + env-expose beyond dangerous-shell; `verify-gates.sh` VAL-M2-GATE-001; gate names in all five role prompts |
| Progressive skill/MCP | `803f415` — product-wide progressive/curated (`discoverSkills: false`); firehose opt-in; MCP `search_tool`/`use_tool`; `verify-progressive-skills.sh` VAL-M2-SKILL-001 |
| Role tool floors | `0b63f7b` — allow/deny floors on five agents + `config.permissions.yaml`; `verify-role-permissions.sh` VAL-M2-PERM-001 |
| Docs | [continuation.md](./continuation.md), [progressive-skills.md](./progressive-skills.md), [role-permissions.md](./role-permissions.md), `do-harness/prompts/gates.md` |

M2 exit criteria in [backlog-m1-m3.md](./backlog-m1-m3.md) are **checked**. Full seal entry: [CHANGELOGS.md](../CHANGELOGS.md) F-M2-SHIP.

### M3 sealed (native power tools)

| Surface | Evidence |
|---------|----------|
| CodeGraph MCP product surface | `7a55c75` — MCP-first `do-codegraph` wrapping `xai-codebase-graph`; explore/impact/stats; [codegraph.md](./codegraph.md); `verify-codegraph.sh` VAL-M3-CG-001 |
| Hashline default edit policy | `ef06622` — product `file_toolset = "hashline"` overlay; worker floors/guidance; rollback to `"standard"`; [hashline.md](./hashline.md); `verify-hashline.sh` VAL-M3-HASH-001 |
| Tool packs | None required M3 — no silent crate sprawl; MCP + config placement documented |
| Docs / capability map | [capability-map.md](./capability-map.md) refreshed post-M3; backlog exit criteria all checked |

M3 exit criteria in [backlog-m1-m3.md](./backlog-m1-m3.md) are **checked**. Full seal entry: [CHANGELOGS.md](../CHANGELOGS.md) F-M3-SHIP.

### In progress / next

| Item | Track | Notes |
|------|-------|-------|
| Parking-lot promotions only | post-mission | Goal-as-mission, side-ask, BM25 skill_search, multi-provider auth, permission-rules YAML |
| Optional polish | UX / L7 | Proactive first-message lock toast; CodeGraph `tool_pack` if MCP friction forces it |

### True-now constraints

- Do not modify `~/code/pi-ness`, `~/code/grok-build`, or `~/code/grok-build-no-telemetry` (read-only)
- Extension-before-deep-fork
- Config root: **`~/.config/do`** + project **`.do/`** (CFG sealed); `GROK_HOME` overrides user home
- Role cycle remains **pre-message only** (no mid-session hop)
- Guided denials for do-owned gates: **`[GATE: …]` + Do this instead**
- Continuation nudges re-surface **one** highest open lane (no continuum dump thrash)
- Power nav: prefer CodeGraph MCP explore/impact before full-repo grep thrash
- Product edit default: hashline namespace when `file_toolset = "hashline"` (stock Default still Standard until TOML merge)
- SpaceXAI telemetry fail-closed; external OTEL optional
- BYOK / `preferred_method=api_key` does not force grok.com OAuth
- Commit every milestone; handoff needs `commitId` + `repoPath`

## Near-term sequence

1. **Parking lot only** — promote from [future-plan.md](./future-plan.md) when product chooses next work
2. Optional UX / tool_pack polish listed above

## Links

- [architecture.md](./architecture.md)
- [models-and-config.md](./models-and-config.md)
- [backlog-m1-m3.md](./backlog-m1-m3.md)
- [patch-matrix.md](./patch-matrix.md)
- [capability-map.md](./capability-map.md)
- [prompt-system.md](./prompt-system.md)
- [workspace.md](./workspace.md)
- [progressive-skills.md](./progressive-skills.md)
- [codegraph.md](./codegraph.md)
- [hashline.md](./hashline.md)
- [../FORK.md](../FORK.md)
- [grok-build/README.md](./grok-build/README.md)
- [future-plan.md](./future-plan.md)
- [CHANGELOGS.md](../CHANGELOGS.md)
