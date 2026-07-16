# Capability map: pi-ness → grok-build / do

**Status:** M0 **sealed** for F-DOC-003 / VAL-DOC-003.  
**Purpose:** Map pi-ness harness modules, L0–L6 prompt layers, roles, continuum concepts, and **model assignment** surfaces onto forked grok-build tools / APIs / plugins / hooks / config — or **`"gap"`**.

**How to use:** Prefer existing grok surfaces; do not reinvent. For gaps, follow [patch-matrix.md](./patch-matrix.md) path/order and [limitations.md](./limitations.md). Base inventory: [grok-build/](./grok-build/).

| Trees | Path | Access |
|-------|------|--------|
| Ideas (pi-ness) | `/home/datht/code/pi-ness` | **Read-only** |
| Fork (evidence + product) | `/home/datht/code/do` | Writable |
| Product overlay | `do-harness/` | Agents, hooks, skills, prompts, `config.models.yaml` |

**Legend (Grok surface column):**

| Token | Meaning |
|-------|---------|
| Tool FQ / kind | Registered in `ToolRegistryBuilder::new()` — see [native-tools.md](./grok-build/native-tools.md) |
| Config | `~/.grok/config.toml` or project `.grok/config.toml` |
| Agent / persona | Discovery under `.grok/agents/`, roles, personas |
| Hook | PreToolUse / session hooks via `xai-grok-hooks` |
| Plugin / skill | Plugin marketplace or skill discovery |
| MCP | `search_tool` / `use_tool` + `xai-grok-mcp` |
| do-harness | Repo product identity (not auto-wired until noted) |
| **`"gap"`** | No equivalent product surface yet — see L* |

---

## 1. Master summary (by limitation)

| L* | pi-ness idea | Primary grok surface | Map status |
|----|--------------|----------------------|------------|
| L1 | Primary-session roles + Tab cycle + post-message lock | Agents/personas (subagent-strong); keybind/session flag | **Partial** — profiles exist; primary Tab+lock = **`"gap"`** (M1) |
| L2 | L0–L6 layered prompts + fragment budgets | System + agent prompts, skills, reminders | **Partial** — no named L0–L6 registry |
| L3 | Always-on TS harness factories | Rust tool registry + plugins/hooks + `register_tool_pack` | **Re-express** — no TS factories ([hard-limits](./grok-build/hard-limits.md)) |
| L4 | Progressive skill/MCP catalog | Skill tool + `SkillDiscoveryReminder`; MCP search/use | **Partial** — no `skill_search`/`skill_load` product mode |
| L5 | Continuation coordinator | `update_goal`, plan mode, `todo_write`, task/scheduler | **Compose** — pieces exist; unified coordinator = **`"gap"`** (M2) |
| L6 | Guided blocks `[GATE:…]` | Permissions + PreToolUse hooks | **Partial** — hooks exist; guided shape product-wide = **`"gap"`** (M0 proof / M2) |
| L7 | CodeGraph lean tools | `xai-codebase-graph` crate; MCP path | **Partial** — graph code exists; lean agent tools = **`"gap"`** (M3) |
| L8 | Side-ask / intake default | `ask_user_question`, agent profiles | **Partial** — intake profile pending; dual-stream UI = **`"gap"`** |
| L9 | `.piness/` workspace disk | Session dir + plan/goal tools | **Map** — different layout; document contract |
| L10 | Overlay-first / fork hygiene | Full fork under `do/` | **Process** — FORK policy (F-DOC-004) |
| L11 | Node/OpenTUI | Rust/ratatui pager | **Accept** — no OpenTUI port M0–M1 |
| L12 | Patch mergeability | Surgical crate patches | **Process** — patch-matrix crate log |
| **L13** | OpenCode-like model assignment | Multi-`[model.*]` + subagent resolution | **Registry exists**; assignment UX / YAML wire = **partial → M1** |

---

## 2. pi-ness native modules → grok

Source group table: `/home/datht/code/pi-ness/packages/piness-core/src/native/README.md` and factory list in `native/index.ts` / `factory-builders.ts`.

### 2.1 Tools surface

| pi-ness module | Path (pi-ness) | Idea | Grok / do surface | Status |
|----------------|----------------|------|-------------------|--------|
| **skill-catalog** | `native/skill-catalog/` (`skill_search`, `skill_load`) | Progressive retrieval; dynamic prompt mode | Skill tool + listing (`implementations/skills/`); `SkillDiscoveryReminder`; workspace `discover_skills` | **Partial** — no BM25 search/load pair; L4 |
| **mcp-client** | `native/mcp-client/` | Cap enabled tools; discover then call | `SearchTool` / `UseTool`; `xai-grok-mcp/`; bridge `xai-grok-tools/src/bridge.rs` | **Mapped** — use progressive MCP ([patterns](./grok-build/patterns.md) § MCP) |
| **tool-alias** | `native/tool-alias/` | Alias names → canonical tools | OpenCode/Codex namespaces + `ToolServerConfig` name overrides | **Partial** — multi-namespace IDs; no pi alias layer |
| **unified-read** | `native/unified-read/` | Single read surface (file/dir limits) | `ReadFileTool`, `ListDirTool`, concise variants | **Mapped** — use GrokBuild read/list |
| **hashline** | `native/hashline/` | Hash-anchored edit grammar | `GrokBuildHashline:*` (`hashline_read/edit/grep`); `FileToolset::Hashline` | **Mapped** — default still Standard; product default = M3 policy |
| **ask-user** | `native/ask-user/` | Structured user questions | `AskUserQuestionTool` (`ToolKind::AskUser`) | **Mapped** |
| **lsp** | `native/lsp/` | Language server client | `LspTool` (`ToolKind::Lsp`) | **Mapped** |
| **codegraph** (ext) | `packages/piness-ext-codegraph/` | Lean explore/impact tools | Crate `xai-codebase-graph/`; agent lean tools **`"gap"`** → MCP/`tool_pack` M3 | **Partial** (L7) |

### 2.2 Safety

| pi-ness module | Path (pi-ness) | Idea | Grok / do surface | Status |
|----------------|----------------|------|-------------------|--------|
| **permission** | `native/permission/` | Rule engine + guided deny | `xai-grok-workspace/src/permission/` (policy, auto_mode, rules, shell_access) | **Mapped** — compose with hooks |
| **guided-block** | `native/guided-block.ts` | `[GATE:…]` + Do this instead | PreToolUse hooks; product message shape **`"gap"`** until F-EXT-002 + M2 | **Partial** (L6) |
| **hooks/** (deny-shell-edit, path-policy, doom-loop, env-mask, read-policy, shell-strategy, deny-model-new) | `native/hooks/*` | Always-on safety filters | `xai-grok-hooks/` + `HookEvent::*`; do-harness hooks | **Mapped** as pattern — re-express per hook, not port TS |
| **role-tools / subagent-guard** | `native/role-tools/` | Role tool floors | Agent profiles + `ToolServerConfig` / capability filters by `ToolKind` | **Partial** — subagent-strong; primary-session floors = L1 product |

### 2.3 Continuum

| pi-ness module | Path (pi-ness) | Idea | Grok / do surface | Status |
|----------------|----------------|------|-------------------|--------|
| **workspace** | `native/workspace/` | Disk continuum under `.piness/` | Session dirs + plan files; native plan/goal/todo tools | **Map layout** (L9) — semantics differ |
| **goal** | `native/goal/` | Goals, milestones, progress | `UpdateGoalTool` + classifier; config goal model pools | **Mapped** — use `update_goal` |
| **continuum** | `native/continuum/` | Shared goal/todo status helpers | Compose goal + `TodoWriteTool` | **Compose** |
| **continuation-coordinator** | `native/continuation-coordinator/` | Priority: interrupt→streak→goal→plan→workflow→todo | Separate tools only | **`"gap"`** unified coordinator (L5 / M2) |
| **interrupt-tracker** | `native/interrupt-tracker/` | Interrupt streaks for continuation | Session/runtime signals; no dedicated product module | **`"gap"`** (feeds L5) |
| **workflow** | `native/workflow/` | Workflow mode / phase tools | Plan mode enter/exit + product policy | **Partial** |
| **method** | `native/method/` | Method / BMAD-style routing | Skills + agents | **Partial** — skill/agent, not first-class method engine |

### 2.4 Session glue

| pi-ness module | Path (pi-ness) | Idea | Grok / do surface | Status |
|----------------|----------------|------|-------------------|--------|
| **intake** | `native/intake/` | Default role, intent packs, context pack | Agent profile (F-EXT-001); `ask_user_question` | **Partial** — dual-stream side-ask **`"gap"`** (L8) |
| **prompt-fragments** | `native/prompt-fragments/` | Named fragments + maxBytes + budget sentinel | Agent prompts, skills, reminders — no fragment registry | **Partial** (L2) |
| **context-threshold** | `native/context-threshold/` | Context pressure / compact triggers | PreCompact/PostCompact hooks; compact pipeline | **Partial** |
| **alias-as-pi** | `native/alias-as-pi/` | Identity alias / herdr pane | Product branding only; not a grok module | **N/A / defer** — do brand in docs |
| **blocker** / **validation** | `native/blocker/`, `native/validation/` | Goal assertion / validation helpers | Product policy on goal continuum; no 1:1 tools | **Partial** — future goal-as-mission |
| **system-skills** | `native/system-skills/` | Built-in skill contracts | Bundled skills under `xai-grok-shell/skills/` | **Mapped** pattern |

### 2.5 Subagent

| pi-ness module | Path (pi-ness) | Idea | Grok / do surface | Status |
|----------------|----------------|------|-------------------|--------|
| **subagent-barrier** | `native/subagent-barrier/` | Group latch / wait | `WaitTasksTool`, `TaskOutputTool`, task kill tools | **Mapped** (different API) |
| **subagent-isolation** | `native/subagent-isolation/` | Isolation template + concurrent slots | `TaskTool` + subagent resolution; persona fail-closed | **Mapped** — see [patterns](./grok-build/patterns.md) § Subagent |

### 2.6 Outside always-on factory list (pi-ness)

| Concept | pi-ness home | Grok / do surface | Status |
|---------|--------------|-------------------|--------|
| **Roles (main session)** | `packages/piness-core/src/roles.ts`, `session-role.ts`, `prompts/roles/` | Agent discovery; subagent roles/personas; primary Tab cycle | **Partial** — L1; lock policy documented M0, implement M1 |
| **Role routing** | `role-routing.ts` | Subagent type/role model pools; do `assignment:` | **Partial** — L13 wire M1 |
| **Side-ask** | `docs/side-ask.md`, TUI | No dual-stream product | **`"gap"`** (L8) |
| **CodeGraph package** | `piness-ext-codegraph` | `xai-codebase-graph` + MCP/tool_pack | **Partial** (L7) |
| **TUI / OpenTUI** | `piness-tui` | `xai-grok-pager` / ratatui | **Accept Rust** (L11); no port |

---

## 3. L0–L6 prompt layers → grok inject points

pi-ness L0–L6 (from `/home/datht/code/pi-ness/docs/prompt-system.md` and do [prompt-system.md](./prompt-system.md) stub). Layer numbers in pi-ness docs and do stub differ slightly; map by **purpose**, not number alone.

| Layer purpose | pi-ness (typical) | Grok inject / surface | do product home | Status |
|---------------|-------------------|----------------------|-----------------|--------|
| Identity / kernel safety | L0 `SYSTEM.md` / factories | System prompt + permission + hooks | `do-harness/prompts/`, hard AGENTS constraints | **Partial** — no L0 registry |
| Tool contracts | L1 tool `registerTool` snippets | Tool descriptions in registry; `ToolKind` filters | Prefer stock tool docs; avoid rewrite | **Mapped** |
| Project brief | L2 `AGENTS.md` context | Project files / workspace context discovery | Root `AGENTS.md` + `docs/` | **Mapped** |
| Progressive catalogs | L3 skill-catalog dynamic | Skills listing + reminders; MCP search | Config ignore + L4 work | **Partial** |
| Role body | L4 `${role_body}` / roles/* | Agent profile body / role `prompt_file` | `do-harness/agents/`, roles | **Partial** — primary role machine L1 |
| Mode injects | L5 `before_agent_start` fragments | Plugins, hooks, plan-mode tool hints | Hooks + plan tools | **Partial** |
| Disk state (re-read) | L6 `.piness/` | Session plan/goal files on disk | Map `.grok` session layout (L9) | **Map** — do not paste full bodies |
| Fragment maxBytes | `prompt-fragments/` + budget sentinel | No first-class budget registry | Optional crate later | **`"gap"`** (L2) |

**Role lifecycle (product, not a pi module):** Tab/Shift+Tab only **pre-message**; lock after first user message — [prompt-system.md](./prompt-system.md) Role lifecycle; implement M1 (L1 + L13).

---

## 4. Roles and control units

| Concept | pi-ness | Grok | do | Status |
|---------|---------|------|-----|--------|
| Role as primary session control | `getActiveMainRole` / `setActiveMainRole` | Subagent roles strong; primary weaker | Product Tab cycle + lock (M1) | **`"gap"`** primary machine |
| Role bodies | `prompts/roles/*` | Agent markdown / role TOML `prompt_file` | `do-harness/agents/`, prompts | **Mapped** path |
| Tool/skill deny floors | Role routing + permission | Permissions + agent toolsets + hooks | do-harness + permission rules | **Partial** |
| Subagent spawn | Role-aware spawn | `TaskTool` + `xai-grok-subagent-resolution` | Use stock; pin models via L13 | **Mapped** |
| Personas | pi session personas | `.grok/personas/`, `[subagents.personas.*]` | Optional product personas | **Mapped** |
| Intake default | intake role + intent packs | Agent profile proof (F-EXT-001) | do-harness intake | **Pending proof** |
| Orchestrator / explorer / worker / oracle | Role roster + OpenCode pins | Agent defs + subagent types | `assignment:` in YAML | **Design sealed**; wire M1 |

---

## 5. Continuum concepts

| Concept | pi-ness | Grok tool / API | Notes | Status |
|---------|---------|-----------------|-------|--------|
| **Goal** | `native/goal/`, `.piness/goals/` | `GrokBuild:update_goal` (`UpdateGoalTool`) | Classifier + progress | **Mapped** |
| **Plan** | plans under workspace / continuum | `EnterPlanModeTool` / `ExitPlanModeTool`; plan files | Paired mode — do not reinvent | **Mapped** |
| **Todo** | todos.json / continuum helpers | `TodoWriteTool` (`ToolKind::Plan`); OpenCode `todowrite` | | **Mapped** |
| **Workflow** | `native/workflow/` | Plan mode + skills + product policy | No single workflow engine | **Partial** |
| **Continuation priority** | continuation-coordinator | Compose goal/plan/todo/task | Unified coordinator | **`"gap"`** (L5) |
| **Interrupt / streak** | interrupt-tracker | Runtime interrupt; no product module | Feeds L5 | **`"gap"`** |
| **Scheduler / monitor** | (less central in pi-ness native list) | Scheduler\* tools, `MonitorTool` | Adopt grok patterns | **Mapped** (gained from grok) |
| **Task / subagent** | barrier + isolation | `TaskTool`, wait/kill/output | | **Mapped** |

Disk layout contract: [workspace.md](./workspace.md) (stub) + L9.

---

## 6. Model registry and assignment (L13)

**Correct facts:** multi-model registry **already exists** in stock grok. Gap is **assignment UX** and do YAML → agent/role wire. Full design: [models-and-config.md](./models-and-config.md).

| Concept | OpenCode / pi-ness idea | Grok surface | do surface | Status |
|---------|-------------------------|--------------|------------|--------|
| Model registry (N models) | Provider catalog | Many `[model.<name>]` + `[models] default` in `config.toml` | `models.registry` in `do-harness/config.models.yaml` → maps to TOML | **Registry: exists**; YAML: **template M0** |
| Default model | Default provider model | `[models] default` | `models.default` | **Mapped** |
| api_backend / base_url | Provider config | Per-model fields (user-guide §11) | YAML registry fields | **Mapped** |
| Subagent model resolution | Agent model pins | **spawn > role > persona > parent** (`xai-grok-subagent-resolution`) | Must respect this chain | **Mapped** |
| Role → model pin | `agent.model` / OpenCode table | `[subagents.roles.*.model]`, agent frontmatter `model` | `assignment.<role>` in YAML | **Partial** — not auto-applied (M1) |
| Reasoning effort | effort on agent | `reasoning_effort` on role/persona | `assignment.<role>.effort` (schema) | **Partial** |
| Primary-session model from role | Tab role + model | Weak primary role machine | Apply assignment only while role switch allowed | **`"gap"`** wire + lock (M1) |
| Competing second registry | — | — | **Forbidden** — YAML overlays; TOML remains runtime SoT | **Policy** |

### 6.1 Assignment flow (target)

```
do-harness/config.models.yaml
  models.registry.*  ──map──►  ~/.grok/config.toml  [model.*]
  models.default     ──map──►  [models] default
  assignment.*       ──map──►  agent frontmatter / [subagents.roles.*] model
                                      │
                                      ▼
                    xai-grok-subagent-resolution
                    (spawn > role > persona > parent)
```

M0: document + template. M1: wire assignment into agents; apply on primary role switch only pre-message.

---

## 7. Extension seams quick map

| Want (pi-ness-style) | Prefer grok/do seam | Evidence |
|----------------------|---------------------|----------|
| Product identity / roles / assignment | do-harness agents + YAML | [extension-seams.md](./grok-build/extension-seams.md) §1–2, §10 |
| Deny + teach model | PreToolUse hook | §3 Hooks; L6 |
| Optional power pack | Plugin | §4 Plugins |
| Progressive skills | Skill discovery + reminders | §5 Skills; L4 |
| Multi-model runtime | `config.toml` | §6 Config; L13 |
| New in-process tool | `register_tool_pack` | §7; L3 |
| External semantic nav | MCP first | §9 MCP; L7 |
| IDE protocol | ACP | §11 ACP |

---

## 8. Native tools “use, don’t reinvent”

| Continuum / power need | Use this (GrokBuild unless noted) | Do not invent |
|------------------------|-----------------------------------|---------------|
| Shell | `run_terminal_cmd` / BashTool | Second bash stack |
| Read / edit / search | `read_file`, `search_replace`, `grep`, `list_dir` | Parallel FS API |
| Hashline edits | `GrokBuildHashline:hashline_*` when toolset=hashline | Second patch grammar |
| Todos | `todo_write` | Second todo DB |
| Plan mode | `enter_plan_mode` / `exit_plan_mode` | Second plan mode |
| Goal | `update_goal` | Dual-write goals |
| Subagents | `task` + wait/kill/output | Second spawn bus |
| User questions | `ask_user_question` | Ad-hoc stdin prompts only |
| MCP | `search_tool` / `use_tool` | Raw MCP client in product code |
| LSP | `lsp` | Ad-hoc language servers |
| Skills | Skill tool + discovery | Always-on skill dump (L4) |

Full namespace/kind tables: [native-tools.md](./grok-build/native-tools.md).

---

## 9. Explicit `"gap"` register

| Gap | L* | Milestone | Preferred path |
|-----|----|-----------|----------------|
| Primary-session Tab/Shift+Tab role cycle + post-first-message lock | L1 | M1 | agent + config; optional crate for keybind |
| Named L0–L6 fragment registry + maxBytes | L2 | M1 | prompts + plugin; crate if needed |
| TS `NATIVE_HARNESS_EXTENSION_FACTORIES` | L3 | — | **Cannot port** — re-express via plugin/hook/tool_pack |
| `skill_search` / `skill_load` dynamic catalog | L4 | M1–M2 | config + skill; optional crate |
| Unified continuation coordinator | L5 | M2 | hook first; crate if races |
| Product-wide guided-block denial shape | L6 | M0 proof + M2 | hook (+ tools-api only if needed) |
| Lean CodeGraph agent tools | L7 | M3 | MCP / tool_pack (crate graph exists) |
| Side-ask dual stream UI | L8 | later | defer TUI; intake agent first |
| `.piness/` layout parity | L9 | M0–M1 | document map onto `.grok` / thin `.do/` |
| do YAML assignment auto-apply | L13 | M1 | config + agent frontmatter |
| OpenTUI / Node harness port | L11 | never M0–M1 | defer |

---

## 10. Related docs

| Doc | Role |
|-----|------|
| [limitations.md](./limitations.md) | L1–L13 evidence inventory |
| [patch-matrix.md](./patch-matrix.md) | Gap → path / risk / order |
| [models-and-config.md](./models-and-config.md) | Multi-model dual surface + L13 |
| [grok-build/native-tools.md](./grok-build/native-tools.md) | Tool namespaces and registration |
| [grok-build/extension-seams.md](./grok-build/extension-seams.md) | Where to extend |
| [grok-build/hard-limits.md](./grok-build/hard-limits.md) | Where not to force |
| [grok-build/patterns.md](./grok-build/patterns.md) | Patterns to adopt |
| [prompt-system.md](./prompt-system.md) | L0–L6 stub + role lifecycle |
| [workspace.md](./workspace.md) | Continuum stub |
| [architecture.md](./architecture.md) | System layout |
| Root [AGENTS.md](../AGENTS.md) | Operating contract |

---

## 11. Verification (VAL-DOC-003)

- [x] File exists: `docs/capability-map.md`
- [x] Maps pi-ness **native modules** (tools, safety, continuum, session, subagent) to grok tools/APIs/hooks/config or `"gap"`
- [x] Maps **L0–L6 / layer purposes** to inject points
- [x] Maps **roles** and **continuum** concepts
- [x] Maps **model registry + assignment** (L13) including dual TOML/YAML surface
- [x] Cites `docs/grok-build/*`, limitations, models-and-config
)
