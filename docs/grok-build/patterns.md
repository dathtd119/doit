# Patterns to adopt from grok-build

Reusable behaviors **do should build on**, not reimplement. Evidence from the forked tree.

## 1. Plan mode

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| Enter/exit as a **paired** mode | `EnterPlanModeTool` / `ExitPlanModeTool` under `implementations/grok_build/`; registered in `ToolRegistryBuilder::new()` | Use tools; do not invent a second plan mode |
| Tool hints in prompts | Enter-plan output hints default toward `ask_user_question` + `exit_plan_mode` (`types/output.rs` tests; Claude aliases keep pair) | Keep guided next-steps in product prompts |
| Plan file on disk | Session plan probing in tools/workspace continuum | Map pi-ness workspace continuum onto session plan layout (L9) |

## 2. `update_goal` + classifier

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| Model-driven goal progress | `implementations/grok_build/update_goal/`; `UPDATE_GOAL_TOOL_NAME` from tools-api | Use `update_goal` for continuum; do not dual-write goals |
| Registered with todos/tasks | Same builder registration block as `TodoWriteTool` / `TaskTool` | Compose continuum in product policy |
| Telemetry / events | Sampling/file-utils events around goal completion | Observability without a parallel goal bus |

**Gap (L5):** no single continuation coordinator — compose plan + goal + todo carefully in product policy until M2.

## 3. Subagent resolution

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| Precedence | `xai-grok-subagent-resolution`: **override > role > persona > parent** (`lib.rs`, `overrides.rs`) | Role→model assignment must respect this chain |
| Pure resolution crate | No session/transport deps — reusable | Keep policy in resolution + agent defs; avoid shell-only forks |
| Persona fail-closed / role soft-fail | File-read errors vs missing prompt_file | Document spawn failure modes for workers |
| Resume identity | Type/persona checks; model soft-ignored on resume (`resume.rs`) | Document resume semantics for workers |
| Agent discovery merge | Project can shadow built-ins; user/bundled cannot (`discovery.rs`) | Place do proof agents under project `.doit/agents` or linked path |

Spawn surface: `TaskTool` (`implementations/grok_build/task/`).

## 4. Hashline edits

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| Hashline namespace | `ToolNamespace::GrokBuildHashline`, `implementations/grok_build_hashline/` | Prefer hashline for precise multi-hunk edits when enabled |
| Config switch | `FileToolset::{Standard, Hashline}` in shell `tools/config.rs`; default **Standard** | Product default is **standard**; hashline is **opt-in** via `file_toolset = "hashline"` ([hashline.md](../hashline.md)) |
| Mutual exclusivity | Standard and Hashline toolsets are mutually exclusive for read/edit/grep | Do not enable both in one toolset |
| FQ IDs | `GrokBuildHashline:hashline_read` / `hashline_edit` / `hashline_grep` | Use exact IDs in `ToolServerConfig` |
| Scheme params | `[toolset.hashline]` — `scheme`, `hash_len`, `chunk_size` | Validate via `HashlineSchemeConfig::validate` |

## 5. Skill discovery reminders

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| Cross-cutting reminders | `Reminder` trait + `SkillDiscoveryReminder` in tools registry | Progressive catalog (L4): reminders over full dump |
| Skills on SessionContext | `SessionContext.skills: Vec<SkillInfo>` | Install do skills onto discovery paths |
| Bundled examples | `xai-grok-shell/skills/` (`best-of-n`, `code-review`, `create-skill`, …) | Follow same skill layout conventions |
| Listing | `xai_grok_agent::prompt::skills::list_skills` via workspace `discover_skills` | Align do-harness skill layout with discovery |

## 6. Permissions + hooks

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| PreToolUse gate | `HookEvent::PreToolUse`; hooks runner (command/http) | Guided blocks: name gate + **Do this instead** |
| Hook file discovery | `HookSource::Directory` of `*.json` under `~/.config/doit/hooks/` or project `.doit/hooks/` | Ship do guided hook as JSON on discovery path |
| Permission subsystem | `xai-grok-workspace/src/permission/` (policy, auto_mode, rules, shell_access) | Layer hooks **with** permission rules, not instead of |
| Plan-mode auto allowlist | `auto_mode.rs` references plan-mode tools | Align dangerous-tool policy with plan mode |

## 7. Tool registry composition

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| Tool packs | `register_tool_pack` before first builder; applied inside `new()` | Startup registration only |
| Built-in registration | Explicit list in `ToolRegistryBuilder::new()` | Prefer config toolset over forking registration list |
| ToolServerConfig | Explicit tool ID lists + behavior_preset | Config-driven toolsets per role/capability |
| Kind-based capability filters | `ToolKind` on `ToolConfig` | Prefer kind filters over ID hardcoding for new tools |
| Version presets | `behavior_preset` / `versions.rs` managed tools | Pin behavior for regression safety |

## 8. MCP dispatch

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| Discover then call | `SearchTool` → `UseTool` | External tools via MCP |
| Mis-route detection | Native tools through `use_tool` → corrective error | Teach models in tool error text (same spirit as guided gates) |
| Graph package exists | `xai-codebase-graph` crate present | Prefer MCP/product exposure before reinventing graph indexing |

## 9. Scheduler / monitor

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| Scheduler tools | `SchedulerCreateTool` / `Delete` / `List` registered in builder; modules under `grok_build/scheduler` | Long-running / loop tasks without reinventing timers |
| Monitor tool | `MonitorTool`, `ToolKind::Monitor` | Background observation patterns |
| Task survival across toolset swap | Workspace tests: tasks survive `ToolServerConfig` rebuild | Design product toolset swaps carefully |

## 10. ACP

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| ACP library linked from pager-bin | `xai-acp-lib` in pager-bin deps | IDE/client integration via ACP, not a second wire protocol |

## 11. Multi-model (stock)

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| Many named models + default | config / models crates; product docs L13 | Keep TOML runtime; YAML assignment overlay for UX |
| Subagent model chain | `resolve_effective_overrides` in subagent-resolution | Wire do role pins into this chain in M1 |
| Goal role model pools | config-types remote settings (planner/strategist/goal_skeptic) | Do not confuse with product role Tab cycle (L1) |

## 12. Composition-root binary

| Pattern | Evidence | Adopt how |
|---------|----------|-----------|
| Thin binary, fat libraries | `xai-grok-pager-bin` composes pager + shell + ACP + update | Prefer extending libraries/extension seams over bloating `main.rs` |
| Multiple agent modes | headless / leader / stdio from same shell crate | Headless discovery checks for F-EXT-003 |

## Anti-patterns (do not adopt)

- Bare permission denials without gate name + alternative
- Mid-session primary role hops (product rule: lock after first user message)
- Competing model registry at runtime
- Deep TUI fork before hooks/plugins/tool packs fail
- Inventing tools that already exist under GrokBuild / Hashline / MCP
- Enabling Standard and Hashline file tools in the same toolset

## See also

- [native-tools.md](./native-tools.md)
- [extension-seams.md](./extension-seams.md)
- [hard-limits.md](./hard-limits.md)
- [../workspace.md](../workspace.md), [../prompt-system.md](../prompt-system.md)
