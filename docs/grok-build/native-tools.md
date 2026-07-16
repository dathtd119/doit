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

| Kind | Role |
|------|------|
| `Read` / `Edit` / `Write` / `Delete` / `Move` | Filesystem mutations |
| `ListDir` / `Search` / `List` | Directory / search |
| `Execute` | Shell / bash |
| `Plan` | `todo_write` |
| `EnterPlan` / `ExitPlan` | Plan mode pair |
| `AskUser` | `ask_user_question` |
| `Task` / `BackgroundTaskAction` / `WaitTasksAction` / `KillTaskAction` | Subagents + background tasks |
| `GoalUpdate` | `update_goal` |
| `Monitor` | monitor |
| `Skill` | skill tools |
| `WebSearch` / `WebFetch` | Network |
| `Lsp` | Language server |
| `SearchTool` / `UseTool` | MCP discover / invoke |
| `MemorySearch` / `MemoryGet` | Memory tools |
| `ImageGen` / `VideoGen` / `ImageToVideo` / `ReferenceToVideo` / `DeployApp` | Media / deploy |
| `Other` | Serde sink for unknown kinds |

## Registration source of truth

All built-ins below are registered in **`ToolRegistryBuilder::new()`**:

`crates/codegen/xai-grok-tools/src/registry/types.rs` (approx. lines 663–741).

External packs run after built-ins via `for pack in tool_packs().lock().iter()`.

## GrokBuild namespace (primary)

Modules under `implementations/grok_build/` (module docs: **NewTool** architecture; old `Tool` paths may still live under `implementations/<tool>/` during migration).

| Registered type (builder) | Module | Notes |
|---------------------------|--------|--------|
| `BashTool` | `bash/` | Execute; version-managed as `GrokBuild:run_terminal_cmd` |
| `ReadFileTool` | `read_file/` | Filesystem read |
| `SearchReplaceTool` | `search_replace/` | Edit |
| `ListDirTool` | `list_dir/` | List |
| `GrepTool` | `grep/` | Search |
| `KillTaskTool` / `KillTerminalCommandTool` | `kill_task/` | Kill |
| `TodoWriteTool` | `todo/` | Plan continuum |
| `UpdateGoalTool` | `update_goal/` | `UPDATE_GOAL_TOOL_NAME` re-export |
| `TaskOutputTool` / `GetTerminalCommandOutputTool` / `WaitTasksTool` | `task_output/` | Task I/O |
| `TaskTool` | `task/` | Subagent spawn |
| `WebSearchTool` / `WebFetchTool` | `web_search/`, `web_fetch/` | Network |
| `LspTool` | `lsp/` | LSP |
| `ImageGenTool` / `ImageEditTool` / `ImageToVideoTool` / `ReferenceToVideoTool` | media modules | Product-coupled |
| `EnterPlanModeTool` / `ExitPlanModeTool` | `enter_plan_mode/`, `exit_plan_mode/` | Plan mode pair |
| `AskUserQuestionTool` | `ask_user_question/` | User questions |
| `MonitorTool` | `monitor/` | Monitor |
| `SchedulerCreateTool` / `SchedulerDeleteTool` / `SchedulerListTool` | `scheduler/` | Scheduled / loop tasks |

Also present as module (deploy stub): `deploy_app` / `DEPLOY_APP_TOOL_NAME` (exported; product-coupled).

Entry re-exports: `implementations/grok_build/mod.rs`.

### Version-managed GrokBuild IDs

From `crates/codegen/xai-grok-tools/src/versions.rs` (`MANAGED_TOOLS`):

- `GrokBuild:run_terminal_cmd`
- `GrokBuild:read_file`
- `GrokBuild:search_replace`
- `GrokBuild:list_dir`
- `GrokBuild:grep`
- `GrokBuild:kill_task`
- `GrokBuild:get_task_output`

Presets include `"current"` and `"legacy-0.4.10"` (grep is managed but may only have `"current"`).

## GrokBuildHashline

`implementations/grok_build_hashline/` — hashline-anchored read/edit/grep:

| Tool type | FQ ID (when selected) |
|-----------|------------------------|
| `HashlineReadTool` | `GrokBuildHashline:hashline_read` |
| `HashlineEditTool` | `GrokBuildHashline:hashline_edit` |
| `HashlineGrepTool` | `GrokBuildHashline:hashline_grep` |

Supporting modules: `anchor.rs`, `scheme.rs`, `mutate.rs`, `edit/`, `config.rs`, `benchmark.rs`.

**File toolset selection (mutually exclusive):** shell config `FileToolset::{Standard, Hashline}` in `crates/codegen/xai-grok-shell/src/tools/config.rs`:

- Default: **`Standard`** (`read_file`, `search_replace`, `grep`)
- `file_toolset = "hashline"`: swaps in the three hashline tools (see config comments under `[toolset]` / `[toolset.hashline]`)

## GrokBuildConcise

Registered concise variants (shorter I/O surface):

- `ReadFileConciseTool`
- `SearchReplaceConciseTool`
- `BashConciseTool`

Path: `implementations/grok_build_concise/`.

## Codex namespace

Registered in the same builder:

| Type | Module |
|------|--------|
| `ApplyPatchTool` | `codex/apply_patch/` |
| `CodexListDirTool` | `codex/list_dir/` |
| `CodexGrepFilesTool` | `codex/grep_files/` |
| `CodexReadFileTool` | `codex/read_file/` |

## OpenCode namespace

| Type | Module |
|------|--------|
| `OpenCodeBashTool` | `opencode/bash/` |
| `OpenCodeReadTool` | `opencode/read/` |
| `OpenCodeEditTool` | `opencode/edit/` |
| `OpenCodeWriteTool` | `opencode/write/` |
| `OpenCodeGrepTool` | `opencode/grep/` |
| `OpenCodeGlobTool` | `opencode/glob/` |
| `OpenCodeTodoWriteTool` | `opencode/todowrite/` |
| `OpenCodeSkillTool` | `opencode/skill/` |

OpenCode-compatible names for interop / presets.

## Memory + MCP surface

| Type | Path | Role |
|------|------|------|
| `MemorySearchImpl` / `MemoryGetImpl` | `implementations/memory/` | Memory search/get |
| `SearchTool` | `implementations/search_tool/` | Discover MCP tools |
| `UseTool` | `implementations/use_tool/` | Invoke MCP (or detect mis-routed native calls) |
| MCP bridge | `xai-grok-tools/src/bridge.rs` | Register MCP tools into toolset |

MCP servers: `crates/codegen/xai-grok-mcp/` + computer-hub MCP adapter under `crates/common/xai-computer-hub-mcp-adapter/`.

## Cross-cutting reminders

Registered at end of `ToolRegistryBuilder::new()`:

| Reminder | Purpose |
|----------|---------|
| `LspDiagnosticsReminder` | Post-tool LSP diagnostics |
| `TaskCompletionReminder` | Task completion signals |
| `SkillDiscoveryReminder` | Progressive skill discovery (`reminders/` + registry) |

Also: skills tool + `SkillInfo` under `implementations/skills/`; Claude/Cursor aliases in `types/claude_alias.rs`.

## Toolsets and config

| Concept | Evidence |
|---------|----------|
| `ToolServerConfig` | `registry/types.rs` — `tools: Vec<ToolConfig>`, optional `behavior_preset` |
| `ToolConfig` | Fully-qualified `id`, `name_override`, `params_*`, `kind`, `behavior_version` |
| Session finalization | `SessionContext` + `FinalizedToolset` (same registry module; used by workspace hub) |
| Capability modes | Filter by `ToolKind`; tools with `kind: None` preserved (extensibility) |
| Shell toolset knobs | `xai-grok-shell/src/tools/config.rs` — `[toolset.bash]`, `[toolset.web_fetch]`, `[toolset.ask_user_question]`, `file_toolset`, `[toolset.hashline]` |
| Workspace toolset swap | `xai-grok-workspace` hub/server tests reference `ToolServerConfig` with `GrokBuild:*` ids |

## What do should use (not reinvent)

From product architecture (aligned with this inventory):

- Filesystem + optional hashline + grep/list
- Shell execute
- `todo_write`, `enter_plan_mode` / `exit_plan_mode`, `update_goal`
- `task` + subagent resolution
- Multi-model config (TOML), not a second registry
- Plugins / hooks / skills / MCP for extension

## See also

- [extension-seams.md](./extension-seams.md) — how to add tools without forking core
- [patterns.md](./patterns.md) — plan/goal/task usage patterns
