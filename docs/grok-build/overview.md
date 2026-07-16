# Grok-build overview

Evidence-backed snapshot of the forked Grok Build tree that **do** is built on.

## What it is

**Grok Build** is a native-rich **Rust** coding-agent harness: TUI pager, shell/session runtime, tool registry, agents/personas, plugins/hooks/skills, MCP, workspace hub, plan/goal/todo continuum, multi-model config.

| Fact | Evidence |
|------|----------|
| Product binary lineage | `xai-grok-pager-bin` → binary name `xai-grok-pager` (`crates/codegen/xai-grok-pager-bin/`) |
| License | Apache-2.0 (`LICENSE`, per-crate `license = "Apache-2.0"`) |
| Workspace root | Root `Cargo.toml` — **auto-generated**; comment: *Prefer editing per-crate Cargo.toml files* |
| Config home (stock) | `~/.grok` / `GROK_HOME` (agent discovery, config.toml) |
| Branding in do | Docs/product name **do**; keep `~/.grok` discovery for M0 |

## Entry points

```
User / CLI
  → xai-grok-pager-bin (composition root)
       → xai-grok-pager (TUI / application)
       → xai-grok-shell (agent runtime, leader, headless, config)
       → xai-grok-tools (tool registry + implementations)
       → xai-grok-agent (agent defs, plugins, prompts)
       → xai-grok-workspace (sessions, permissions, hub)
       → xai-grok-hooks + xai-hooks-plugins-types
       → xai-grok-mcp / computer-hub MCP adapter
       → xai-acp-lib (Agent Client Protocol)
```

| Surface | Crate / path |
|---------|----------------|
| Binary composition root | `crates/codegen/xai-grok-pager-bin/src/main.rs` |
| Pager / TUI library | `crates/codegen/xai-grok-pager/` |
| Shell / session / leader | `crates/codegen/xai-grok-shell/` |
| Tools registry + packs | `crates/codegen/xai-grok-tools/` (`register_tool_pack` in `src/registry/types.rs`) |
| Tool trait runtime | `crates/common/xai-tool-runtime/` (unified `Tool` trait) |
| Tool protocol / types | `crates/common/xai-tool-protocol/`, `xai-tool-types/` |
| Agent discovery + defs | `crates/codegen/xai-grok-agent/src/discovery.rs` |
| Subagent resolution | `crates/codegen/xai-grok-subagent-resolution/` |
| Config load | `crates/codegen/xai-grok-config/`, `xai-grok-config-types/` |
| Models | `crates/codegen/xai-grok-models/` |
| Hooks runtime | `crates/codegen/xai-grok-hooks/` |
| Hook/plugin types | `crates/codegen/xai-hooks-plugins-types/` |
| Plugin marketplace | `crates/codegen/xai-grok-plugin-marketplace/` |
| Workspace + permissions | `crates/codegen/xai-grok-workspace/` (`src/permission/`) |
| MCP | `crates/codegen/xai-grok-mcp/` |
| Codebase graph (native pkg) | `crates/codegen/xai-codebase-graph/` |
| ACP | `crates/codegen/xai-acp-lib/` |
| Paths / home | `crates/codegen/xai-grok-paths/` |

## Crate map (high level)

Workspace members live under:

| Area | Path | Role |
|------|------|------|
| **codegen** | `crates/codegen/*` | Product crates (pager, shell, tools, agent, MCP, …) |
| **common** | `crates/common/*` | Shared tool runtime, protocol, tracing, computer-hub |
| **build** | `crates/build/*` | Build helpers (e.g. `xai-proto-build`) |
| **prod** | `prod/*` | Prod-adjacent packages (e.g. cli-chat-proxy types) |

### Clusters (do-relevant)

| Cluster | Key crates |
|---------|------------|
| UI / process | `xai-grok-pager*`, `xai-ratatui-*`, `ptyctl*` |
| Agent loop | `xai-grok-shell*`, `xai-grok-agent`, `xai-agent-lifecycle`, `xai-chat-state` |
| Tools | `xai-grok-tools`, `xai-grok-tools-api`, `xai-tool-runtime`, `xai-tool-protocol` |
| Extension | `xai-grok-hooks`, `xai-hooks-plugins-types`, `xai-grok-plugin-marketplace` |
| Continuum / workspace | `xai-grok-workspace*`, goal/plan tools under `xai-grok-tools` |
| Models / auth | `xai-grok-models`, `xai-grok-auth`, `xai-grok-config*` |
| Integrations | `xai-grok-mcp`, `xai-acp-lib`, computer-hub SDK/adapters |

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

Grok already supports multiple models via TOML (`~/.grok/config.toml`): many `[model.<name>]`, `[models] default`, api backends. Subagent resolution: **spawn override > role > persona > parent** (`xai-grok-subagent-resolution`). Product assignment UX is a **do** gap (L13) — see [../models-and-config.md](../models-and-config.md).

## TODO expand (workers)

- [ ] Full member list annotated by “touch often / rarely / never for do”
- [ ] Headless vs TUI launch paths from `xai-grok-shell` leader
- [ ] Session directory layout on disk (plan.md, goals, state)
- [ ] Exact config.toml schema keys from `xai-grok-config-types`

## See also

- [native-tools.md](./native-tools.md)
- [extension-seams.md](./extension-seams.md)
- [hard-limits.md](./hard-limits.md)
- [patterns.md](./patterns.md)
