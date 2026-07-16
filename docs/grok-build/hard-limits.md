# Hard limits (where we **cannot** / deep-fork only)

Surfaces that **do must not casually fight**. Prefer extension seams ([extension-seams.md](./extension-seams.md)). If a crate patch is unavoidable, record it in `docs/patch-matrix.md`.

## Product / process limits

| Limit | Implication for do | Evidence / policy |
|-------|--------------------|-------------------|
| **No external upstream PRs** | do is a private/local fork path | Root `AGENTS.md` Hard Constraints; [../related-projects.md](../related-projects.md) |
| **Never modify sibling trees** | `/home/datht/code/grok-build` and `/home/datht/code/pi-ness` are **read-only** | Import by **COPY** only into `/home/datht/code/do` |
| **Generated workspace root** | Do not treat root `Cargo.toml` as hand-edited source of truth | Header: *Auto-generated workspace root. Prefer editing per-crate Cargo.toml files.* |
| **Apache-2.0 + notices** | Preserve `LICENSE`, `THIRD-PARTY-NOTICES` on every ship | Import requirement |

## Architecture limits

| Limit | Why hard | Where it shows up |
|-------|----------|-------------------|
| **Main-session role machine gaps (L1)** | Agents/personas are strong for **subagents**; primary-session intake→orchestrator role cycle + **Tab lock after first message** are product work, not free | `xai-grok-agent`, `xai-grok-subagent-resolution`; product rule in `AGENTS.md` / `docs/prompt-system.md` |
| **No TS harness factories (L3)** | Always-on behavior is Rust + plugins/hooks, not pi-ness-style TS factories | Monolithic `xai-grok-tools` registry + `ToolRegistryBuilder::new()` |
| **No unified continuation coordinator (L5)** | Goal classifier, plan mode, todos exist **separately** | `update_goal`, plan tools, todo tools; no single priority coordinator crate |
| **Dual Tool / NewTool migration** | `grok_build/mod.rs`: new tools implement **NewTool**; old `Tool` paths still exist during migration under `implementations/<tool>/` | Migration split + unified runtime `Tool` in `xai-tool-runtime` |
| **Tool pack ordering** | `register_tool_pack` **must** run before first `ToolRegistryBuilder::new()` | `registry/types.rs` ordering contract |
| **Deep pager / TUI fork** | Last resort; high cost (ratatui stack) | `xai-grok-pager*`, L11; M0–M1: **no OpenTUI port** |
| **xAI / GrokBuild environment coupling** | Production gateway URLs, update channels, deployment IDs, asset servers | `GrokBuildEnvironment` in `xai-grok-shell-base/src/env.rs`; update crates |
| **Auth stock paths (M0)** | Keep stock auth; multi-provider beyond stock is future | `xai-grok-auth` |
| **Windows best-effort** | Some tool bundling/search helpers are Unix-gated | e.g. tools build helpers under `#[cfg(unix)]` consumers |
| **Capability mode + unknown kinds** | Unknown `ToolKind` → `Other` and may be **dropped** in restrictive modes | `ToolConfig` kind deserialize notes in `registry/types.rs` |
| **MCP mis-routing** | Native tools wrongly called via `use_tool` need corrective errors | `use_tool` implementation comments |
| **Hashline vs standard exclusivity** | `FileToolset` Standard and Hashline are **mutually exclusive** for read/edit/grep | `xai-grok-shell/src/tools/config.rs` `FileToolset` docs |

## What not to reinvent

| Already native | Do not build a parallel… |
|----------------|---------------------------|
| `enter_plan_mode` / `exit_plan_mode` | Second plan protocol |
| `update_goal` + classifier | Second goal state machine (unless coordinating **on top**) |
| hashline namespace + `file_toolset` | Alternate edit addressing without reason |
| `task` + subagent resolution | Second spawn stack |
| multi-`[model.*]` TOML | Competing runtime model registry (YAML **overlays** only) |
| MCP search/use | Parallel MCP client in do-harness |
| `xai-codebase-graph` crate | Ignoring existing graph package when adding CodeGraph (still may need MCP/API productization — L7) |

Note: `xai-codebase-graph` **exists** in the fork (`crates/codegen/xai-codebase-graph/` — `index_manager.rs`, `navigation.rs`, `scope_graph/`). L7 gap is productized lean tools / agent exposure, not “zero graph code.”

## Config dual-surface rule

| Do | Do not |
|----|--------|
| Map `do-harness/config.models.yaml` → stock TOML + agent frontmatter | Replace `~/.grok/config.toml` multi-model registry with a second runtime source of truth |

## When a crate patch is allowed

1. Extension seams exhausted (documented attempt).
2. Placement asked / recorded (Native vs Extension vs Crate Patch in `AGENTS.md`).
3. Entry added to `docs/patch-matrix.md` with risk + order.
4. Prefer surgical diffs; avoid deep pager forks until M2+ with explicit decision.

## See also

- [extension-seams.md](./extension-seams.md)
- [../architecture.md](../architecture.md) L1–L13
- Root customization order in `AGENTS.md`
