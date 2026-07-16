# CHANGELOGS

Append-only ship log for **do**. Not a status essay — one entry per substantive milestone or control-plane change.

---

## 2026-07-16 — F-DOC-002 patch-matrix L1–L13 seal

**Scope:** docs only (`docs/patch-matrix.md`, index, living status)  
**Feature:** F-DOC-002 · **VAL:** VAL-DOC-002

### Sealed

- `docs/patch-matrix.md` maps **every L1–L13** gap to:
  - Preferred path (`plugin` | `hook` | `agent` | `skill` | `tool_pack` | `crate_patch` | `defer` + `config` overlay)
  - Risk band
  - Recommended implementation **order** (master table + expanded rows)
- Expanded per-gap fields: seams, avoid, milestone, links to limitations + grok-build extension-seams / hard-limits
- Crate patch log scaffold (empty — no product crate patches yet)
- Milestone → matrix slice (M0–M3)
- Living status + `docs/index.md` updated

### Not in scope

- F-DOC-003 capability-map
- Runtime implementation of any L* gap

### Files

- `docs/patch-matrix.md`
- `docs/index.md`
- Root `AGENTS.md` living status + next steps
- `docs/current-status.md`
- `docs/limitations.md` (cross-ref only)
- This CHANGELOGS entry

---

## 2026-07-16 — F-DOC-001 limitations L1–L13 seal

**Scope:** docs only (`docs/limitations.md`, index, living status)  
**Feature:** F-DOC-001 · **VAL:** VAL-DOC-001

### Sealed

- `docs/limitations.md` complete evidence-backed inventory for **L1–L13**:
  - Each row: idea (pi-ness / OpenCode) → stock grok status → gap → preferred path → absolute evidence paths
  - L1 role control + post-message lock; L2 prompt layers; L3 native factories; L4 progressive catalog; L5 continuation; L6 guided blocks; L7 CodeGraph; L8 side-ask/intake; L9 workspace disk; L10 fork hygiene; L11 Rust UI cost; L12 patch mergeability
  - **L13:** multi-model registry **already exists** (`[model.*]`, spawn > role > persona > parent); gap is **assignment UX** + do YAML wire (cross-link models-and-config)
- Linked from `docs/index.md`; living status updated (root `AGENTS.md`, `docs/current-status.md`)

### Evidence sources

- pi-ness (read-only): `packages/piness-core/src/native/*`, `docs/{prompt-system,hooks,skill-catalog,workspace,side-ask}.md`
- Fork: `crates/codegen/xai-grok-{agent,hooks,tools,subagent-resolution,codebase-graph,...}`; `docs/grok-build/*`

### Not in scope

- F-DOC-002 patch-matrix refine; F-DOC-003 capability-map
- Runtime implementation of any L* gap

### Files

- `docs/limitations.md`
- `docs/index.md`
- Root `AGENTS.md` living status + next steps
- `docs/current-status.md`
- This CHANGELOGS entry

---

## 2026-07-16 — F-GROK-001 grok-build inventory seal

**Scope:** docs only (`docs/grok-build/*`, index already linked, living status)  
**Feature:** F-GROK-001 · **VAL:** VAL-GROK-001

### Sealed

- `docs/grok-build/` complete and evidence-backed from forked tree:
  - `README.md` — section index + how to use
  - `overview.md` — crate map, entry points (pager-bin → shell headless/leader/stdio), multi-model + registry note
  - `native-tools.md` — namespaces, `ToolKind`, full builder registration list, version-managed IDs, hashline vs standard `FileToolset`
  - `extension-seams.md` — do-harness, agents, hooks, plugins, skills, config, `register_tool_pack`, MCP, subagent resolution, ACP
  - `hard-limits.md` — process + architecture limits; dual-registry ban; what not to reinvent
  - `patterns.md` — plan/goal/task/hashline/hooks/registry/MCP/scheduler/ACP patterns + anti-patterns
- All six files linked from `docs/index.md` under **Grok-build inventory**
- Living status updated (root `AGENTS.md`, `docs/current-status.md`)

### Evidence highlights (fork paths)

- `ToolRegistryBuilder::new()` registration: `crates/codegen/xai-grok-tools/src/registry/types.rs`
- `ToolNamespace` / `ToolKind`: `crates/codegen/xai-grok-tools/src/types/tool.rs`
- Agent discovery order: `crates/codegen/xai-grok-agent/src/discovery.rs`
- Subagent precedence: `crates/codegen/xai-grok-subagent-resolution/`
- Hooks: `xai-hooks-plugins-types` + `xai-grok-hooks`
- Hashline config: `xai-grok-shell/src/tools/config.rs` (`FileToolset`)

### Not in scope

- L1–L12 deep limitations rewrite (F-DOC-001)
- capability-map (F-DOC-003)
- Runtime wiring of do-harness

### Files

- `docs/grok-build/*` (six docs)
- Root `AGENTS.md` living status + next steps
- `docs/current-status.md`
- This CHANGELOGS entry

---

## 2026-07-16 — F-FORK-002 cargo check smoke seal

**Scope:** build environment + docs note (no product crate patches)  
**Feature:** F-FORK-002 · **VAL:** VAL-FORK-002

### Sealed

- `cargo check -p xai-grok-pager-bin` from `/home/datht/code/do` exits **0** (locked workspace)
- Host prerequisite: **`dotslash`** on `PATH` so repo `bin/protoc` (dotslash wrapper → protoc 29.3) executes; without it, `xai-grok-tools-api` build.rs fails
- Documented in `README.md` Build section

### Not required / not done

- No import/path source fixes were needed for check
- Full workspace `cargo test` not in scope

### Files

- `README.md` — Build requirements (`dotslash`, smoke command)
- Root `AGENTS.md` living status + next steps
- `docs/current-status.md`
- This CHANGELOGS entry

---

## 2026-07-16 — F-CTRL-001 control plane seal

**Scope:** docs / AGENTS / README / CHANGELOGS (no Rust product code)  
**Feature:** F-CTRL-001 · **VALs:** VAL-CTRL-001, VAL-CTRL-002, VAL-CTRL-003

### Added / sealed

- Root `AGENTS.md` as pi-ness-style operating contract (direction, hard constraints, customization order, gates, documentation rules, living status, models & config control)
- Docs split under `docs/` (all linked from `docs/index.md`):
  - `index.md`, `architecture.md`, `future-plan.md`, `current-status.md`
  - `milestone-ship-discipline.md`, `related-projects.md`
  - **`models-and-config.md`** — grok multi-model facts, OpenCode gap, do YAML overlay design, **L13**
  - Stubs: `prompt-system.md`, `workspace.md`
- `CHANGELOGS.md` + product-framed `README.md`
- Mission `AGENTS.md` points workers at `/home/datht/code/do/AGENTS.md` and keeps mission boundaries
- Ship discipline: verify → document under `docs/` + CHANGELOGS → conventional commit every milestone → handoff with `commitId` + `repoPath`

### Product decisions recorded

- Stock multi-model remains `~/.grok/config.toml` (many `[model.*]`, default, role/persona/spawn resolution)
- do product YAML overlay for assignment UX; map into TOML + agent frontmatter
- Multi-model assignment is a first-class M0 requirement (L13), M1 wire
- Role Tab/Shift+Tab cycle only pre-message; lock after first user message (document M0, implement M1)

### Not in this entry

- `cargo check` smoke (F-FORK-002)
- Evidence limitations / patch-matrix / capability-map (F-DOC-001..003)
- Proof agent + guided hook (F-EXT-*)
- Formal F-MODEL-001 worker seal

---

## 2026-07-16 — F-ROLE-001 role switch lock policy seal

**Scope:** docs only (AGENTS, prompt-system, architecture, status)  
**Feature:** F-ROLE-001 · **VAL:** VAL-ROLE-001

### Sealed

- **Tab / Shift+Tab** role cycle **only** at session start (empty transcript / no user messages)
- **Disabled** after first user message or any conversation content — no mid-session role hop
- Model re-assignment from role only while switch is still allowed
- **M1** is the implementation milestone (session flag, keybind gate, L1 stack freeze, role→model wire)
- M1 implementation note seeded in `docs/prompt-system.md` and `docs/architecture.md` for F-BACK-001 backlog pickup

### Files

- Root `AGENTS.md` — Hard Constraints + Session / role control + living status
- `docs/prompt-system.md` — Role lifecycle + M1 implementation note
- `docs/architecture.md` — Session / role control table + M1 note
- `docs/current-status.md` — F-ROLE-001 marked done

---

## 2026-07-16 — F-MODEL-001 multi-model + L13 seal

**Scope:** docs + do-harness YAML template (no Rust product code)  
**Feature:** F-MODEL-001 · **VALs:** VAL-MODEL-001, VAL-MODEL-002

### Sealed

- `docs/models-and-config.md` — grok multi-`[model.*]` facts with **fork evidence paths**, subagent resolution spawn > role > persona > parent, OpenCode assignment gap, do YAML schema, map to TOML + agent/role model fields, full **L13** statement; example ≥2 models and ≥3 role assignments
- `do-harness/config.models.yaml` — template with `models.registry` + `assignment` (intake/orchestrator/explorer/worker/oracle) and comments; not auto-applied in M0
- `docs/limitations.md` — L1–L13 inventory; L13 detail with evidence table
- `docs/patch-matrix.md` — every L1–L13 → path/risk/order; L13 = `config` + `agent`, low risk, M1 wire

### Product decisions confirmed

- Multi-model registry **already exists** in stock grok — do not reimplement
- Gap is assignment UX / role→model **policy** (L13)
- Dual surface: stock TOML runtime + do YAML product overlay
- M1 wires YAML assignment into agents/roles; no second runtime registry

### Files

- `docs/models-and-config.md`, `docs/limitations.md`, `docs/patch-matrix.md`, `docs/index.md`
- `do-harness/config.models.yaml`
- Root `AGENTS.md` living status, `docs/current-status.md`, this CHANGELOGS entry
