# Extension seams (where we **can** extend)

Prefer these surfaces **before** crate patches. Order matches root `AGENTS.md` Customization Order.

Evidence paths are under `/home/datht/code/do` (forked tree) unless noted.

## 1. do-harness (product identity)

| What | Where (product) | Discovery target (runtime) |
|------|-----------------|----------------------------|
| Agents | `do-harness/agents/` | Must land on `.grok/agents` / `~/.grok/agents` discovery paths |
| Hooks | `do-harness/hooks/` | Hook config / plugin install paths |
| Skills | `do-harness/skills/` | Skills discovery used by Skill tool + reminders |
| Prompts | `do-harness/prompts/` | Agent/role prompt fragments |
| Model assignment YAML | `do-harness/config.models.yaml` | Maps to TOML + agent frontmatter (M1 wire) |

**do policy:** long-term identity lives in repo `do-harness/`; home-dir only as install/link target.

## 2. Agents / personas

| Seam | Evidence |
|------|----------|
| Agent file discovery | `crates/codegen/xai-grok-agent/src/discovery.rs` |
| Project dirs | `.grok/agents/`, `.claude/agents/` (walk cwd → repo root) |
| User dirs | `~/.grok/agents/`, `~/.claude/agents/` |
| Bundled | `~/.grok/bundled/agents/` (lowest priority) |
| GROK_HOME | Discovery is GROK_HOME-aware; legacy `~/.grok` still considered |
| Frontmatter model | Agent defs can pin model (stock multi-model path) |

**do use:** proof intake agent (F-EXT-001); role profiles for M1; role→model from YAML into agent frontmatter.

## 3. Hooks

| Seam | Evidence |
|------|----------|
| Hook events | `crates/codegen/xai-hooks-plugins-types/src/lib.rs` — `HookEvent` |
| Key events | `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `SessionStart`/`End`, `Stop`, `UserPromptSubmit`, `PermissionDenied`, `SubagentStart`/`Stop`, `PreCompact`/`PostCompact`, … |
| Runtime | `crates/codegen/xai-grok-hooks/` (discovery, dispatcher, matcher, runner) |
| Telemetry gate outcomes | `xai-grok-telemetry` PreToolUse deny semantics |

**do use:** guided PreToolUse hook with `[GATE: …]` + **Do this instead** (F-EXT-002); never bare “Permission denied”.

## 4. Plugins

| Seam | Evidence |
|------|----------|
| Plugin types | `xai-hooks-plugins-types` |
| Marketplace / install | `crates/codegen/xai-grok-plugin-marketplace/` |
| Agent plugin discovery | `xai-grok-agent` plugins module + discovery |

**do use:** optional installable bundles; package do-harness pieces as plugin when appropriate.

## 5. Skills

| Seam | Evidence |
|------|----------|
| Skill tool + SkillInfo | `xai-grok-tools/src/implementations/skills/` |
| Bundled skills (examples) | `crates/codegen/xai-grok-shell/skills/` (e.g. best-of-n, code-review, create-skill, …) |
| Discovery reminders | `SkillDiscoveryReminder` wired in `registry/types.rs` |
| SessionContext.skills | Passed at toolset finalization |

**do use:** progressive catalog via config/ignore + reminders first (L4); avoid dumping full skill text always-on.

## 6. Config (`config.toml`)

| Seam | Evidence |
|------|----------|
| Config load | `crates/codegen/xai-grok-config/`, `xai-grok-config-types/` |
| Persist helpers | `xai-grok-shell` managed_config / util/config |
| Multi-model | Many `[model.<name>]`, `[models] default` — see [../models-and-config.md](../models-and-config.md) |
| Toolset sections | e.g. `[toolset.ask_user_question]` merge in shell persist |
| Permissions | `xai-grok-workspace/src/permission/` (policy, auto_mode, rules, shell_access) |

**do use:** document mapping from `config.models.yaml` → TOML; do not replace TOML registry.

## 7. `register_tool_pack` (native in-process tools)

| Seam | Evidence |
|------|----------|
| API | `crates/codegen/xai-grok-tools/src/registry/types.rs` |
| Type | `ToolPack = fn(&mut ToolRegistryBuilder)` |
| Function | `register_tool_pack(pack)` |
| Ordering | **MUST** run before first `ToolRegistryBuilder::new()` |
| Idempotency | Caller’s responsibility |

**do use:** new in-process tools when hooks/plugins cannot express behavior; implement `Tool` via `xai-tool-runtime` / grok tools metadata (`ToolNamespace`, `ToolKind`).

## 8. `ToolServerConfig` / toolset composition

| Seam | Evidence |
|------|----------|
| Config struct | `ToolServerConfig { tools, behavior_preset }` in `registry/types.rs` |
| Per-tool | `ToolConfig` id, overrides, kind, behavior_version |
| Workspace | Hub/session bind + toolset swap (`xai-grok-workspace`) |

**do use:** capability modes, name overrides, presets — configure before writing new tools.

## 9. MCP

| Seam | Evidence |
|------|----------|
| Client/server crate | `crates/codegen/xai-grok-mcp/` |
| Tools | `search_tool`, `use_tool` |
| Bridge | `xai-grok-tools/src/bridge.rs` |
| Computer hub adapter | `crates/common/xai-computer-hub-mcp-adapter/` |

**do use:** CodeGraph / external services as MCP first (L7), native tool only if MCP insufficient.

## 10. Subagent resolution (roles / personas / models)

| Seam | Evidence |
|------|----------|
| Pure resolution crate | `crates/codegen/xai-grok-subagent-resolution/` |
| Precedence | explicit override > role > persona > parent |
| Types | `SubagentRole`, `SubagentPersona`, `EffectiveRuntimeConfig` |

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

## TODO expand (workers)

- [ ] Exact hook file layout / matcher syntax examples from `xai-grok-hooks`
- [ ] Plugin manifest schema
- [ ] Skill discovery path order (project vs user vs bundled)
- [ ] Permission rule file formats

## See also

- [hard-limits.md](./hard-limits.md)
- [patterns.md](./patterns.md)
- [../architecture.md](../architecture.md) extension strategy
