# Limitations inventory (L1–L13)

**Status:** M0 **sealed** for F-DOC-001 / VAL-DOC-001 — every row has evidence paths into **pi-ness** (read-only ideas) and/or **forked grok-build** under `/home/datht/code/do` (primary). L13 multi-model detail also lives in [models-and-config.md](./models-and-config.md).

**Product thesis:** pi-ness harness control + OpenCode assignment ergonomics on forked Grok Build. Each row: idea → stock grok status → gap → preferred path → evidence.

**How to use:** Prefer [grok-build/extension-seams.md](./grok-build/extension-seams.md) before [grok-build/hard-limits.md](./grok-build/hard-limits.md). Map work into [patch-matrix.md](./patch-matrix.md). Capability mapping (module → tool/API) is F-DOC-003 (`docs/capability-map.md`).

| Trees | Path | Access |
|-------|------|--------|
| Ideas (pi-ness) | `/home/datht/code/pi-ness` | **Read-only** |
| Base (upstream sibling) | `/home/datht/code/grok-build` | **Read-only** |
| Fork (evidence + product) | `/home/datht/code/do` | Writable |

Absolute paths below are preferred; crate paths without a prefix mean under `/home/datht/code/do`.

---

## Summary table

| ID | Idea | Stock grok-build | Gap / risk | Preferred path |
|----|------|------------------|------------|----------------|
| L1 | Role roster as **primary session** control + tool/skill deny floors; **Tab cycle only pre-message, lock after first message** | Agents + personas strong for **subagents**; not full intake→orchestrator primary role machine | Primary-session role cycle weaker than pi-ness; post-message lock not implemented | `agent` + `config`; M1 Tab cycle + lock; crate only if keybind/session flag cannot land via seams |
| L2 | L0–L6 layered prompt assembly + fragment registry/maxBytes | System/agent prompts, skills, reminders — different assembly model | No explicit L0–L6 control plane or fragment budgets | Prompt templates + plugin injects; crate patch for budget/registry if needed |
| L3 | Always-on native harness factories (TS) | Monolithic Rust tool registry + plugins/hooks | No TS factory inject | Plugin + hooks; `register_tool_pack` when native |
| L4 | Progressive skill/MCP catalog (dynamic mode, not dump) | Skills listing + discovery reminders exist | May still firehose vs pi-ness `skill_search` / `skill_load` | Config/ignore + reminder tuning; patch skill prompt builder if needed |
| L5 | Continuation coordinator (interrupt→streak→goal→plan→workflow→todo) | Goal classifier + plan mode + todos exist **separately** | No unified priority coordinator | SessionActor / hooks first; coordinator crate if multi-lane races |
| L6 | Guided blocks `[GATE:…]` + “Do this instead” | Permissions + PreToolUse hooks | Denials less “teach the model” | Hooks + tool error shapes; small tools-api patch only if gate format needs it |
| L7 | CodeGraph lean tools | `xai-codebase-graph` crate exists; no first-party lean agent tool surface observed | Semantic nav not productized for agents | MCP or plugin first; optional native tool later |
| L8 | Side-ask dual stream / intake default role | `ask_user_question`, modes, agent profiles | No side dual-stream product; intake profile pending proof | Intake agent first (F-EXT-001); dual-stream UI deferred |
| L9 | Workspace disk state `.piness/` (L6 disk) | Session dir + plan.md + goals | Different layout/semantics | Map `.do/` or reuse `.grok/` session layout; document contract |
| L10 | Overlay-first without forking Pi | **This is a fork** of grok-build | Must own fork hygiene, rebases, branding | Fork policy + “do” identity; never modify sibling trees |
| L11 | Node/OpenTUI stack | Rust/ratatui pager | Different contrib model & UI extension cost | Accept Rust; plugins before deep TUI fork; **no OpenTUI port** in M0–M1 |
| L12 | Compat patches to upstream dist | Full source tree available | Easier to patch crates, harder to stay mergeable | Prefer config/plugin; minimize core diffs; document every patch |
| **L13** | **OpenCode-like multi-model assignment** | **Multi-model registry already exists** (`[model.*]`, default, spawn > role > persona > parent) | **Assignment UX / role→model policy** weaker; do YAML not wired | do-harness YAML + agent frontmatter; keep stock TOML as runtime SoT |

---

## L1 — Primary-session role control + post-message lock

### Idea (pi-ness / OpenCode)

- Session **job persona** is a first-class control unit: role bodies, tool floors, routing catalogs.
- Tab / `/role` can change main-session role (and rebuild `${role_body}` / active tools).
- **do product rule (binding):** Tab/Shift+Tab only **pre-message**; **disabled** after first user message so the system/role stack stays clean (OpenCode-like hygiene; see [prompt-system.md](./prompt-system.md) Role lifecycle).

### Stock grok-build

- Strong **subagent** agent/persona discovery and model resolution.
- Primary session is not an intake→orchestrator role machine equivalent to pi-ness main role.

### Gap

- No shipped primary-session Tab cycle with post-first-message lock.
- Role tool/skill deny floors for main session need product profiles + optional shell keybind work.

### Preferred path

1. Agent profiles under `do-harness/agents/` / discovery paths  
2. Config + role model pins (ties to L13)  
3. M1: session flag + keybind gate + stack freeze  
4. Crate patch only if seams cannot express lock

### Evidence

| Side | Path |
|------|------|
| pi-ness roles | `/home/datht/code/pi-ness/packages/piness-core/src/roles.ts` |
| pi-ness session role | `/home/datht/code/pi-ness/packages/piness-core/src/session-role.ts` (`getActiveMainRole` / `setActiveMainRole`) |
| pi-ness role bodies | `/home/datht/code/pi-ness/packages/piness-core/prompts/roles/` |
| pi-ness role routing | `/home/datht/code/pi-ness/packages/piness-core/src/role-routing.ts` |
| pi-ness docs | `/home/datht/code/pi-ness/docs/prompt-system.md` (§ Session role) |
| grok agent discovery | `crates/codegen/xai-grok-agent/src/discovery.rs` |
| grok subagent resolution | `crates/codegen/xai-grok-subagent-resolution/` |
| do product rule | Root `AGENTS.md` (Role switch lock); `docs/prompt-system.md`; mission architecture L1 |

---

## L2 — L0–L6 layered prompt assembly

### Idea (pi-ness)

Explicit prompt surface layers (not model tiers):

| Layer | Name | pi-ness home (summary) |
|-------|------|------------------------|
| L0 | Identity | `prompts/SYSTEM.md`, `SYSTEM_GENERAL.md` |
| L1 | Tool contracts | `registerTool` description / snippets |
| L2 | Project brief | `AGENTS.md` via context files |
| L3 | Progressive catalogs | skill-catalog dynamic mode |
| L4 | Role body | `prompts/roles/*` via `${role_body}` |
| L5 | Mode injects | `before_agent_start` fragments |
| L6 | Disk state | `.piness/` — re-read, do not paste full bodies |

Fragment registry + **maxBytes** budgets: `packages/piness-core/src/native/prompt-fragments/` (`KNOWN_PROMPT_FRAGMENTS`, budget-sentinel).

### Stock grok-build

System + agent prompts, skills, plugins, reminders — **no** named L0–L6 registry or hard per-fragment budgets.

### Gap

Operators cannot reason about “what layer am I editing?” or enforce fragment budgets without inventing a control plane.

### Preferred path

Map layers onto agent profiles + `do-harness/prompts/` + reminders; crate patch only for registry/budget if extension fails.

### Evidence

| Side | Path |
|------|------|
| pi-ness L0–L6 | `/home/datht/code/pi-ness/docs/prompt-system.md` |
| pi-ness fragments | `/home/datht/code/pi-ness/packages/piness-core/src/native/prompt-fragments/` |
| pi-ness prompts | `/home/datht/code/pi-ness/packages/piness-core/prompts/` |
| do stub | `docs/prompt-system.md` |
| grok skills/reminders | `crates/codegen/xai-grok-tools/src/implementations/skills/`; `SkillDiscoveryReminder` in registry builder |
| grok patterns | `docs/grok-build/patterns.md` § Skill discovery reminders |

---

## L3 — Always-on native harness factories

### Idea (pi-ness)

Always-on identity lives in **TS factories** registered once:

- `NATIVE_HARNESS_EXTENSION_FACTORIES` in `packages/piness-core/src/native/index.ts`
- Modules under `packages/piness-core/src/native/` (permission, goal, workspace, skill-catalog, …)
- Env kill switches for debug, not product opt-in

### Stock grok-build

Monolithic Rust `ToolRegistryBuilder::new()` + plugins/hooks/config. No pi-style TS factory inject.

### Gap

Cannot port factories 1:1; must re-express behavior on Rust seams.

### Preferred path

Hooks + plugins + agent/skills for behavior; `register_tool_pack` for in-process tools (`registry/types.rs` ordering contract).

### Evidence

| Side | Path |
|------|------|
| pi-ness factories | `/home/datht/code/pi-ness/packages/piness-core/src/native/index.ts` |
| pi-ness factory builders | `/home/datht/code/pi-ness/packages/piness-core/src/native/factory-builders.ts` |
| pi-ness hooks docs | `/home/datht/code/pi-ness/docs/hooks.md` |
| grok tool registry | `crates/codegen/xai-grok-tools/src/registry/types.rs` (`register_tool_pack`, `ToolRegistryBuilder::new`) |
| grok extension seams | `docs/grok-build/extension-seams.md` |
| grok hard limit | `docs/grok-build/hard-limits.md` (No TS harness factories) |

---

## L4 — Progressive skill / MCP catalog

### Idea (pi-ness)

Stop dumping full skill metadata into every system prompt:

- `skill_search` / `skill_load` retrieval tools  
- Compact skill-intents fragment (`maxBytes` 3000)  
- Dynamic mode: `PN_SKILLS_PROMPT_MODE=dynamic`  
- Kill: `PN_SKILL_CATALOG=0`  
- Source: `packages/piness-core/src/native/skill-catalog/`

### Stock grok-build

Skill tool + listing + **SkillDiscoveryReminder**; MCP via `search_tool` / `use_tool`. Catalog can still be firehose depending on install set.

### Gap

No BM25/RRF progressive catalog product equivalent; risk of always-on skill dump.

### Preferred path

Tune discovery/reminders + config ignore lists; optional crate patch to skill prompt builder; keep MCP progressive via search-then-use.

### Evidence

| Side | Path |
|------|------|
| pi-ness skill catalog doc | `/home/datht/code/pi-ness/docs/skill-catalog.md` |
| pi-ness skill-catalog src | `/home/datht/code/pi-ness/packages/piness-core/src/native/skill-catalog/` |
| grok skills impl | `crates/codegen/xai-grok-tools/src/implementations/skills/` |
| grok skill discovery | workspace `discover_skills`; agent `list_skills` |
| grok MCP | `crates/codegen/xai-grok-mcp/`; tools `search_tool` / `use_tool` |
| inventory | `docs/grok-build/native-tools.md`, `extension-seams.md` § Skills / MCP |

---

## L5 — Continuation coordinator

### Idea (pi-ness)

Unified priority across interrupt → streak → goal → plan → workflow → todo:

- `packages/piness-core/src/native/continuation-coordinator/`  
- Registers **first** among many factories with interrupt tracker  
- Kill: `PN_CONTINUATION_COORDINATOR=0`  
- Documented in `/home/datht/code/pi-ness/docs/workspace.md`

### Stock grok-build

Separate surfaces:

- `update_goal` + classifier  
- `enter_plan_mode` / `exit_plan_mode`  
- `todo` / `TodoWriteTool`  
- `task` / scheduler / monitor  

No single priority coordinator crate.

### Gap

Multi-lane races and settle-continue policy must be product-composed; easy to thrash without a coordinator.

### Preferred path

M2: hooks / SessionActor policy first; dedicated coordinator only if races remain.

### Evidence

| Side | Path |
|------|------|
| pi-ness coordinator | `/home/datht/code/pi-ness/packages/piness-core/src/native/continuation-coordinator/` |
| pi-ness interrupt tracker | `/home/datht/code/pi-ness/packages/piness-core/src/native/interrupt-tracker/` |
| pi-ness workspace doc | `/home/datht/code/pi-ness/docs/workspace.md` |
| grok tools | `crates/codegen/xai-grok-tools/src/implementations/grok_build/{update_goal,enter_plan_mode,exit_plan_mode,todo,task}/` |
| grok registration | `crates/codegen/xai-grok-tools/src/registry/types.rs` |
| grok patterns | `docs/grok-build/patterns.md` § Plan / update_goal / Gap L5 |
| do stub | `docs/workspace.md` |

---

## L6 — Guided blocks (`[GATE:…]` + Do this instead)

### Idea (pi-ness)

Denied/blocked/gated tools must **teach recovery**, not bare “Permission denied”:

```text
[GATE: <subsystem>] <what was blocked>

Do this instead:
1. …
```

- Helper: `packages/piness-core/src/native/guided-block.ts` → `formatGuidedBlock`  
- Named in system prompts so models know before first hit  
- Doc: `/home/datht/code/pi-ness/docs/hooks.md`

### Stock grok-build

Rich permissions (`xai-grok-workspace/src/permission/`) + PreToolUse hooks (`xai-grok-hooks`, `HookEvent::PreToolUse`). Denial text quality is not standardized as guided blocks product-wide.

### Gap

Models thrash after opaque denials; do hard constraint requires gate name + Do this instead (+ human / do-not thrash).

### Preferred path

Proof PreToolUse hook (F-EXT-002); normalize message shape in hooks; tools-api patch only if shared format needs it.

### Evidence

| Side | Path |
|------|------|
| pi-ness guided-block | `/home/datht/code/pi-ness/packages/piness-core/src/native/guided-block.ts` |
| pi-ness permission engine | `/home/datht/code/pi-ness/packages/piness-core/src/native/permission/` |
| pi-ness hooks doc | `/home/datht/code/pi-ness/docs/hooks.md` |
| grok hook events | `crates/codegen/xai-hooks-plugins-types/src/lib.rs` |
| grok hooks runtime | `crates/codegen/xai-grok-hooks/` (`discovery.rs`, `dispatcher.rs`, `runner/`) |
| grok permissions | `crates/codegen/xai-grok-workspace/src/permission/` |
| do policy | Root `AGENTS.md` Hard Constraints (Guided blocks) |
| seams | `docs/grok-build/extension-seams.md` § Hooks |

---

## L7 — CodeGraph lean tools

### Idea (pi-ness)

Lean semantic navigation package: `packages/piness-ext-codegraph/` (`explore`, `graph`, `format`, …) plus docs `/home/datht/code/pi-ness/docs/codegraph.md`.

### Stock grok-build

- **Exists:** `crates/codegen/xai-codebase-graph/` (`index_manager.rs`, `navigation.rs`, `scope_graph/`)  
- **Missing as product:** first-party lean agent tools / default MCP exposure for “go-to / blast radius” UX

### Gap

Semantic nav not default agent path; do not reinvent graph indexing from zero.

### Preferred path

MCP or plugin wrapping local/index APIs first; optional `tool_pack` later (M3 backlog).

### Evidence

| Side | Path |
|------|------|
| pi-ness ext | `/home/datht/code/pi-ness/packages/piness-ext-codegraph/` |
| pi-ness docs | `/home/datht/code/pi-ness/docs/codegraph.md` |
| grok graph crate | `crates/codegen/xai-codebase-graph/src/` |
| hard-limits note | `docs/grok-build/hard-limits.md` (What not to reinvent / L7) |
| MCP path | `docs/grok-build/extension-seams.md` § MCP |

---

## L8 — Side-ask dual stream / intake default role

### Idea (pi-ness)

- **Side-ask** (`/ask`): ephemeral dual stream, read-only tools, no main transcript pollution — `/home/datht/code/pi-ness/docs/side-ask.md`  
- **Intake** default role + intent pack; role bodies under `prompts/roles/intake.md`  
- Side sessions: `createSession({ skipRoleBootstrap: true })` + role-body stash/restore

### Stock grok-build

`ask_user_question`, modes, agent profiles — no side dual-stream product equivalent.

### Gap

No dual-stream side panel product; intake profile is M0 proof work (F-EXT-001), not full side-ask.

### Preferred path

Intake agent profile first; defer dual-stream UI (high TUI cost; related to L11).

### Evidence

| Side | Path |
|------|------|
| pi-ness side-ask | `/home/datht/code/pi-ness/docs/side-ask.md` |
| pi-ness TUI | `/home/datht/code/pi-ness/packages/piness-tui/` |
| pi-ness intake native | `/home/datht/code/pi-ness/packages/piness-core/src/native/intake/` |
| pi-ness roles | `/home/datht/code/pi-ness/packages/piness-core/prompts/roles/` |
| grok ask_user | `crates/codegen/xai-grok-tools/src/implementations/grok_build/ask_user_question/` |
| grok agent discovery | `crates/codegen/xai-grok-agent/src/discovery.rs` |
| do plan | F-EXT-001 intake agent; `docs/future-plan.md` parking lot |

---

## L9 — Workspace disk state (`.piness/` vs session layout)

### Idea (pi-ness)

Dedicated tree under project `.piness/`:

- `session/<id>/todos.json`, `active-plan.json`, `active-goal.json`, …  
- `plans/<slug>/`, `goals/goal_<id>/`  
- L6 prompt rule: model **re-reads** disk; do not paste full bodies into system  
- Doc: `/home/datht/code/pi-ness/docs/workspace.md`

### Stock grok-build

Session directories, plan files, goals via native tools — different layout/semantics than `.piness/`.

### Gap

Operators and agents need a documented contract: map product semantics onto `.grok` session layout vs introduce thin `.do/` overlay later.

### Preferred path

Document mapping first; reuse native plan/goal/todo tools; avoid dual-write.

### Evidence

| Side | Path |
|------|------|
| pi-ness workspace | `/home/datht/code/pi-ness/packages/piness-core/src/native/workspace/` |
| pi-ness goal | `/home/datht/code/pi-ness/packages/piness-core/src/native/goal/` |
| pi-ness workspace doc | `/home/datht/code/pi-ness/docs/workspace.md` |
| grok continuum tools | `implementations/grok_build/{todo,update_goal,enter_plan_mode,exit_plan_mode}/` |
| do stub | `docs/workspace.md` |
| patterns | `docs/grok-build/patterns.md` § Plan / update_goal |

---

## L10 — Overlay-first without forking Pi → fork hygiene for do

### Idea (pi-ness)

pi-ness historically prefers **overlay / extension** on Pi without deep-forking the base (see pi-ness migration/extension docs).

### Stock / do reality

**do is a fork of grok-build** (private/local). Upstream external PRs are **not** the path. Sibling trees are read-only; import by **COPY** only.

### Gap

Must own rebases, branding, license notices, and clear identity vs stock `grok`.

### Preferred path

`FORK.md` + extension-before-deep-fork order; preserve Apache-2.0 + `THIRD-PARTY-NOTICES`.

### Evidence

| Side | Path |
|------|------|
| pi-ness extension docs | `/home/datht/code/pi-ness/docs/extension-compatibility.md`, `migration-from-overlay.md`, `patch-system.md` |
| do hard constraints | Root `AGENTS.md` |
| mission boundaries | Mission `AGENTS.md` |
| related projects | `docs/related-projects.md` |
| hard-limits | `docs/grok-build/hard-limits.md` (No external upstream PRs; never modify sibling trees) |
| FORK policy | `FORK.md` (F-DOC-004; may still be expanding) |

---

## L11 — Node/OpenTUI vs Rust/ratatui

### Idea (pi-ness)

OpenTUI / Node stack for TUI product (`packages/piness-tui/`, docs `opentui-architecture.md`).

### Stock grok-build

Rust pager / ratatui lineage (`xai-grok-pager*`, binary `xai-grok-pager-bin`).

### Gap

Different contrib model and high cost for UI deep forks. **No OpenTUI port** in M0–M1.

### Preferred path

Accept Rust UI; extend via plugins/hooks/agents; deep pager fork last (M2+ only with explicit decision).

### Evidence

| Side | Path |
|------|------|
| pi-ness TUI package | `/home/datht/code/pi-ness/packages/piness-tui/` |
| pi-ness OpenTUI docs | `/home/datht/code/pi-ness/docs/opentui-architecture.md` |
| grok pager-bin | workspace package `xai-grok-pager-bin` (see `docs/grok-build/overview.md`) |
| hard-limits | `docs/grok-build/hard-limits.md` (Deep pager / TUI fork) |
| do non-goals | Root `AGENTS.md` Non-Goals |

---

## L12 — Patch mergeability / core diffs

### Idea (pi-ness)

Compat patches / overlay discipline against upstream dist (`docs/patch-system.md`, extension porting notes).

### Stock / do reality

Full source tree under `do/crates/` makes crate patches easy and **merge hygiene hard**.

### Gap

Untracked core diffs accumulate; future import refreshes from sibling grok-build become painful.

### Preferred path

Prefer config/plugin/agent/hook; every crate patch documented in [patch-matrix.md](./patch-matrix.md) with risk + order; surgical diffs only.

### Evidence

| Side | Path |
|------|------|
| pi-ness patch system | `/home/datht/code/pi-ness/docs/patch-system.md` |
| do patch matrix | `docs/patch-matrix.md` |
| do ship discipline | `docs/milestone-ship-discipline.md` |
| generated workspace root | root `Cargo.toml` header (auto-generated; prefer per-crate edits) — `docs/grok-build/hard-limits.md` |
| dual Tool/NewTool migration | `docs/grok-build/hard-limits.md` |

---

## L13 — Multi-model assignment UX (not missing multi-model)

### Statement

Grok **already** multi-models. The gap is **controllable assignment** at product quality comparable to OpenCode (one table: role → model [+ effort]), not a second inference runtime.

| Claim | Truth |
|-------|--------|
| Multi-model registry | **Exists** — many `[model.<name>]` + `[models] default` + `api_backend` |
| Subagent resolution | **Exists** — spawn override > role > persona > parent |
| OpenCode-like assignment table | **Gap** — no single product file that pins role → model (+ effort) |
| do YAML overlay | **M0 template** `do-harness/config.models.yaml`; **not** auto-applied yet (M1 wire) |

### Idea (OpenCode / product need)

- Provider catalog + agent `model:` pins  
- Orchestrator / explorer / worker / oracle each pin model (+ effort)  
- Central assignment table in config (e.g. oh-my-opencode-slim patterns; user `~/.config/opencode/`)

### Stock grok-build

- Registry in `~/.grok/config.toml`  
- Role/persona `model` + `reasoning_effort`  
- Hot-reload of `[model.*]`  
- Agent frontmatter model pins

### Gap

Operators hand-edit TOML + scattered agent files without a single **assignment** policy surface. do YAML is template-only until M1.

### Preferred path

1. Keep stock TOML as **runtime** registry  
2. `do-harness/config.models.yaml` as **policy** (`models.registry` + `assignment`)  
3. M1: map into agent frontmatter / role model fields  
4. **Avoid** crate_patch and competing runtime registries

### Evidence (fork)

| Fact | Path under `/home/datht/code/do` |
|------|----------------------------------|
| Custom models guide | `crates/codegen/xai-grok-pager/docs/user-guide/11-custom-models.md` |
| Subagent model pins / roles | `crates/codegen/xai-grok-pager/docs/user-guide/16-subagents.md` |
| Resolution crate | `crates/codegen/xai-grok-subagent-resolution/src/lib.rs` |
| Precedence `EffectiveRuntimeConfig` | `crates/codegen/xai-grok-subagent-resolution/src/types.rs` |
| Role/persona model + reasoning_effort | `crates/codegen/xai-grok-subagent-resolution/src/config.rs` |
| Overrides cascade | `crates/codegen/xai-grok-subagent-resolution/src/overrides.rs` |
| `[model.*]` hot-reload | `crates/codegen/xai-grok-shell/src/config/reloader.rs` |
| `api_backend` | `crates/codegen/xai-grok-sampler/src/config.rs` |
| Product design | `docs/models-and-config.md` |
| YAML template | `do-harness/config.models.yaml` |

### OpenCode contrast (read-only notes)

- Agent frontmatter / `opencode.jsonc` agent `model:` pins  
- Central agent→model tables in plugin configs  
- Reference: user `~/.config/opencode/`; pi-ness OpenCode harnessing notes under `/home/datht/code/pi-ness/docs/opencode-harnessing.md` when present

### Non-goals

- YAML-only runtime that bypasses `~/.grok/config.toml`  
- Competing multi-model registry in Rust for M0  
- Claiming stock grok is single-model-only

### Product response

| Artifact | Role |
|----------|------|
| [models-and-config.md](./models-and-config.md) | Full design, schema, mapping, ≥2 models / ≥3 role example |
| `do-harness/config.models.yaml` | M0 template: `models.registry` + `assignment` |
| M1 | Wire assignment into agents/roles; optional TOML emit/diff |
| Role lock (L1) | Role→model re-assign only while pre-message switch allowed |

---

## Cross-cutting notes

1. **Extension order (binding):** config / agents / hooks / plugins / skills / YAML → `register_tool_pack` → surgical crate patch → deep TUI last.  
2. **Do not reinvent** native plan/goal/todo/task/hashline/MCP/multi-`[model.*]` — compose product policy on top.  
3. **Evidence thin areas (honest):** primary-session Tab keybinds in forked shell were not found as a complete role-cycle machine (L1 implementation is M1); side-ask has no grok twin (L8); exact default skill-prompt dump size vs pi-ness dynamic mode is qualitative (L4).  
4. **Related M0 features:** F-DOC-002 patch-matrix **sealed**; F-DOC-003 capability-map; F-EXT-001..003 proof agent/hook; F-BACK-001 M1–M3 backlog.

---

## Related

- [architecture.md](./architecture.md) — compact L1–L13 + system layout  
- [models-and-config.md](./models-and-config.md) — L13 design home  
- [patch-matrix.md](./patch-matrix.md) — gap → path / risk / order  
- [prompt-system.md](./prompt-system.md) — L2 stub + Role lifecycle  
- [workspace.md](./workspace.md) — L5 / L9 stub  
- [grok-build/](./grok-build/) — base inventory (read before crate work)  
- Root [AGENTS.md](../AGENTS.md) — hard constraints + living status  
