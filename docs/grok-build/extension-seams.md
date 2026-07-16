# Extension seams (where we **can** extend)

Prefer these surfaces **before** crate patches. Order matches root `AGENTS.md` Customization Order.

Evidence paths are under `/home/datht/code/do` (forked tree) unless noted.

## 1. do-harness (product identity)

| What | Where (product) | Discovery target (runtime) |
|------|-----------------|----------------------------|
| Agents | `do-harness/agents/` | Must land on `.doit/agents` / `~/.config/doit/agents` discovery paths |
| Hooks | `do-harness/hooks/` | Hook config / `~/.config/doit/hooks/` / project `.doit/hooks/` |
| Skills | `do-harness/skills/` | Skills discovery used by Skill tool + reminders |
| Prompts | `do-harness/prompts/` | Agent/role prompt fragments |
| Model assignment YAML | `do-harness/config.models.yaml` | Maps to TOML + agent frontmatter (M1 wire) |

**do policy:** long-term identity lives in repo `do-harness/`; home-dir only as install/link target.

## 2. Agents / personas

| Seam | Evidence |
|------|----------|
| Agent file discovery | `crates/codegen/xai-grok-agent/src/discovery.rs` |
| Project dirs | `.doit/agents/`, `.claude/agents/` (walk cwd → repo root) |
| User dirs | `~/.config/doit/agents/` (GROK_HOME-aware), `~/.claude/agents/` |
| Bundled | `~/.config/doit/bundled/agents/` (lowest priority) |
| Merge priority | Project user agents can shadow built-ins; user-level and bundled **cannot** shadow built-in names (`merge_subagents` docs in discovery.rs) |
| Search order (discover) | 1) project `.grok`/`.claude` walk → 2) user grok agents → 3) `.claude` user → 4) bundled |
| Frontmatter model | Agent defs can pin model (stock multi-model path) |
| Subagent toggles | `[subagents.toggle]` filters enabled agents (`all_subagents`) |

**do use:** proof intake agent (F-EXT-001); role profiles for M1; role→model from YAML into agent frontmatter.

## 3. Hooks

| Seam | Evidence |
|------|----------|
| Hook events (plugin types) | `crates/codegen/xai-hooks-plugins-types/src/lib.rs` — `HookEvent` |
| Key events | `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `SessionStart`/`SessionEnd`, `Stop`/`StopFailure`, `UserPromptSubmit`, `PermissionDenied`, `SubagentStart`/`SubagentStop`, `PreCompact`/`PostCompact`, `Notification` |
| Runtime | `crates/codegen/xai-grok-hooks/` — `discovery.rs`, `dispatcher.rs`, `matcher.rs`, `runner/` (command + http) |
| Hook sources | `HookSource::SettingsFile` and `HookSource::Directory` of `*.json` (e.g. `~/.config/doit/hooks/`) |
| Workspace config | `xai-grok-workspace/src/config.rs` — global vs project hook sources |
| Wire names | `xai-grok-workspace-types/src/rpc/hooks.rs` — `HookEventNameWire` (includes `SubagentEnd`, `Unknown` sink) |
| Telemetry | `xai-grok-telemetry` PreToolUse deny semantics |

**do use:** guided PreToolUse hook with `[GATE: …]` + **Do this instead** (F-EXT-002); never bare “Permission denied”.

## 4. Plugins

| Seam | Evidence |
|------|----------|
| Plugin types | `xai-hooks-plugins-types` |
| Marketplace / install | `crates/codegen/xai-grok-plugin-marketplace/` |
| Agent plugin discovery | `xai-grok-agent` plugins module; workspace `discovery.rs` → `discover_plugins` |
| Shell plugin surface | `xai-grok-shell/src/plugin.rs`, `extensions/` |

**do use:** optional installable bundles; package do-harness pieces as plugin when appropriate.

## 5. Skills

| Seam | Evidence |
|------|----------|
| Skill tool + SkillInfo | `xai-grok-tools/src/implementations/skills/` |
| Listing implementation | `xai-grok-agent` prompt skills (`list_skills`); workspace `discovery.rs` → `discover_skills` |
| Bundled skills (examples) | `crates/codegen/xai-grok-shell/skills/` — `best-of-n`, `check-work`, `code-review`, `create-skill`, `help`, `imagine` |
| Discovery reminders | `SkillDiscoveryReminder` registered in `ToolRegistryBuilder::new()` |
| SessionContext.skills | Passed at toolset finalization |
| Paths | Project/user `~/.config/doit/skills/` patterns exercised in workspace discovery tests |

**do use:** progressive catalog via config/ignore + reminders first (L4); avoid dumping full skill text always-on.

## 6. Config (`config.toml`)

| Seam | Evidence |
|------|----------|
| Config load | `crates/codegen/xai-grok-config/`, `xai-grok-config-types/` |
| Project config | `<root>/.doit/config.toml` (`xai-grok-workspace/src/discovery.rs`) |
| Persist helpers | `xai-grok-shell` `managed_config` / util/config |
| Multi-model | Many `[model.<name>]`, `[models] default` — see [../models-and-config.md](../models-and-config.md) |
| Goal role models | `xai-grok-config-types` remote settings: planner/strategist/goal_skeptic model pools |
| Toolset sections | Shell `tools/config.rs`: `[toolset.bash]`, `[toolset.web_fetch]`, `[toolset.ask_user_question]`, `file_toolset`, `[toolset.hashline]` |
| Permissions | `xai-grok-workspace/src/permission/` (`policy`, `auto_mode`, `rules`, `shell_access`, `manager`, …) |

**do use:** document mapping from `config.models.yaml` → TOML; do not replace TOML registry.

## 7. `register_tool_pack` (native in-process tools)

| Seam | Evidence |
|------|----------|
| API | `crates/codegen/xai-grok-tools/src/registry/types.rs` |
| Type | `ToolPack = fn(&mut ToolRegistryBuilder)` |
| Function | `register_tool_pack(pack)` |
| Ordering | **MUST** run before first `ToolRegistryBuilder::new()` |
| Application | Packs applied at end of `ToolRegistryBuilder::new()` |
| Idempotency | Caller’s responsibility (double register = double tools) |

**do use:** new in-process tools when hooks/plugins cannot express behavior; implement `Tool` via `xai-tool-runtime` / grok tools metadata (`ToolNamespace`, `ToolKind`).

## 8. `ToolServerConfig` / toolset composition

| Seam | Evidence |
|------|----------|
| Config struct | `ToolServerConfig { tools, behavior_preset }` in `registry/types.rs` |
| Per-tool | `ToolConfig` id, overrides, kind, behavior_version |
| File toolset swap | `FileToolset` in shell `tools/config.rs` (Standard vs Hashline) |
| Workspace | Hub/session bind + toolset swap (`xai-grok-workspace`) |

**do use:** capability modes, name overrides, presets — configure before writing new tools.

## 9. MCP

| Seam | Evidence |
|------|----------|
| Client/server crate | `crates/codegen/xai-grok-mcp/` |
| Tools | `search_tool`, `use_tool` (registered in builder) |
| Bridge | `xai-grok-tools/src/bridge.rs` |
| Computer hub adapter | `crates/common/xai-computer-hub-mcp-adapter/` |
| Shell doctor | `xai-grok-shell/src/mcp_doctor.rs` |

**do use:** CodeGraph / external services as MCP first (L7), native tool only if MCP insufficient. Note: `xai-codebase-graph` already exists as a crate — gap is agent exposure, not absence of graph code.

## 10. Subagent resolution (roles / personas / models)

| Seam | Evidence |
|------|----------|
| Pure resolution crate | `crates/codegen/xai-grok-subagent-resolution/` |
| Precedence | explicit override > role > persona > parent (`lib.rs` docs + `overrides.rs`) |
| Types | `SubagentRole`, `SubagentPersona`, `EffectiveRuntimeConfig` |
| Persona fail-closed | Unreadable persona instructions file aborts spawn early |
| Role prompt soft-fail | Missing role `prompt_file` warns but continues |
| Spawn surface | `TaskTool` in `implementations/grok_build/task/` |

**do use:** wire role→model policy here / via agent defs; primary-session role cycle is a separate M1 product gap (L1).

## 11. ACP (Agent Client Protocol)

| Seam | Evidence |
|------|----------|
| Library | `crates/codegen/xai-acp-lib/` |
| Binary links | `xai-grok-pager-bin` depends on `xai-acp-lib` |

**do use:** external IDE/client integration without reinventing the wire protocol.

## Decision table (quick)

| Want… | Prefer |
|-------|--------|
| Product identity / safety / roles | do-harness agents + hooks + YAML |
| Optional install | plugin |
| Deny + teach model | PreToolUse hook + guided message |
| New tool logic in-process | `register_tool_pack` |
| External capability | MCP |
| Model per role | agent frontmatter + YAML→TOML map (L13) |
| Still impossible | See [hard-limits.md](./hard-limits.md) → patch-matrix |

## See also

- [hard-limits.md](./hard-limits.md)
- [patterns.md](./patterns.md)
- [../architecture.md](../architecture.md) extension strategy
