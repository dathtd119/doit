# Native tools inventory

Evidence from forked tree: `crates/codegen/xai-grok-tools/`.

**Rule for do:** use these tools; do not reinvent plan/goal/todo/hashline/task/MCP wrappers.

## Namespaces (`ToolNamespace`)

Defined in `crates/codegen/xai-grok-tools/src/types/tool.rs`:

| Namespace | Serde aliases | Implementation tree |
|-----------|---------------|---------------------|
| **GrokBuild** | `GrokBuild` | `implementations/grok_build/` |
| **GrokBuildConcise** | `GrokBuildConcise` | `implementations/grok_build_concise/` |
| **GrokBuildHashline** | `GrokBuildHashline` | `implementations/grok_build_hashline/` |
| **Codex** | `Codex` | `implementations/codex/` |
| **OpenCode** | `opencode`, `OpenCode`, `open_code` | `implementations/opencode/` |
| **MCP** | `mcp`, `MCP` | Dynamic via MCP bridge + `search_tool` / `use_tool` |

Fully-qualified IDs look like `"GrokBuild:run_terminal_cmd"` (`versions.rs`, `ToolConfig`).

## Tool kinds (`ToolKind`)

Same file — capability filtering uses kind (not hardcoded IDs when kind is populated):

| Kind | Typical tools |
|------|----------------|
| `Read` / `Edit` / `Write` / `Delete` / `Move` | read_file, search_replace, … |
| `ListDir` / `Search` | list_dir, grep |
| `Execute` | run_terminal_cmd / bash |
| `Plan` | todo_write |
| `EnterPlan` / `ExitPlan` | enter_plan_mode, exit_plan_mode |
| `AskUser` | ask_user_question |
| `Task` / `BackgroundTaskAction` / `WaitTasksAction` / `KillTaskAction` | task, task_output, kill_task |
| `GoalUpdate` | update_goal |
| `Monitor` | monitor |
| `Skill` | skill tools |
| `WebSearch` / `WebFetch` | web_search, web_fetch |
| `Lsp` | lsp |
| `SearchTool` / `UseTool` | search_tool, use_tool (MCP) |
| `MemorySearch` / `MemoryGet` | memory tools |
| Image/video/deploy | image_gen, video_gen, deploy_app stubs |
| `Other` | serde sink for unknown kinds |

## GrokBuild namespace (primary)

Registered under `implementations/grok_build/` (module docs call these **NewTool** architecture tools). Modules present:

| Module / tool | Notes |
|---------------|--------|
| `bash` / run_terminal_cmd | Execute; version-managed (`versions.rs`) |
| `read_file`, `search_replace`, `list_dir`, `grep` | Filesystem |
| `todo` (`todo_write`) | Plan/todos continuum |
| `enter_plan_mode`, `exit_plan_mode` | Plan mode pair |
| `update_goal` | Goal classifier integration (`UPDATE_GOAL_TOOL_NAME`) |
| `ask_user_question` | User questions |
| `task`, `task_output`, `kill_task` | Subagents + background tasks |
| `scheduler` (create/delete/list) | Scheduled / loop tasks |
| `monitor` | Monitor kind |
| `lsp` | Language server |
| `web_search`, `web_fetch` | Network |
| `image_gen`, `image_edit`, `video_gen` | Media (product-coupled) |
| `deploy_app` | Stub / deployer config |

Entry re-exports: `implementations/grok_build/mod.rs`, `implementations/mod.rs`.

## GrokBuildHashline

`implementations/grok_build_hashline/` — hashline-aware read/edit/grep/mutate:

- `read_file`, `edit/`, `grep`, `mutate`, `anchor`, `scheme`, `config`, `benchmark`

Prefer hashline for precise edits when the session toolset includes this namespace.

## GrokBuildConcise

`implementations/grok_build_concise/` — concise variants of bash / read_file / search_replace (shorter I/O surface for constrained contexts).

## Codex namespace

`implementations/codex/`: `apply_patch`, `grep_files`, `list_dir`, `read_file` — Codex-compatible tool shapes.

## OpenCode namespace

`implementations/opencode/`: bash, edit, glob, grep, read, skill, todowrite, write — OpenCode-compatible names for interop / presets.

## MCP surface (not a static pack)

| Tool | Role | Path |
|------|------|------|
| `search_tool` | Index/discover MCP tools | `implementations/search_tool/` |
| `use_tool` | Invoke MCP (or detect mis-routed native calls) | `implementations/use_tool/` |
| MCP bridge | Register MCP tools into toolset | `xai-grok-tools/src/bridge.rs` (`register_mcp_tools`) |

MCP servers: `crates/codegen/xai-grok-mcp/` + computer-hub MCP adapter under `crates/common/`.

## Cross-cutting

| Piece | Path |
|-------|------|
| Skills tool + SkillInfo | `implementations/skills/` |
| Skill discovery reminders | `reminders/` + `SkillDiscoveryReminder` in registry |
| Claude/Cursor aliases | `types/claude_alias.rs` (Bash→Execute, TodoWrite→Plan, …) |
| Version-managed tools | `versions.rs` (e.g. `GrokBuild:run_terminal_cmd`) |
| Tool packs (external) | `registry/types.rs` → `register_tool_pack` |

## Toolsets and config

| Concept | Evidence |
|---------|----------|
| `ToolServerConfig` | `registry/types.rs` — `tools: Vec<ToolConfig>`, optional `behavior_preset` |
| `ToolConfig` | Fully-qualified `id`, `name_override`, `params_*`, `kind`, `behavior_version` |
| Session finalization | `SessionContext` + `FinalizedToolset` (same registry module; used by workspace hub) |
| Capability modes | Filter by `ToolKind`; tools with `kind: None` preserved (extensibility) |
| Workspace toolset swap | `xai-grok-workspace` hub/server tests reference `ToolServerConfig` with `GrokBuild:*` ids |

Default/product toolset composition is built via `grok_build` registration (`register_all` described in `grok_build/mod.rs`) plus shell/session config — **TODO expand**: exact default ID lists from shell presets.

## What do should use (not reinvent)

From product architecture (aligned with this inventory):

- Filesystem + hashline + grep/list
- Shell execute
- `todo_write`, `enter_plan_mode` / `exit_plan_mode`, `update_goal`
- `task` + subagent resolution
- Multi-model config (TOML), not a second registry
- Plugins / hooks / skills / MCP for extension

## TODO expand (workers)

- [ ] Exhaustive table of every `GrokBuild:<id>` registered in `register_all`
- [ ] Default toolset presets used by interactive vs headless sessions
- [ ] Hashline scheme defaults and when hashline namespace is enabled
- [ ] Memory tools paths and enablement flags

## See also

- [extension-seams.md](./extension-seams.md) — how to add tools without forking core
- [patterns.md](./patterns.md) — plan/goal/task usage patterns
