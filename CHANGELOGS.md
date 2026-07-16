# CHANGELOGS

Append-only ship log for **do**. Not a status essay — one entry per substantive milestone or control-plane change.

---

## 2026-07-16 — F-EXT-003 proof extension discovery verified

**Scope:** do-harness discovery verification + product README  
**Feature:** F-EXT-003 · **VAL:** VAL-EXT-003

### Sealed

- `do-harness/scripts/verify-discovery.sh` — scripted discovery-path check (exit 0):
  - project `.grok/agents/intake.md` and `.grok/hooks/*` on real grok paths
  - symlinks resolve to `do-harness/` source of truth
  - agent frontmatter + hook PreToolUse JSON shape
  - guided deny/allow self-test (`[GATE: …]`)
  - forked evidence citations (`discovery.rs`, `util/hooks.rs`)
  - optional binary `inspect` when a pager binary is built
- `do-harness/README.md` — layout, enablement, **verify commands** for VAL-EXT-003

### Not in scope

- Full binary-built inspect e2e when no binary is present (path check is authoritative per VAL-EXT-003(b))
- YAML→agent wiring / role Tab cycle (M1)
- M0 seal commit / backlog-m1-m3 (F-BACK-001)

### Files

- `do-harness/scripts/verify-discovery.sh`
- `do-harness/README.md`
- This CHANGELOGS entry

---

## 2026-07-16 — F-EXT-002 guided PreToolUse hook proof

**Scope:** do-harness hooks + project discovery install  
**Feature:** F-EXT-002 · **VAL:** VAL-EXT-002

### Sealed

- `do-harness/hooks/guided-dangerous-shell.json` — PreToolUse matcher for shell tools (`Bash` / `run_terminal_cmd` / …)
- `do-harness/hooks/bin/guided-dangerous-shell.py` — deny dangerous patterns (`rm -rf /`, `sudo rm`, `pkill`/`killall`, `mkfs`, `dd … of=/dev/…`, fork bombs, device redirects) with **guided-block** reason:
  - `[GATE: …]` + **Do this instead** (+ optional Human involvement / Do not)
  - never bare “Permission denied”
- `do-harness/hooks/README.md` — enablement (project symlink / user-global copy) + verify commands
- Project discovery install: `.grok/hooks/guided-dangerous-shell.json` + `.grok/hooks/bin/guided-dangerous-shell.py` → symlinks to do-harness (same pattern as intake agent)

### Not in scope

- F-EXT-003 end-to-end discovery binary/script + top-level `do-harness/README.md`
- Full always-on guided-block productization (M2)

### Files

- `do-harness/hooks/guided-dangerous-shell.json`
- `do-harness/hooks/bin/guided-dangerous-shell.py`
- `do-harness/hooks/README.md`
- `.grok/hooks/*` (symlinks)
- This CHANGELOGS entry

---

## 2026-07-16 — F-EXT-001 intake agent profile proof

**Scope:** do-harness agent + project discovery install  
**Feature:** F-EXT-001 · **VAL:** VAL-EXT-001

### Sealed

- `do-harness/agents/intake.md` — grok-compatible agent definition (YAML frontmatter + prompt body):
  - `name: intake`, `permissionMode: plan`, clarify-only tools floor
  - Allowlist: `read_file`, `list_dir`, `grep`, `run_terminal_cmd`, `ask_user_question`, `Agent(explore)`
  - Denylist: edits, plan/goal/todo ownership tools
  - Intent Pack capture fields; no implementation; M1 model pin noted (`model: inherit` for M0)
- Project discovery install: `.grok/agents/intake.md` → symlink to `do-harness/agents/intake.md` (source of truth under do-harness; on path used by `xai-grok-agent` discovery walk)

### Not in scope

- F-EXT-002 guided PreToolUse hook
- F-EXT-003 end-to-end binary/scripted discovery verification + `do-harness/README.md`
- Full role roster / Tab cycle (M1)

### Files

- `do-harness/agents/intake.md`
- `.grok/agents/intake.md` (symlink)
- This CHANGELOGS entry

---

## 2026-07-16 — F-DOC-004 README + FORK policy seal

**Scope:** docs only (`README.md`, `FORK.md`, index, living status)  
**Feature:** F-DOC-004 · **VAL:** VAL-DOC-004

### Sealed

- `README.md` product intent: forked Grok Build + pi-ness harness control + OpenCode-style multi-model ergonomics; dual config; build smoke
- `FORK.md` fork hygiene and identity:
  - Extension-before-deep-fork order (do-harness → config/plugins → tool packs → crate patch → deep TUI)
  - Config root **`~/.grok` reuse for M0** (brand as do in docs; optional `~/.do` later)
  - Dual multi-model surface: stock TOML runtime + do YAML assignment overlay (L13 accurate facts)
  - No external upstream PRs as product path; sibling trees read-only; import by copy
  - License/notices and VAL-DOC-004 checklist
- Cross-linked from `docs/index.md`, living status, limitations L10 pointer

### Not in scope

- F-EXT proof agent/hook; F-BACK-001 backlog; YAML→agent runtime wire (M1)

### Files

- `README.md`
- `FORK.md` (new)
- `docs/index.md`
- Root `AGENTS.md` living status + next steps
- `docs/current-status.md`
- `docs/limitations.md` / `docs/patch-matrix.md` (FORK status cross-ref)
- This CHANGELOGS entry

---

## 2026-07-16 — F-DOC-003 capability-map seal

**Scope:** docs only (`docs/capability-map.md`, index, living status)  
**Feature:** F-DOC-003 · **VAL:** VAL-DOC-003

### Sealed

- `docs/capability-map.md` maps:
  - pi-ness **native modules** (tools, safety, continuum, session glue, subagent) → grok tools/APIs/hooks/config or `"gap"`
  - **L0–L6 / layer purposes** → grok inject points + do-harness homes
  - **Roles** and **continuum** (goal / plan / todo / continuation)
  - **Model registry + assignment** (L13 dual TOML + do YAML; resolution chain; M1 wire)
  - Explicit `"gap"` register with L* / milestone / preferred path
  - “Use, don’t reinvent” native tool table
- Cross-linked from `docs/index.md`, `docs/limitations.md`, living status

### Not in scope

- F-DOC-004 README/FORK; runtime wiring of any gap
- Implementation of L1 Tab lock or L13 YAML auto-apply

### Files

- `docs/capability-map.md` (new)
- `docs/index.md`
- `docs/limitations.md` (cross-ref)
- Root `AGENTS.md` living status + next steps
- `docs/current-status.md`
- This CHANGELOGS entry

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
