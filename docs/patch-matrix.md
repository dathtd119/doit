# Patch matrix (L1–L13)

**Status:** M0 **sealed** for F-DOC-002 / VAL-DOC-002 — every gap maps to preferred path, risk, and recommended order. Expanded from F-MODEL-001 L13 row + architecture stubs; evidence deepened via [limitations.md](./limitations.md) and [grok-build/](./grok-build/).

**How to use:** Pick work by **Order** (lower first). Prefer extension seams ([grok-build/extension-seams.md](./grok-build/extension-seams.md)) before [hard-limits.md](./grok-build/hard-limits.md). Every actual crate diff must add a dated entry under [Crate patch log](#crate-patch-log).

---

## Path vocabulary

| Path | Meaning |
|------|---------|
| `plugin` | Installable bundle (skills + hooks + agents + MCP) via grok plugin discovery |
| `hook` | Pre/Post tool / session hooks (`PreToolUse`, …) |
| `agent` | Agent/persona profiles under discovery paths (`do-harness/agents/`, `.grok/agents/`) |
| `skill` | Skill files + discovery / reminder tuning |
| `tool_pack` | In-process `register_tool_pack` before first `ToolRegistryBuilder::new()` |
| `crate_patch` | Surgical edit under `crates/` — last resort; document here |
| `defer` | Explicit non-work or late milestone; do not implement now |
| `config` | Stock TOML / do YAML overlays / docs contracts (product overlay; not a second runtime) |

Primary VAL paths are the first seven. `config` is allowed when the gap is policy/docs/mapping with no new agent/hook binary surface.

**Extension order (binding):** `config` / `agent` / `hook` / `plugin` / `skill` → `tool_pack` → `crate_patch` → deep TUI (`defer` until explicit decision).

---

## Master order table

Recommended **implementation / product order** (not limitation ID order). Risk is for the preferred path as written; escalating to `crate_patch` raises risk one band.

| Order | ID | Preferred path | Risk | Milestone | One-line intent |
|------:|----|----------------|------|-----------|-----------------|
| 1 | L10 | `config` + docs (`FORK.md`) | Low | M0 | Fork hygiene, identity, never touch sibling trees |
| 2 | **L13** | **`config` (do YAML) + `agent`** | **Low** | M0 template / **M1 wire** | Assignment UX only; multi-model registry already exists |
| 3 | L1 | `agent` + `config` (+ optional `crate_patch` for Tab lock) | Medium | **M1** | Primary-session role roster + **post-first-message lock** |
| 4 | L6 | `hook` (+ small `crate_patch` only if gate format needs tools-api) | Low–Medium | M0 proof / M2 harden | Guided blocks `[GATE:…]` + **Do this instead** |
| 5 | L8 | `agent` (`defer` dual-stream UI) | Low / High if TUI | M0 intake / later | Intake default profile first; side-ask UI deferred |
| 6 | L9 | `config` + docs | Low | M0–M1 | Map product workspace semantics onto `.grok` / thin `.do/` |
| 7 | L2 | `plugin` / prompts + optional `crate_patch` | Medium | M1 | L0–L6 mapping onto grok inject points |
| 8 | L4 | `config` + `skill` (+ optional `crate_patch`) | Medium | M1–M2 | Progressive skill/MCP catalog (not firehose dump) |
| 9 | L5 | `hook` first; coordinator `crate_patch` only if races remain | Medium / **High** if crate | **M2** | Continuation priority lanes over native goal/plan/todo |
| 10 | L3 | `plugin` + `hook` + `tool_pack` | Medium | M1–M3 | Re-express always-on harness without TS factories |
| 11 | L7 | `plugin` / MCP; optional `tool_pack` later | Medium | **M3** | CodeGraph lean agent surface (crate graph already exists) |
| 12 | L11 | `defer` deep TUI / OpenTUI | High | M2+ only if decided | Accept ratatui; plugins before pager fork; **no OpenTUI M0–M1** |
| 13 | L12 | process: document every `crate_patch` | Ongoing | Always | Minimize core diffs; merge hygiene |

---

## Expanded rows (L1–L13)

Each row: gap → path → risk → order → seams → avoid → links.

### L1 — Primary-session role control + post-message lock

| Field | Value |
|-------|--------|
| **Gap** | Main session is not intake→orchestrator role machine; Tab cycle + **lock after first user message** not implemented |
| **Preferred path** | `agent` + `config`; optional `crate_patch` only for session flag / keybind gate if seams fail |
| **Risk** | **Medium** — wrong mid-session hop pollutes system/role stack; lock policy is product-binding |
| **Order** | **3** (after L10 hygiene + L13 assignment template; with L13 wire in M1) |
| **Milestone** | M0 document (done: VAL-ROLE-001); **M1 implement** |
| **Seams** | `do-harness/agents/`; agent discovery `crates/codegen/xai-grok-agent/src/discovery.rs`; role→model via L13; shell keybinds only if needed |
| **Avoid** | Mid-session role hop; deep TUI role UI before lock policy ships |
| **Evidence / design** | [limitations.md § L1](./limitations.md#l1--primary-session-role-control--post-message-lock); [prompt-system.md](./prompt-system.md) Role lifecycle; root `AGENTS.md` Role switch lock |
| **Hard limit note** | [hard-limits.md](./grok-build/hard-limits.md) Main-session role machine gaps |

### L2 — L0–L6 layered prompt assembly

| Field | Value |
|-------|--------|
| **Gap** | No explicit L0–L6 control plane or fragment maxBytes registry |
| **Preferred path** | `plugin` / `do-harness/prompts/` + agent templates; `crate_patch` only for budget/registry |
| **Risk** | **Medium** — over-injection vs silent budget cuts; map layers before inventing a second prompt engine |
| **Order** | **7** |
| **Milestone** | M1 roles + prompt layers |
| **Seams** | Agent prompts, skills, `SkillDiscoveryReminder`, plugin injects; [extension-seams.md](./grok-build/extension-seams.md) § Skills / Plugins |
| **Avoid** | Pasting full L6 disk bodies into system (re-read disk — L9) |
| **Evidence / design** | [limitations.md § L2](./limitations.md#l2--l0l6-layered-prompt-assembly); [prompt-system.md](./prompt-system.md) |

### L3 — Always-on native harness factories

| Field | Value |
|-------|--------|
| **Gap** | No pi-ness TS `NATIVE_HARNESS_EXTENSION_FACTORIES`; always-on is Rust + plugins/hooks |
| **Preferred path** | `plugin` + `hook` + `tool_pack` (when in-process tools required) |
| **Risk** | **Medium** — double-register tool packs; fighting monolithic registry |
| **Order** | **10** (compose behaviors after L1/L6/L2 surfaces exist) |
| **Milestone** | M1–M3 incremental |
| **Seams** | `register_tool_pack` in `crates/codegen/xai-grok-tools/src/registry/types.rs` (**before** first `ToolRegistryBuilder::new()`); hooks; plugins |
| **Avoid** | Porting TS factories 1:1; ignoring pack ordering contract |
| **Evidence / design** | [limitations.md § L3](./limitations.md#l3--always-on-native-harness-factories); [hard-limits.md](./grok-build/hard-limits.md) No TS harness factories |

### L4 — Progressive skill / MCP catalog

| Field | Value |
|-------|--------|
| **Gap** | Skill/MCP listing may firehose vs pi-ness `skill_search` / `skill_load` dynamic mode |
| **Preferred path** | `config` + `skill` (ignore lists, reminder tuning); optional `crate_patch` on skill prompt builder; keep MCP via `search_tool` / `use_tool` |
| **Risk** | **Medium** — context bloat if dump mode remains default |
| **Order** | **8** |
| **Milestone** | M1–M2 |
| **Seams** | Skills discovery + `SkillDiscoveryReminder`; MCP crate + progressive search/use ([native-tools.md](./grok-build/native-tools.md), [extension-seams.md](./grok-build/extension-seams.md) § Skills / MCP) |
| **Avoid** | Always-on full skill body dump; parallel MCP client in do-harness |
| **Evidence / design** | [limitations.md § L4](./limitations.md#l4--progressive-skill--mcp-catalog) |

### L5 — Continuation coordinator

| Field | Value |
|-------|--------|
| **Gap** | Goal classifier, plan mode, todos exist **separately** — no unified priority (interrupt→streak→goal→plan→workflow→todo) |
| **Preferred path** | `hook` / SessionActor policy first; dedicated coordinator `crate_patch` only if multi-lane races remain |
| **Risk** | **Medium** on hooks; **High** if early coordinator crate without measuring races |
| **Order** | **9** |
| **Milestone** | **M2** |
| **Seams** | Native `update_goal`, `enter_plan_mode` / `exit_plan_mode`, `todo`, `task` — **compose, do not reinvent** ([patterns.md](./grok-build/patterns.md)) |
| **Avoid** | Second plan/goal state machine; thrashing without settle-continue policy |
| **Evidence / design** | [limitations.md § L5](./limitations.md#l5--continuation-coordinator); [workspace.md](./workspace.md) |

### L6 — Guided blocks (`[GATE:…]` + Do this instead)

| Field | Value |
|-------|--------|
| **Gap** | Denials less “teach the model”; bare “Permission denied” thrash risk |
| **Preferred path** | `hook` (PreToolUse / PermissionDenied); small `crate_patch` only if shared tools-api gate format required |
| **Risk** | **Low–Medium** — hook-only proof is low risk; format fragmentation if many denial shapes |
| **Order** | **4** (early safety teaching; M0 proof F-EXT-002) |
| **Milestone** | M0 proof hook; M2 harden product-wide |
| **Seams** | `HookEvent::PreToolUse` — `xai-hooks-plugins-types`, `xai-grok-hooks`; permissions under `xai-grok-workspace` |
| **Avoid** | Bare deny strings; gate names missing from system/role prompts |
| **Evidence / design** | [limitations.md § L6](./limitations.md#l6--guided-blocks-gate--do-this-instead); root `AGENTS.md` Guided blocks constraint |
| **Proof features** | F-EXT-002, F-EXT-003 |

### L7 — CodeGraph lean tools

| Field | Value |
|-------|--------|
| **Gap** | `xai-codebase-graph` exists; lean agent tool / default MCP product surface missing |
| **Preferred path** | `plugin` / MCP wrapping local index first; optional `tool_pack` later |
| **Risk** | **Medium** — reinventing index vs productizing existing crate |
| **Order** | **11** |
| **Milestone** | **M3** |
| **Seams** | `crates/codegen/xai-codebase-graph/`; MCP extension seams |
| **Avoid** | Greenfield graph from zero; ignoring existing crate ([hard-limits.md](./grok-build/hard-limits.md) What not to reinvent) |
| **Evidence / design** | [limitations.md § L7](./limitations.md#l7--codegraph-lean-tools) |

### L8 — Side-ask dual stream / intake default role

| Field | Value |
|-------|--------|
| **Gap** | No side dual-stream product; intake profile is proof work, not full side-ask |
| **Preferred path** | `agent` for intake; **`defer`** dual-stream UI (ties to L11) |
| **Risk** | **Low** for intake agent; **High** if dual-stream TUI pursued early |
| **Order** | **5** (intake early; UI deferred) |
| **Milestone** | M0 F-EXT-001 intake; dual-stream parking lot |
| **Seams** | Agent discovery; `ask_user_question` tool (use, do not replace) |
| **Avoid** | OpenTUI dual-stream port; main-transcript pollution without product design |
| **Evidence / design** | [limitations.md § L8](./limitations.md#l8--side-ask-dual-stream--intake-default-role); [future-plan.md](./future-plan.md) |

### L9 — Workspace disk state (`.piness/` vs session layout)

| Field | Value |
|-------|--------|
| **Gap** | Different layout/semantics than pi-ness `.piness/`; need documented contract |
| **Preferred path** | `config` + docs; reuse native plan/goal/todo tools |
| **Risk** | **Low** if map-only; **Medium** if dual-write `.do/` + session dirs |
| **Order** | **6** |
| **Milestone** | M0–M1 document; thin `.do/` only if proven needed |
| **Seams** | Session dir + native continuum tools; [workspace.md](./workspace.md) |
| **Avoid** | Dual-write continuum; pasting full plan/goal bodies into prompts |
| **Evidence / design** | [limitations.md § L9](./limitations.md#l9--workspace-disk-state-piness-vs-session-layout) |

### L10 — Fork hygiene / identity

| Field | Value |
|-------|--------|
| **Gap** | do is a fork — must own rebases, branding, licenses; not overlay-on-Pi |
| **Preferred path** | `config` + docs (`FORK.md`, README); process only |
| **Risk** | **Low** when followed; **catastrophic** if sibling trees are modified |
| **Order** | **1** (first — always) |
| **Milestone** | M0 F-DOC-004 / VAL-DOC-004 — FORK.md + README sealed |
| **Seams** | N/A code; policy in root `AGENTS.md`, mission boundaries |
| **Avoid** | Editing `/home/datht/code/pi-ness` or `/home/datht/code/grok-build`; external upstream PRs as product path |
| **Evidence / design** | [limitations.md § L10](./limitations.md#l10--overlay-first-without-forking-pi--fork-hygiene-for-do); [hard-limits.md](./grok-build/hard-limits.md) process limits |

### L11 — Node/OpenTUI vs Rust/ratatui

| Field | Value |
|-------|--------|
| **Gap** | Different UI stack; deep pager fork cost high |
| **Preferred path** | **`defer`** OpenTUI and deep TUI; extend via `plugin` / `hook` / `agent` |
| **Risk** | **High** if deep pager fork before extension exhaustion |
| **Order** | **12** |
| **Milestone** | **No OpenTUI M0–M1**; M2+ only with explicit decision |
| **Seams** | Prefer non-TUI product surfaces; pager crates only as last resort |
| **Avoid** | Full OpenTUI port; early `xai-grok-pager*` deep fork |
| **Evidence / design** | [limitations.md § L11](./limitations.md#l11--nodeopentui-vs-rustratatui); root `AGENTS.md` Non-Goals |

### L12 — Patch mergeability / core diffs

| Field | Value |
|-------|--------|
| **Gap** | Full source tree makes patches easy and merge hygiene hard |
| **Preferred path** | Process: prefer extension; every `crate_patch` logged below |
| **Risk** | **Ongoing** — untracked core diffs break future import refreshes |
| **Order** | **13** (always-on discipline, not a feature sprint) |
| **Milestone** | Continuous |
| **Seams** | Customization order in root `AGENTS.md`; generated root `Cargo.toml` is not hand-edit SoT |
| **Avoid** | Undocumented crate edits; large non-surgical diffs |
| **Evidence / design** | [limitations.md § L12](./limitations.md#l12--patch-mergeability--core-diffs); [milestone-ship-discipline.md](./milestone-ship-discipline.md) |

### L13 — Multi-model assignment UX (not missing multi-model)

| Field | Value |
|-------|--------|
| **Gap** | Assignment UX / role→model **policy** weaker than OpenCode; do YAML not auto-applied |
| **Preferred path** | **`config`** (YAML overlay) → **`agent`** / role frontmatter; stock TOML remains runtime registry |
| **Risk** | **Low** if overlay-only; **Medium** if operators expect auto-wire before M1; **High** if second runtime registry |
| **Order** | **2** (template M0; wire with L1 in M1) |
| **Milestone** | M0 template + docs (done); **M1 wire** |
| **Seams** | `do-harness/config.models.yaml`; `~/.grok/config.toml` `[model.*]`; subagent resolution spawn > role > persona > parent; agent frontmatter model |
| **Avoid** | Competing runtime registry; early `crate_patch` for assignment; claiming stock grok is single-model |
| **Evidence / design** | [limitations.md § L13](./limitations.md#l13--multi-model-assignment-ux-not-missing-multi-model); [models-and-config.md](./models-and-config.md); template `do-harness/config.models.yaml` |
| **Validators** | VAL-MODEL-001, VAL-MODEL-002 |
| **Coupling** | Role→model re-assign only while L1 pre-message switch allowed |

---

## Decision rules

1. **Prefer extension** (`config` / `agent` / `hook` / `plugin` / `skill`) before `tool_pack` before `crate_patch` before deep TUI.  
2. **Ask placement** before always-on behavior or promoting config → crate (root `AGENTS.md` Native vs Extension vs Crate Patch).  
3. **Do not reinvent** native plan / goal / todo / task / hashline / MCP / multi-`[model.*]` — compose product policy on top ([hard-limits.md](./grok-build/hard-limits.md)).  
4. **Dual config for models:** do YAML policy + `~/.grok/config.toml` runtime — do not fight the base.  
5. **Guided denials (L6):** incomplete until gate is named in prompts **and** result uses `[GATE: …]` + **Do this instead**.  
6. **Every crate patch** adds a dated row in the log below (crate path, reason, linked L*, risk).

---

## Crate patch log

| Date | Crate / path | L* | Reason | Risk | Alternatives exhausted |
|------|--------------|----|--------|------|------------------------|
| 2026-07-16 | `xai-grok-shell` `session/role_switch.rs` + `acp_session_impl/session_mode.rs` | L1 | Session flag `role_switch_allowed` + gate product-role `session/set_mode` after first turn so L1 prompt freeze is enforced server-side | Medium | Agents/hooks cannot observe turn_count or refuse ACP set_mode; pure policy module is shared, not a deep TUI fork |
| 2026-07-16 | `xai-grok-pager` `dispatch/modes.rs`, `agent_view/prompt.rs`, `actions` | L1 | Tab/Shift+Tab product-role cycle pre-message; no-op after lock (Shift+Tab reverts to plan/yolo CycleMode) | Medium | Keybind lives in pager input path; extension-only cannot intercept Tab before completion UI |
| 2026-07-16 | `xai-grok-shell` `session/role_switch.rs` + `acp_session_impl/session_mode.rs` | L13 + L1 | Role→model re-pin from agent frontmatter (YAML assignment) only while `role_switch_allowed`; post-lock Keep; subagent spawn path untouched | Medium | Apply script only writes frontmatter; primary session must re-pin on pre-message set_mode — hooks cannot change sampling config |

### Planned (not applied) — P-NOTEL from grok-build-no-telemetry

Source: `~/code/grok-build-no-telemetry/patches/0001`–`0006`. Scout: [`plans/reports/scout-grok-build-no-telemetry-260716.md`](../plans/reports/scout-grok-build-no-telemetry-260716.md). Keep `GROK_EXTERNAL_OTEL`. **Do not treat as applied.**

| ID | Status | Scope (one-line) | Upstream patch | Risk |
|----|--------|------------------|----------------|------|
| **P-NOTEL-01** | **planned** | Fail-closed product analytics + telemetry config defaults | `0001-disable-product-analytics.patch` | Medium |
| **P-NOTEL-02** | **planned** | Neuter Mixpanel crate (defense-in-depth no-op) | `0002-neuter-mixpanel-crate.patch` | Low |
| **P-NOTEL-03** | **planned** | Disable Sentry / error reporting | `0003-disable-sentry.patch` | Low |
| **P-NOTEL-04** | **planned** | Disable internal OTLP export; preserve external OTEL | `0004-disable-otlp-export.patch` | Medium |
| **P-NOTEL-05** | **planned** | Disable trace upload paths | `0005-disable-trace-upload.patch` | Low–Medium |
| **P-NOTEL-06** | **planned** | Disable feedback extension / resolve_feedback | `0006-disable-feedback.patch` | Low |

---

## Milestone → matrix slice

| Milestone | Matrix focus |
|-----------|----------------|
| **M0** | L10 docs; L13 template; L6/L8 proof (hook + intake agent); this matrix + limitations sealed |
| **M1** | L1 Tab lock + role roster; L13 YAML→agent wire; L2 prompt layers; start L4 |
| **M2** | L5 continuation; L6 harden; L4 progressive catalog; L11 only if explicit |
| **M3** | L7 CodeGraph product surface; L3 tool packs as needed; hashline default policy (backlog) |

---

## Related

- [limitations.md](./limitations.md) — evidence-backed gap inventory (authoritative “what”)  
- [models-and-config.md](./models-and-config.md) — L13 design home  
- [architecture.md](./architecture.md) — system layout + L1–L13 sketch  
- [grok-build/extension-seams.md](./grok-build/extension-seams.md) — where we can extend  
- [grok-build/hard-limits.md](./grok-build/hard-limits.md) — where we cannot casually fight  
- [grok-build/patterns.md](./grok-build/patterns.md) — adopt native plan/goal/task/hashline  
- Root [AGENTS.md](../AGENTS.md) — customization order, gates, living status  
- Capability mapping (module → API): [capability-map.md](./capability-map.md) (**sealed** F-DOC-003 / VAL-DOC-003)
