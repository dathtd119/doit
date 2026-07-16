## Project Direction

`do` is a forked **Grok Build** coding-agent harness that absorbs **pi-ness** harness-control ideas and **OpenCode-style** multi-model / config control ergonomics.

Current stance:
- Base = forked grok-build (Rust: pager, shell, tools, agent)
- Ideas source = pi-ness (read-only reference at `~/code/pi-ness`)
- OpenCode learnings = provider catalog + agent model pins + permission config (see `docs/related-projects.md`, `docs/models-and-config.md`)
- Upstream grok-build at `~/code/grok-build` is read-only; we **COPY** into `do`
- Prefer extension (agents / hooks / plugins / skills / config) before crate patches
- Full map: [`docs/related-projects.md`](./docs/related-projects.md), [`docs/architecture.md`](./docs/architecture.md)

Objective:
- Harness control on a native-rich base: roles, L0–L6 prompt layers, progressive catalogs, guided gates, workspace continuum, continuation
- **Multi-model registry + role→model assignment** as controllable as OpenCode agents (orchestrator / explorer / worker / oracle each pin model + effort)
- Use grok native tools (`plan`, `update_goal`, hashline, `task`, `lsp`, …) — do not reinvent
- Dual config surface: stock `~/.grok/config.toml` for native multi-model; optional **do YAML** overlay for product assignment UX

## Architecture (see docs/architecture.md)

Target layout after M0 import:

| Surface | Role | Notes |
|---------|------|--------|
| `crates/` + codegen | Forked grok-build workspace | Binary lineage `xai-grok-pager-bin` |
| `do-harness/` | Product identity | agents, hooks, skills, prompts, `config.models.yaml` |
| `docs/` | Durable design + inventory | architecture, models-and-config, limitations, patch-matrix, … |
| Root `AGENTS.md` | Operating contract + compact living status | This file |
| `CHANGELOGS.md` | What shipped | Append on every milestone |

```
User → do binary (xai-grok-pager lineage)
         → shell / agent runtime
           → tools registry (native + tool packs)
           → model resolution (config.toml [model.*] + do YAML assignment)
           → do-harness agents / hooks / skills / prompts
           → session continuum (goal / plan / todo via native tools)
```

**Folder docs:** after import, keep human `README` + agent maps where surfaces change. Maintenance under **Documentation Rules**.

## Hard Constraints

- **NEVER modify** `~/code/pi-ness` or `~/code/grok-build` in place — both are read-only references
- **Import by COPY** into `/home/datht/code/do` only
- **Extension-before-deep-fork order** (see Customization Order 1–5)
- **Guided blocks (mandatory when gates exist):** tool denied/blocked/gated is incomplete until (1) the gate is named in system/role prompts and (2) the result uses `[GATE: …]` + **Do this instead** (+ human involvement / do-not thrash). Never bare “Permission denied”
- **Config root M0:** keep `~/.grok` conventions (including native multi-model TOML); brand as **do** in docs; `do-harness/` lives under the repo and is linked/copied onto discovery paths
- **Multi-model is required product behavior** — registry already exists in grok; fill assignment UX + YAML overlay (see L13)
- **No OpenTUI port** in M0–M1 unless reopened
- **English only** for code, docs, commits, configs, errors, tests
- **Conventional commits**; commit **every** milestone; handoff must include `commitId` + `repoPath`
- **Preserve Apache-2.0** + `THIRD-PARTY-NOTICES` / LICENSE from import
- Document every crate patch in [`docs/patch-matrix.md`](./docs/patch-matrix.md)
- Style: complete-word names; no comments that restate names; comments only for non-obvious trade-offs; don’t touch unrelated code (surface smells separately)
- Do not kill unrelated processes (`pkill`/`killall` by name; no port kills outside mission `services.yaml`)
- **Role switch lock:** Tab/Shift+Tab role cycle only when session has no user messages yet. After the first user message (or non-empty conversation), role switching is disabled — keep system/role context clean. Model re-assignment from role only applies when switch is still allowed.

## Session / role control

OpenCode-style **Tab / Shift+Tab** role cycling is a product requirement with a hard lifecycle rule:

| Phase | Role cycle (Tab / Shift+Tab) | Model re-resolve from role |
|-------|------------------------------|----------------------------|
| Session start — empty transcript, no user messages | **Allowed** | Yes — switch may apply role→model assignment |
| After first user message **or** any conversation content | **Disabled** | No mid-session hop; keep active role + model stack |

**Why:** Mid-session role hops pollute the system/role prompt stack and mix control contracts in one transcript. Cleaner to pick a role before work starts (or start a new session).

**Implementation:** **Documented in M0** (F-ROLE-001 / VAL-ROLE-001); **implement in M1** (role + prompt layers: session flag, keybind gate, stack freeze, role→model wire). Full TUI polish may lag; the lock policy is binding whenever role cycle UI exists. Details: [`docs/prompt-system.md`](./docs/prompt-system.md) (Role lifecycle + M1 note), [`docs/architecture.md`](./docs/architecture.md).

## Models & config control

**Requirement:** multi-model is not optional. Users must register N models and assign them to roles the way OpenCode pins `agent.model`.

| Layer | Format | Owns |
|-------|--------|------|
| Stock grok | TOML `~/.grok/config.toml` | Many `[model.<name>]`, `[models] default`, api_backend, agent frontmatter model |
| do product overlay | YAML `do-harness/config.models.yaml` (later `~/.do/config.yaml`) | Registry ergonomics + **role → model + effort** assignment table |

Facts (do not mis-document):
- Grok-build **already supports multiple custom models** via many `[model.<name>]` sections + default
- Subagent model resolution: spawn override > role > persona > parent
- Gap (**L13**): assignment UX and role→model **policy** weaker than OpenCode; do YAML overlay not wired yet

Full design, examples, and mapping: [`docs/models-and-config.md`](./docs/models-and-config.md).

## Native vs Extension vs Crate Patch (ask first)

**Before** a new tool, always-on behavior, or deep fork — **ask** placement. Do not silently choose.

| Placement | When | Where |
|-----------|------|--------|
| **Native tool pack** | Must implement Rust `Tool` trait / in-process tools | `register_tool_pack` / `xai-grok-tools` (or successor crate) |
| **do-harness** | Product identity: agents, hooks, skills, prompts, YAML model assignment | `do-harness/` |
| **Plugin** | Installable optional bundle | `.grok/plugins` or do-harness packaged as plugin |
| **Crate patch** | Only when extension seams fail | Documented in `docs/patch-matrix.md` |
| **Deep pager/TUI fork** | Last resort UI/runtime change | Avoid until M2+ and only with explicit decision |

### Rules

1. Always ask when adding always-on behavior or promoting config → crate
2. Default if user says “you choose”: identity/safety/roles/model-assignment → **do-harness**; optional → **plugin**; in-process tool → **tool pack**; only then **crate patch**
3. Do not bury long-term product identity only under home-dir overlays without a repo `do-harness/` source of truth
4. Record placement in plan/report when non-trivial
5. Prefer generating or documenting mapping into stock `config.toml` over forking the TOML schema

## Customization Order

When changing behavior, prefer:

1. **do-harness** agents / hooks / skills / prompts / YAML overlays
2. **`.grok` config / plugins** (M0 discovery root; multi-model TOML)
3. **`register_tool_pack`** for new native tools
4. **Surgical crate patches** (document in patch-matrix)
5. **Deep pager / TUI fork** last

Learning sources: [`docs/related-projects.md`](./docs/related-projects.md).  
Limitations L1–L13: [`docs/architecture.md`](./docs/architecture.md) (detail in `docs/limitations.md` after M0 docs; L13 in `docs/models-and-config.md`).

## Gates

### Read (before tool / prompt / extension / crate work)

1. [`docs/index.md`](./docs/index.md) — open matching subsystem docs
2. **Before any crate work** (tool packs, surgical patches, deep fork): read [`docs/grok-build/`](./docs/grok-build/) — at least [README](./docs/grok-build/README.md), [extension-seams](./docs/grok-build/extension-seams.md), [hard-limits](./docs/grok-build/hard-limits.md); use [native-tools](./docs/grok-build/native-tools.md) and [patterns](./docs/grok-build/patterns.md) when adding or choosing tools
3. Minimum: [`docs/architecture.md`](./docs/architecture.md); `docs/patch-matrix.md` and `docs/limitations.md` when relevant; **`docs/models-and-config.md`** for any model/role assignment work
4. Subsystem stubs as needed: [`docs/prompt-system.md`](./docs/prompt-system.md), [`docs/workspace.md`](./docs/workspace.md)
5. Read **source** in learning repos before borrowing (pi-ness, OpenCode, grok-build) — cite what you copied; prefer forked tree under `do/crates/` as primary evidence
6. Tool optimization order: extension behavior → tool pack → crate tool contract → prompt guidance

Use scout for maps/seams; ask before major architecture; keep docs current after substantive drift.

### Smoke (after code / import change)

```bash
cd /home/datht/code/do
cargo check -p xai-grok-pager-bin
```

Targeted packages only unless full workspace is required to fix import breakage.

### Quality

- During iteration: targeted `cargo check` / `cargo test -p <crate>`
- Full workspace only when needed (import breakage, release prep)
- Docs-only milestones: file existence + link consistency; no full cargo required
- Universal ship process: [`docs/milestone-ship-discipline.md`](./docs/milestone-ship-discipline.md)

## Documentation Rules

Keep current:

- `docs/` + [`docs/index.md`](./docs/index.md)
- **`CHANGELOGS.md`** — append on ship (not a second Status essay)
- **`docs/future-plan.md`** — long parking lot; root Future Plan stays short
- **`docs/current-status.md`** — optional expanded status; root AGENTS stays compact
- This file — operating contract + compact living status

After milestone:

1. Update `docs/` for that milestone
2. Append [`CHANGELOGS.md`](./CHANGELOGS.md)
3. Update **Current Status** / **Next steps** in this file if true-now changed
4. Conventional commit for the milestone; handoff includes `commitId`

| Artifact | For |
|----------|-----|
| `docs/*.md` | Durable design / inventory / APIs |
| `CHANGELOGS.md` | What shipped |
| Root AGENTS living | Compact Status + Next steps + short Future Plan |
| `docs/current-status.md` | Expanded narrative status |
| `docs/future-plan.md` | Long parking lot |
| `plans/reports/` | Multi-step evidence, scorecards |

**Never** dump long future backlog into root `AGENTS.md` — park it in `docs/future-plan.md`.

## Living status and backlog

| Where | When |
|-------|------|
| **`CHANGELOGS.md`** | Always append on substantive ship |
| **Current Status** | Only if compact “true *now*” would be wrong (≤ ~15 bullets) |
| **Next steps** | Ordered near-term; remove completed |
| **Future Plan** (this file) | Short active ideas only |
| **`docs/future-plan.md`** | Long parking lot; promote into root Future Plan / Next steps when ready |

## Development Flow

When task is **done** (see also [`docs/milestone-ship-discipline.md`](./docs/milestone-ship-discipline.md)):

1. **Verify** — code: `cargo check -p xai-grok-pager-bin` (or agreed package); docs-only: existence + VAL coverage
2. **Document** — under `docs/`; CHANGELOGS; Next steps / Status if needed
3. **Commit** — conventional `type(scope): subject`; atomic; every milestone; no secrets
4. **Handoff** — include `commitId` + `repoPath` (missing = incomplete/fail)

Skip commit only if user says so or no file changes. Working-tree-only “done” without commit is incomplete.

## Current Status

Date: 2026-07-16

**Ship history:** [`CHANGELOGS.md`](./CHANGELOGS.md) · **Expanded status:** [`docs/current-status.md`](./docs/current-status.md) · **Long Future parking lot:** [`docs/future-plan.md`](./docs/future-plan.md) · **Models:** [`docs/models-and-config.md`](./docs/models-and-config.md)

- **Mission** — `mis_413072d4` active; M0 not sealed
- **Fork import** — grok-build tree present under `/home/datht/code/do` (F-FORK-001 done)
- **Build smoke** — **sealed** (F-FORK-002 / VAL-FORK-002): `cargo check -p xai-grok-pager-bin` exit 0; needs `dotslash` for `bin/protoc`
- **Control plane** — root `AGENTS.md` + docs split **sealed** (F-CTRL-001 / VAL-CTRL-001..003): index, architecture, future-plan, current-status, ship-discipline, related-projects, **models-and-config** + CHANGELOGS + README; mission AGENTS points here
- **Multi-model (L13)** — **sealed** (F-MODEL-001 / VAL-MODEL-001..002): `docs/models-and-config.md` (fork evidence + OpenCode gap + YAML schema + TOML map); template `do-harness/config.models.yaml`; L13 in `docs/limitations.md` + `docs/patch-matrix.md`
- **Role switch lock** — **sealed** (F-ROLE-001 / VAL-ROLE-001): Tab/Shift+Tab **only pre-message**; disabled after first user message / conversation content; M1 implements (see `docs/prompt-system.md` Role lifecycle + M1 note)
- **Scout** — pi-ness harness ideas + grok native tools inventory in mission architecture / L1–L12 sketch; L13 assignment UX documented
- **Grok-build inventory** — **sealed** (F-GROK-001 / VAL-GROK-001): `docs/grok-build/` README + overview, native-tools, extension-seams, hard-limits, patterns — fork evidence paths; linked from `docs/index.md`
- **Not yet** — L1–L12 deep evidence (F-DOC-001..003); capability-map; do-harness proof agent + guided hook; YAML→agent wiring (M1); M0 seal commit
- **Process** — git at do; commit every milestone; docs under `/docs`; English + conventional commits

### Next steps

1. M0: deepen L1–L12 in limitations/patch-matrix + write capability-map (F-DOC-001..003) — cite `docs/grok-build/*`
2. M0: README identity + `FORK.md` policy expansion (F-DOC-004)
3. M0: proof intake agent + guided PreToolUse hook + discovery verification
4. M0: `docs/backlog-m1-m3.md` including multi-model assignment wiring + **role Tab cycle + post-message lock** + seal commit
5. M1: roles + prompt layers on grok seams; **wire role→model from do YAML into agents**; **implement Tab/Shift+Tab role cycle with post-first-message lock**
6. M2: continuation coordinator + guided-block safety
7. M3: native power tools (CodeGraph, hashline default policy)

### Future Plan

_Short list only. Full parking lot: [`docs/future-plan.md`](./docs/future-plan.md). Promote to Next steps when ready._

- Goal-as-mission full runner (validators + structured handoffs on grok continuum)
- Side-ask dual stream / intake productization
- CodeGraph native or MCP lean tools
- `~/.do` rebrand when extension path is proven (keep `~/.grok` for M0)
- Multi-provider auth beyond stock grok paths
- Progressive skill/MCP catalog dynamic mode parity with pi-ness
- OpenCode-parity permission rules surface in do YAML (beyond model assignment)
- Role-cycle UX polish after M1 lock policy ships (no mid-session hop)

## Non-Goals

- Full OpenTUI / Node port of pi-ness TUI
- Reinventing native tools grok already has (`plan`, `update_goal`, hashline, `task`, `lsp`, …)
- Replacing stock multi-model TOML with a competing registry (overlay + map, don’t fight the base)
- Upstream PRs to xAI grok-build (private/local fork path)
- Speculative abstractions before M0 baseline seals
- Deep pager/TUI fork before extension seams are exhausted
