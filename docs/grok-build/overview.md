# Grok-build overview

Evidence-backed snapshot of the forked Grok Build tree that **do** is built on.

## What it is

**Grok Build** is a native-rich **Rust** coding-agent harness: TUI pager, shell/session runtime, tool registry, agents/personas, plugins/hooks/skills, MCP, workspace hub, plan/goal/todo continuum, multi-model config.

| Fact | Evidence |
|------|----------|
| Product binary lineage | Package `xai-grok-pager-bin` → binary name `xai-grok-pager` (`crates/codegen/xai-grok-pager-bin/Cargo.toml`: `default-run = "xai-grok-pager"`, `[[bin]] name = "xai-grok-pager"`) |
| License | Apache-2.0 (`LICENSE`; per-crate `license = "Apache-2.0"`) |
| Workspace root | Root `Cargo.toml` line 1: *Auto-generated workspace root. Prefer editing per-crate Cargo.toml files.* |
| Config home (stock) | `~/.grok` / `GROK_HOME` (agent discovery, config.toml, hooks, skills) |
| Branding in do | Docs/product name **do**; keep `~/.grok` discovery for M0 |

## Entry points

```
User / CLI
  → xai-grok-pager-bin (composition root: crates/codegen/xai-grok-pager-bin/src/main.rs)
       → xai-grok-pager (TUI / application library)
       → xai-grok-shell (agent runtime: run_headless, run_leader, run_stdio_agent)
       → xai-grok-tools (tool registry + implementations)
       → xai-grok-agent (agent defs, plugins, prompts, skills listing)
       → xai-grok-workspace (sessions, permissions, hub, discovery)
       → xai-grok-hooks + xai-hooks-plugins-types
       → xai-grok-mcp / computer-hub MCP adapter
       → xai-acp-lib (Agent Client Protocol)
```

`main.rs` wires pager CLI modes and shell entry points:

| Mode | Call site (pager-bin / shell) |
|------|-------------------------------|
| Headless agent | `xai_grok_shell::agent::app::run_headless` |
| Leader process | `xai_grok_shell::agent::app::run_leader` |
| Stdio agent | `xai_grok_shell::agent::app::run_stdio_agent` |
| ACP | `xai-acp-lib` linked from pager-bin `Cargo.toml` |

| Surface | Crate / path |
|---------|----------------|
| Binary composition root | `crates/codegen/xai-grok-pager-bin/src/main.rs` |
| Pager / TUI library | `crates/codegen/xai-grok-pager/` |
| Shell / session / leader | `crates/codegen/xai-grok-shell/` (`src/agent/`, `src/leader/`, `src/tools/`) |
| Tools registry + packs | `crates/codegen/xai-grok-tools/` (`register_tool_pack` + `ToolRegistryBuilder::new` in `src/registry/types.rs`) |
| Tool trait runtime | `crates/common/xai-tool-runtime/` (unified `Tool` trait) |
| Tool protocol / types | `crates/common/xai-tool-protocol/`, `xai-tool-types/` |
| Agent discovery + defs | `crates/codegen/xai-grok-agent/src/discovery.rs` |
| Subagent resolution | `crates/codegen/xai-grok-subagent-resolution/` |
| Config load | `crates/codegen/xai-grok-config/`, `xai-grok-config-types/` |
| Models | `crates/codegen/xai-grok-models/` |
| Hooks runtime | `crates/codegen/xai-grok-hooks/` (`discovery.rs`, `dispatcher.rs`, `runner/`) |
| Hook/plugin types | `crates/codegen/xai-hooks-plugins-types/` |
| Plugin marketplace | `crates/codegen/xai-grok-plugin-marketplace/` |
| Workspace + permissions | `crates/codegen/xai-grok-workspace/` (`src/permission/`, `src/discovery.rs`) |
| MCP | `crates/codegen/xai-grok-mcp/` |
| Codebase graph (native pkg) | `crates/codegen/xai-codebase-graph/` (`index_manager.rs`, `navigation.rs`, `scope_graph/`) |
| ACP | `crates/codegen/xai-acp-lib/` |
| Paths / home | `crates/codegen/xai-grok-paths/` |
| Shell environment | `crates/codegen/xai-grok-shell-base/src/env.rs` (`GrokBuildEnvironment`) |

## Crate map (high level)

Workspace members live under:

| Area | Path | Role |
|------|------|------|
| **codegen** | `crates/codegen/*` | Product crates (pager, shell, tools, agent, MCP, …) |
| **common** | `crates/common/*` | Shared tool runtime, protocol, tracing, computer-hub |
| **build** | `crates/build/*` | Build helpers (e.g. `xai-proto-build`) |
| **prod** | `prod/*` | Prod-adjacent packages (when present) |

### Clusters (do-relevant)

| Cluster | Key crates |
|---------|------------|
| UI / process | `xai-grok-pager*`, `xai-ratatui-*`, `ptyctl*` |
| Agent loop | `xai-grok-shell*`, `xai-grok-agent`, `xai-agent-lifecycle`, `xai-chat-state` |
| Tools | `xai-grok-tools`, `xai-grok-tools-api`, `xai-tool-runtime`, `xai-tool-protocol` |
| Extension | `xai-grok-hooks`, `xai-hooks-plugins-types`, `xai-grok-plugin-marketplace` |
| Continuum / workspace | `xai-grok-workspace*`, goal/plan/todo tools under `xai-grok-tools` |
| Models / auth | `xai-grok-models`, `xai-grok-auth`, `xai-grok-config*` |
| Integrations | `xai-grok-mcp`, `xai-acp-lib`, computer-hub SDK/adapters |

### Touch guidance for do workers

| Frequency | Crates / areas |
|-----------|----------------|
| **Touch often (via extension first)** | do-harness; `~/.grok` config; agents/hooks/skills discovery paths |
| **Touch when adding native tools** | `xai-grok-tools` (`register_tool_pack` or `implementations/`), `xai-tool-runtime` |
| **Touch rarely** | `xai-grok-shell` session actor, `xai-grok-workspace` hub |
| **Avoid unless last resort** | `xai-grok-pager*` deep TUI, generated root `Cargo.toml`, xAI env/update coupling |

## Layout after import (do)

```
/home/datht/code/do/
  Cargo.toml                 # workspace (generated header)
  crates/codegen/...         # main product crates
  crates/common/...
  crates/build/...
  do-harness/                # do product identity (not upstream)
  docs/                      # do control plane + this inventory
  LICENSE, THIRD-PARTY-NOTICES
```

## Multi-model (stock)

Grok already supports multiple models via TOML (`~/.config/doit/config.toml`, `$GROK_HOME`): many `[model.<name>]`, `[models] default`, api backends. Subagent resolution precedence is documented in crate docs and implemented in `resolve_effective_overrides`:

**explicit spawn override > role > persona > parent**

Evidence:

- Crate docs: `crates/codegen/xai-grok-subagent-resolution/src/lib.rs` (module header)
- Implementation: `crates/codegen/xai-grok-subagent-resolution/src/overrides.rs` (`resolve_effective_overrides`)

Product assignment UX is a **do** gap (L13) — see [../models-and-config.md](../models-and-config.md).

## Tool registration entry (critical for crate work)

Built-in tools are registered inside **`ToolRegistryBuilder::new()`** (`crates/codegen/xai-grok-tools/src/registry/types.rs`, ~lines 657–745): GrokBuild tools, Codex, OpenCode, memory, MCP search/use, concise variants, hashline tools, then cross-cutting reminders, then **external tool packs**.

The `implementations/grok_build/mod.rs` module docs refer to a `register_all()` narrative; the live wiring for the standard toolset is **`ToolRegistryBuilder::new()`**. Out-of-tree packs must call `register_tool_pack` **before** the first `ToolRegistryBuilder::new()`.

## See also

- [native-tools.md](./native-tools.md)
- [extension-seams.md](./extension-seams.md)
- [hard-limits.md](./hard-limits.md)
- [patterns.md](./patterns.md)
