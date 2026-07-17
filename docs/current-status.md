# Current status (expanded)

Date: **2026-07-16**  
Missions: Factory **M1 → PRIV → CFG → M2 → M3** (`mis_e0bdf86b`, backlog complete); brand **ORIGIN → UPSTREAM → CFG-DOIT → PKG** (`mis_89367de7`, CFG-DOIT sealed)  
Compact status lives in root [AGENTS.md](../AGENTS.md) (may be gitignored); **this file is the committed living-status mirror**.

## Where we are

**doit** is a private/local fork of Grok Build intended to absorb pi-ness harness-control ideas without porting OpenTUI. **M0, M1, PRIV, CFG, M2, and M3 are sealed** on the factory track. Brand mission **CFG-DOIT is sealed**: user home `~/.config/doit`, project `.doit/`, worktree `/home/datht/code/doit`.

### M0 sealed (summary)

- Fork import + product smoke (`cargo check -p doit`; historically pager-bin)
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

### CFG sealed (historical — `~/.config/do` + `.do/`)

| Surface | Evidence |
|---------|----------|
| User home `~/.config/do` only | `12a5c20` — P-CFG-HOME; no silent `~/.grok` fallback; override `GROK_HOME` |
| Project discovery `.do/` | `9039f68` — P-CFG-PROJECT; fixtures `53bf77b` |
| Docs | Prior F-CFG-SHIP under factory mission |

**Superseded by CFG-DOIT** (paths below). Historical seal entry still in [CHANGELOGS.md](../CHANGELOGS.md).

### CFG-DOIT sealed (true-now config paths)

| Surface | Evidence |
|---------|----------|
| User home `~/.config/doit` | `12ed80c` — P-CFG-HOME-DOIT (`DEFAULT_USER_HOME_REL` → `.config/doit`); no silent `~/.config/do` / `~/.grok` fallback; override `GROK_HOME` |
| Project discovery `.doit/` | `43bb3b2` — P-CFG-PROJECT-DOIT (agents/hooks/plan/config/skills/plugins); verify scripts → `.doit/` |
| Host + share + MCP migrate | `de07cc1` — `~/.config/doit`, `~/.local/share/doit`, MCP `doit-codegraph`; deprecation symlinks `do` → `doit` optional |
| Build smoke | `cargo check -p doit` exit 0 (VAL-CFG-007) |
| Living docs | This file + root AGENTS + [architecture.md](./architecture.md) true-now paths (VAL-CFG-008) |

Full seal entry: [CHANGELOGS.md](../CHANGELOGS.md) F-CFG-SHIP (CFG-DOIT).

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
| CodeGraph MCP product surface | `7a55c75` — MCP-first `doit-codegraph` wrapping `xai-codebase-graph`; explore/impact/stats; [codegraph.md](./codegraph.md); `verify-codegraph.sh` VAL-M3-CG-001 |
| File toolset + hashline opt-in | M3 sealed hashline default (`ef06622`); **policy flip 2026-07-16** → product `file_toolset = "standard"`; hashline opt-in; worker prefers `search_replace`/`write`; media tools denied; [hashline.md](./hashline.md); `verify-hashline.sh` VAL-M3-HASH-001 |
| Tool packs | None required M3 — no silent crate sprawl; MCP + config placement documented |
| Docs / capability map | [capability-map.md](./capability-map.md) refreshed post-M3; backlog exit criteria all checked |

M3 exit criteria in [backlog-m1-m3.md](./backlog-m1-m3.md) are **checked**. Full seal entry: [CHANGELOGS.md](../CHANGELOGS.md) F-M3-SHIP.

### Brand mission (`mis_89367de7`) — ORIGIN + UPSTREAM + CFG-DOIT + PKG sealed

| Surface | Notes |
|---------|--------|
| GitHub / origin | `dathtd119/doit` — origin `https://github.com/dathtd119/doit.git` |
| Implementation root | **`/home/datht/code/doit` only** |
| Sibling clone | `/home/datht/code/do` **deprecated** as writable product root (docs only; no `rm -rf` without user OK) |
| Upstream absorb | `6cdf160` merge absorb `8adf901`; [AGENTS.md](../AGENTS.md) **Upstream sync checklist** mandatory every merge |
| CFG-DOIT | `~/.config/doit` + `.doit/` + `~/.local/share/doit` + MCP `doit-codegraph` — **sealed** |
| M3 PKG packaging | CI/release/binstall → `dathtd119/doit`; README Install no crates.io; `verify-install.sh` exit 0 — **sealed** |
| Fork hygiene | [FORK.md](../FORK.md) §2 trees + checklist |

### In progress / next

| Item | Track | Notes |
|------|-------|-------|
| Parking-lot promotions | later | Goal-as-mission, side-ask, BM25 skill_search, multi-provider auth, permission-rules YAML |
| First `v*` GitHub Release | ops optional | Enables cargo-binstall prebuilts from release assets |
| Deprecation symlink cleanup | ops optional | Host `~/.config/do` → `doit` and share `do` → `doit` may be removed when operators ready |

### True-now constraints

- **Implementation root:** `/home/datht/code/doit` only; sibling `/home/datht/code/do` is deprecated (do not edit as product root)
- **Never modify** `/home/datht/code/pi-ness` or `/home/datht/code/grok-build` in place (VAL-CROSS-001)
- Every upstream sync: follow AGENTS **Upstream sync checklist** (patch-matrix inventory mandatory)
- Extension-before-deep-fork
- Config root: **`~/.config/doit`** + project **`.doit/`** (CFG-DOIT sealed); `GROK_HOME` overrides user home
- Share: **`~/.local/share/doit`**; MCP id **`doit-codegraph`**
- Role cycle remains **pre-message only** (no mid-session hop)
- Guided denials for do-owned gates: **`[GATE: …]` + Do this instead**
- Continuation nudges re-surface **one** highest open lane (no continuum dump thrash)
- Power nav: prefer CodeGraph MCP explore/impact before full-repo grep thrash
- Product edit default: **standard** (`file_toolset = "standard"` → `read_file` / `search_replace` / `grep`); hashline is **opt-in**
- SpaceXAI telemetry fail-closed; external OTEL optional
- BYOK / `preferred_method=api_key` does not force grok.com OAuth
- Commit every milestone; handoff needs `commitId` + `repoPath=/home/datht/code/doit`

## Near-term sequence

1. Parking lot — promote from [future-plan.md](./future-plan.md) when product chooses next work
2. Optional: first `v*` GitHub Release for prebuilt install assets

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
