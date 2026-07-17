# Patch matrix (L1–L13)

**Status:** M0 **sealed** for F-DOC-002 / VAL-DOC-002 — every gap maps to preferred path, risk, and recommended order. Expanded from F-MODEL-001 L13 row + architecture stubs; evidence deepened via [limitations.md](./limitations.md) and [grok-build/](./grok-build/).

**How to use:** Pick work by **Order** (lower first). Prefer extension seams ([grok-build/extension-seams.md](./grok-build/extension-seams.md)) before [hard-limits.md](./grok-build/hard-limits.md). Every actual crate diff must add a dated entry under [Crate patch log](#crate-patch-log).

---

## Path vocabulary

| Path | Meaning |
|------|---------|
| `plugin` | Installable bundle (skills + hooks + agents + MCP) via grok plugin discovery |
| `hook` | Pre/Post tool / session hooks (`PreToolUse`, …) |
| `agent` | Agent/persona profiles under discovery paths (`do-harness/agents/`, `.do/agents/`) |
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
| 6 | L9 | `config` + docs | Low | M0–M1 / **CFG** | Map product workspace onto **`.do/`** + **`~/.config/do`** sessions |
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
| **Evidence / design** | [limitations.md § L4](./limitations.md#l4--progressive-skill--mcp-catalog); [progressive-skills.md](./progressive-skills.md); M2: all five roster `discoverSkills: false`; `verify-progressive-skills.sh` → VAL-M2-SKILL-001 |
| **M2 status** | **Extension seal** — progressive/curated product default; firehose opt-in; MCP search/use; no crate |

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
| **Gap** | ~~lean agent tool / default MCP product surface missing~~ **shipped** M3 F-M3-CG: MCP `doit-codegraph` wraps `code-graph` CLI |
| **Preferred path** | `plugin` / MCP wrapping local index first; optional `tool_pack` later |
| **Risk** | **Medium** — reinventing index vs productizing existing crate |
| **Order** | **11** |
| **Milestone** | **M3** |
| **Seams** | `crates/codegen/xai-codebase-graph/`; `do-harness/codegraph/mcp_server.py`; `[mcp_servers.doit-codegraph]`; stock `search_tool`/`use_tool` |
| **Avoid** | Greenfield graph from zero; ignoring existing crate ([hard-limits.md](./grok-build/hard-limits.md) What not to reinvent) |
| **Evidence / design** | [limitations.md § L7](./limitations.md#l7--codegraph-lean-tools); [codegraph.md](./codegraph.md); `bash do-harness/scripts/verify-codegraph.sh` → VAL-M3-CG-001 |
| **M3 status** | **Extension seal (no crate patch)** — MCP-first; `tool_pack` deferred; no P-* crate log row for this feature |

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
| **Seams** | `do-harness/config.models.yaml`; `~/.config/do/config.toml` `[model.*]`; project `.do/`; subagent resolution spawn > role > persona > parent; agent frontmatter model |
| **Avoid** | Competing runtime registry; early `crate_patch` for assignment; claiming stock grok is single-model |
| **Evidence / design** | [limitations.md § L13](./limitations.md#l13--multi-model-assignment-ux-not-missing-multi-model); [models-and-config.md](./models-and-config.md); template `do-harness/config.models.yaml` |
| **Validators** | VAL-MODEL-001, VAL-MODEL-002 |
| **Coupling** | Role→model re-assign only while L1 pre-message switch allowed |

---

## Decision rules

1. **Prefer extension** (`config` / `agent` / `hook` / `plugin` / `skill`) before `tool_pack` before `crate_patch` before deep TUI.  
2. **Ask placement** before always-on behavior or promoting config → crate (root `AGENTS.md` Native vs Extension vs Crate Patch).  
3. **Do not reinvent** native plan / goal / todo / task / hashline / MCP / multi-`[model.*]` — compose product policy on top ([hard-limits.md](./grok-build/hard-limits.md)).  
4. **Dual config for models:** do YAML policy + `~/.config/do/config.toml` runtime (project `.do/`) — do not fight the base.  
5. **Guided denials (L6):** incomplete until gate is named in prompts **and** result uses `[GATE: …]` + **Do this instead**.  
6. **Every crate patch** adds a dated row in the log below (crate path, reason, linked L*, risk).

---

## Crate patch log

| Date | Crate / path | L* | Reason | Risk | Alternatives exhausted |
|------|--------------|----|--------|------|------------------------|
| 2026-07-16 | `xai-grok-shell` `session/role_switch.rs` + `acp_session_impl/session_mode.rs` | L1 | Session flag `role_switch_allowed` + gate product-role `session/set_mode` after first turn so L1 prompt freeze is enforced server-side | Medium | Agents/hooks cannot observe turn_count or refuse ACP set_mode; pure policy module is shared, not a deep TUI fork |
| 2026-07-16 | `xai-grok-pager` `dispatch/modes.rs`, `agent_view/prompt.rs`, `actions` | L1 | Tab/Shift+Tab product-role cycle pre-message; no-op after lock (Shift+Tab reverts to plan/yolo CycleMode) | Medium | Keybind lives in pager input path; extension-only cannot intercept Tab before completion UI |
| 2026-07-16 | `xai-grok-shell` `session/role_switch.rs` + `acp_session_impl/session_mode.rs` | L13 + L1 | Role→model re-pin from agent frontmatter (YAML assignment) only while `role_switch_allowed`; post-lock Keep; subagent spawn path untouched | Medium | Apply script only writes frontmatter; primary session must re-pin on pre-message set_mode — hooks cannot change sampling config |

### Applied — P-NOTEL from grok-build-no-telemetry (PRIV F-PRIV-NOTEL)

Source: `~/code/grok-build-no-telemetry/patches/0001`–`0006` (manual port; no blind `git apply`). Scout: [`plans/reports/scout-grok-build-no-telemetry-260716.md`](../plans/reports/scout-grok-build-no-telemetry-260716.md). External OTEL via `GROK_EXTERNAL_OTEL` + `OTEL_*` preserved (`xai-grok-telemetry/src/external/` untouched).

| Date | ID | Status | Crate / path | Reason | Risk | Alternatives exhausted |
|------|----|--------|--------------|--------|------|------------------------|
| 2026-07-16 | **P-NOTEL-01** | **applied** | `xai-grok-telemetry` `client.rs`/`config.rs`; `xai-grok-shell` `agent/config.rs` (`is_telemetry_enabled`, `resolve_telemetry_mode`) | Fail-closed product analytics + null defaults; env/remote cannot re-enable SpaceXAI events/Mixpanel | Medium | Config-only opt-out is re-enableable via remote/env; product policy is hard-off |
| 2026-07-16 | **P-NOTEL-02** | **applied** | `xai-mixpanel` `lib.rs` | Defense-in-depth no-op `track`/`engage` (no network) | Low | Optional if 01 holds; retained for crate reuse safety |
| 2026-07-16 | **P-NOTEL-03** | **applied** | `xai-grok-telemetry` `sentry.rs`; shell `is_error_reporting_disabled_sync` | No Sentry DSN init / crash phone-home | Low | Env-gated Sentry still re-arms via DSN |
| 2026-07-16 | **P-NOTEL-04** | **applied** | `instrumentation.rs`, `otel_layer/mod.rs`, shell `is_telemetry_explicitly_disabled_sync`, `credential_provider` OTLP layer | Disable internal OTLP to SpaceXAI proxy; keep external OTEL | Medium | Runtime TOML alone cannot force fail-closed on baked/default Server mode |
| 2026-07-16 | **P-NOTEL-05** | **applied** | shell `is_trace_upload_enabled`/`resolve_trace_upload`; telemetry `trace_upload` defaults | Disable session/trace/GCS upload | Low–Medium | Env/config opt-in still re-enabled upload without crate pin |
| 2026-07-16 | **P-NOTEL-06** | **applied** | shell `is_feedback_enabled`/`resolve_feedback`; `extensions/feedback.rs` message | Disable `/feedback` posts to cli-chat-proxy | Low | Config feedback flag remains re-enableable without resolve hard-off |

### Applied — P-AUTH (PRIV F-PRIV-AUTH)

Config-first: `[models] default` + `[model.*]` `api_key`/`env_key` + optional `[auth] preferred_method = "api_key"` (documented in [models-and-config.md](./models-and-config.md) Auth section). ACP already puts `xai.api_key` first for BYOK; hard CLI gate still forced OAuth.

| Date | ID | Status | Crate / path | Reason | Risk | Alternatives exhausted |
|------|----|--------|--------------|--------|------|------------------------|
| 2026-07-16 | **P-AUTH-01** | **applied** | `xai-grok-shell` `agent/auth_method.rs` (`config_satisfies_api_key_auth`, `should_require_interactive_oauth` + unit tests); `xai-grok-pager-bin` `main.rs` `workspace_start` | Skip interactive `ensure_authenticated` / grok.com OAuth when BYOK or `preferred_method=api_key` | Medium | Config alone cannot change pager-bin hard gate; extension/hooks cannot intercept `workspace_start` pre-login |

### Applied — P-CFG-HOME (CFG F-CFG-HOME)

Scout: [`plans/reports/scout-config-home-xdg-do-260716.md`](../plans/reports/scout-config-home-xdg-do-260716.md). Default user home is **`~/.config/do` only** when `GROK_HOME` unset. **No** default dual-read of `~/.grok`. Env override remains **`GROK_HOME`** (full root replace; document this one — `DO_HOME` not wired). Project discovery `.do/` is F-CFG-PROJECT.

| Date | ID | Status | Crate / path | Reason | Risk | Alternatives exhausted |
|------|----|--------|--------------|--------|------|------------------------|
| 2026-07-16 | **P-CFG-HOME** | **applied** | `xai-grok-config` `paths.rs` (`default_grok_home` → `.config/do`, `DEFAULT_USER_HOME_REL`); `xai-fast-worktree` `db/mod.rs` `resolve_grok_home` (synced); `xai-grok-workspace` `worktree/mod.rs` fallback join; `xai-grok-agent` `discovery.rs` drop legacy `~/.grok` dual-read in `user_agent_dirs` | Product default user config/session/home root is XDG-style `~/.config/do`; no silent `~/.grok` fallback for default resolve or agent scan | Medium | Env-only `GROK_HOME=~/.config/do` leaves stock default `~/.grok`; extension/docs cannot change `default_grok_home` / `resolve_grok_home` hardcodes |
| 2026-07-16 | **P-CFG-HOME-DOIT** | **applied** | `xai-grok-config` `paths.rs` (`DEFAULT_USER_HOME_REL` → `.config/doit`, unit tests); `xai-fast-worktree` `db/mod.rs` `resolve_grok_home` (synced); `xai-grok-workspace` `worktree/mod.rs` fallback join; agent discovery fixtures/comments | Product default user home is XDG-style `~/.config/doit` (CFG-DOIT / VAL-CFG-001); `GROK_HOME` still full override; no silent dual-read of `~/.config/do` or `~/.grok` | Medium | Extension/docs cannot change hardcoded default resolvers; host migrate of live `~/.config/do` is F-CFG-MIGRATE |

### Applied — P-CFG-PROJECT (CFG F-CFG-PROJECT)

Product **project** discovery root is **`.doit/`** (CFG-DOIT rebrand from `.do/`; not `.grok/`). Vendor compat (`.claude/`, …) kept. User home remains `$GROK_HOME` / `~/.config/do` (P-CFG-HOME).

| Date | ID | Status | Crate / path | Reason | Risk | Alternatives exhausted |
|------|----|--------|--------------|--------|------|------------------------|
| 2026-07-16 | **P-CFG-PROJECT** | **applied** | `xai-grok-agent` `discovery.rs` `PROJECT_AGENT_SUBDIRS` + plugins `project_plugin_dirs_in`; `xai-grok-shell` `util/hooks.rs` project hooks + `config/` personas/roles + watcher/mcp/claude_import; `xai-grok-workspace` `project_config.rs`, `permission/resolution.rs`, `folder_trust.rs`, `discovery.rs`, checkpoint store; `xai-grok-tools` `PLAN_FILE_RELATIVE_PATH`, `compat` skill/rules dirs, `lsp/config.rs`, `skills/discovery.rs`, `agents_md_tracker` RULES_DIRS; `xai-grok-sandbox` profiles; `xai-grok-pager` agents/import/extensions modals; do-harness verify/install → `.do/` | Project agents/hooks/config/skills/plan/plugins discover under `.do/`; harness install + verify scripts exit 0 | Medium | Extension cannot change in-process discovery string roots; do-harness-only symlinks to `.grok/` would stay invisible after product rebrand |
| 2026-07-16 | **P-CFG-FIXTURES** | **applied** | Test-only + leftover `load_project_config`: shell `config/mod.rs` project config path; workspace `discovery` rules frontmatter strip for `.do/rules`; fixtures under shell/pager/workspace/tools/sandbox/agent (folder_trust, plan-mode, project skills/roles/personas/plugins/mcp/config/sandbox) rewrite `join(".grok")` → `join(".do")`. GROK_HOME/user-home mocks keep custom roots | Tests seed product discovery under `.do/`; plan exit and folder_trust unit tests pass; `cargo check -p xai-grok-pager-bin` | Low | Fixtures must match P-CFG-PROJECT roots or they go dark against product discovery |
| 2026-07-16 | **P-CFG-PROJECT-DOIT** | **applied** | `xai-grok-agent` `discovery.rs` `PROJECT_AGENT_SUBDIRS` + plugins `project_plugin_dirs_in`; `xai-grok-shell` `util/hooks.rs` project hooks + `config/` personas/roles + watcher/mcp/claude_import; `xai-grok-workspace` `project_config.rs`, `permission/resolution.rs`, `folder_trust.rs`, `discovery.rs`, checkpoint store; `xai-grok-tools` `PLAN_FILE_RELATIVE_PATH`, `compat` skill/rules dirs, `lsp/config.rs`, `skills/discovery.rs`, `agents_md_tracker` RULES_DIRS; `xai-grok-sandbox` profiles; `xai-grok-pager` agents/import/extensions modals; fixtures under shell/pager/workspace/tools/sandbox/agent; do-harness verify/install docs → `.doit/` | Project agents/hooks/config/skills/plan/plugins discover under `.doit/` (CFG-DOIT / VAL-CFG-002); harness verify scripts expect `.doit/` | Medium | Extension cannot change in-process discovery string roots; prior `.do/` product root left projects invisible after rebrand |

### Upstream sync — `8adf901` (2026-07-16, F-UPSTREAM-MERGE / VAL-UP-001..005)

| Field | Value |
|-------|--------|
| **Upstream tip** | `8adf901` (`upstream/main` — monorepo sync) |
| **Product branch** | `sync/upstream-8adf901` (merge commit; product history preserved — not full rebase of ~44 fork commits) |
| **Merge base** | `c68e39f` (open-source publish) |
| **Strategy** | `git merge upstream/main` → resolve conflicts per architecture playbook |

#### Conflict resolutions

| Path class | Resolution | Notes |
|------------|------------|-------|
| `crates/codegen/xai-grok-pager-bin/*` → product | **Map** | Upstream package changes applied under **`crates/codegen/doit`** / package **`doit`** / binary **`doit`**. Version line adopted (`0.2.101`). No resurrected `xai-grok-pager-bin` install package path. |
| Config home / discovery (P-CFG-HOME/PROJECT) | **Fork** | `DEFAULT_USER_HOME_REL` / `default_grok_home` stay `~/.config/do`; project `.do/` discovery kept. Upstream `grok_application_in` export merged onto product paths. |
| PRIV P-NOTEL / telemetry | **Fork** | Fail-closed SpaceXAI telemetry still hard-off (`is_telemetry_enabled` → false). No forced re-enable. |
| PRIV P-AUTH / BYOK | **Fork** | `should_require_interactive_oauth` + `doit` `workspace_start` gate still skip forced OAuth for BYOK / `preferred_method=api_key`. |
| Role switch lock (L1) | **Fork** | `role_switch_allowed` + Tab cycle gate + toast still present. |
| `settings_modal` monolith → modular | **Upstream** | Took modular `views/settings_modal/{mod,state,input,render,tests}.rs`; dropped product monolith file. |
| Timeline / screen_mode settings surface | **Upstream + re-wire** | Upstream `SetTimeline` / `SetScreenMode` + setters/router/ui/cache/`UiConfig::show_timeline` re-applied where product base had dropped incomplete timeline wiring. |
| `Cargo.lock` | **Product** | Keep `doit` package; drop upstream `xai-grok-pager-bin` lock entry. |
| `README.md` | **Fork + upstream build notes** | Product identity + `cargo check -p doit`; absorb DotSlash/protoc + `SOURCE_REV` notes. |
| Unrelated monorepo improvements | **Upstream** | Auto-merged shell/pager/workspace/env/memory/etc. when no product identity conflict. |
| Internal `xai-grok-*` library crates | **Keep names** | No mass rename (VAL-CROSS-002). |

#### Smoke / evidence

- `cargo check -p doit` — exit 0 after conflict resolution
- `git merge-base --is-ancestor 8adf901 HEAD` — true after merge commit
- Product package path: `crates/codegen/doit` only (no `xai-grok-pager-bin` directory)

#### Dual-changed hotspots touched (merge-time)

`Cargo.lock`, `README.md`, `crates/codegen/doit/{Cargo.toml,src/main.rs}`, `xai-grok-config/{lib.rs,paths.rs,loader,managed_cache}`, `xai-grok-pager` (actions, dispatch router/settings, app/mod, settings_modal modularization, event_loop, effects helpers), `xai-grok-pager-render` appearance cache/config, `xai-grok-shared` `ui_config`, `xai-grok-shell` settings_writes + agent config (auto-merge kept PRIV), `xai-grok-voice` config docs, plus pure-upstream monorepo delta (~117 files on upstream side).

#### Path mapping note (VAL-UP-005)

| Upstream | Product after merge |
|----------|---------------------|
| `crates/codegen/xai-grok-pager-bin` | `crates/codegen/doit` (package/binary `doit`) |
| binary `xai-grok-pager` | binary `doit` |
| default-run `xai-grok-pager` | default-run `doit` |

P-AUTH-01 path log still refers historically to `xai-grok-pager-bin` `main.rs`; live path is **`crates/codegen/doit/src/main.rs`**.

### Upstream sync — `98c3b24` (2026-07-17, F-UPSTREAM-MERGE / VAL-UP-001..005)

| Field | Value |
|-------|--------|
| **Upstream tip** | `98c3b24` (`upstream/main` — monorepo sync after `8adf901`) |
| **Product branch** | `sync/upstream-98c3b24` (merge commit; product history preserved — not full rebase) |
| **Merge base** | `8adf901` |
| **Strategy** | `git merge upstream/main` → resolve conflicts per FORK §2.1 + AGENTS upstream checklist |

#### Conflict resolutions

| Path class | Resolution | Notes |
|------------|------------|-------|
| `crates/codegen/xai-grok-pager-bin/*` → product | **Map** | Keep package/binary **`doit`** under `crates/codegen/doit`. Adopt lockstep version **`0.2.102`**. Drop lock entry for `xai-grok-pager-bin`. |
| Version lockstep (`doit`, `xai-grok-pager`, `xai-grok-shell`, `xai-grok-version`) | **Upstream version** | Product name kept; version line `0.2.102` (same as prior absorb of `0.2.101`). |
| PRIV P-NOTEL `sync_profile` | **Fork** | Keep fail-closed empty body; do not re-enable Mixpanel `engage` path from upstream. |
| CFG project hooks detect (`folder_trust.rs`) | **Fork + upstream helper** | Product path **`.doit/hooks`** with upstream `path_present_or_uncertain` (not `.grok/hooks`). |
| Permission manager / auto_mode | **Upstream** | No product identity pins; take full upstream monorepo delta (requester-gone cancel + classifier turn). |
| PTY harness (`lib.rs` / `pty.rs` / `content.rs`) + wrap e2e | **Upstream API** | Incomplete auto-merge left product without `wait_for_exit_and_drain` / `PtyRead`; took upstream harness API. Product binary resolve still via `env.rs` (`doit` package). |
| `Cargo.lock` | **Product** | Keep `doit` package; drop `xai-grok-pager-bin`; versions `0.2.102`. |
| Unrelated monorepo improvements | **Upstream** | Auto-merged when no product identity conflict. |
| Internal `xai-grok-*` library crates | **Keep names** | No mass rename (VAL-CROSS-002). |

#### Smoke / evidence

- `cargo check -p doit` — exit 0 after conflict resolution
- `git merge-base --is-ancestor 98c3b24 HEAD` — true after merge commit
- Product package path: `crates/codegen/doit` only (no `xai-grok-pager-bin` directory)
- Pins re-checked: P-NOTEL fail-closed; P-CFG `~/.config/doit` + `.doit/`; L1 `role_switch_allowed`; P-AUTH BYOK skip OAuth

#### Dual-changed hotspots touched (merge-time)

`Cargo.lock`, `crates/codegen/doit/Cargo.toml`, `xai-grok-pager` / `shell` / `version` Cargo.toml, `xai-grok-telemetry` `client.rs` (P-NOTEL), `xai-grok-workspace` `folder_trust.rs` (`.doit`), permission manager/auto_mode (upstream), `xai-grok-pager-pty-harness` (upstream API), pager wrap e2e `common.rs`, plus pure-upstream monorepo delta (~225 files on upstream side).

---

## Milestone → matrix slice

| Milestone | Matrix focus |
|-----------|----------------|
| **M0** | L10 docs; L13 template; L6/L8 proof (hook + intake agent); this matrix + limitations sealed |
| **M1** | L1 Tab lock + role roster; L13 YAML→agent wire; L2 prompt layers; start L4 |
| **PRIV** | P-NOTEL-01..06 fail-closed SpaceXAI telemetry; P-AUTH-01 BYOK skip forced OAuth (**applied**, 2026-07-16) |
| **CFG** | P-CFG-HOME user home `~/.config/do` (**applied**); P-CFG-PROJECT project `.do/` discovery (**applied**); P-CFG-FIXTURES test drift cleanup (**applied**) |
| **M2** | L5 continuation; L6 harden; L4 progressive catalog; L11 only if explicit |
| **M3** | L7 CodeGraph product surface; L3 tool packs as needed; file toolset standard default + hashline opt-in |
| **Upstream sync** | `8adf901` then **`98c3b24`** merge into product history (F-UPSTREAM-MERGE); preserve PRIV/CFG/role-lock; map pager-bin→`doit` |

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
