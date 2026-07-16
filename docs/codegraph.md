# CodeGraph product surface (L7 / F-M3-CG / VAL-M3-CG-001)

**Status:** M3 product surface **shipped** (2026-07-16).  
**Purpose:** Let agents answer explore/impact questions (“where is X / who calls X”) without full-repo grep thrash, using the existing fork graph crate.

## Design choice: MCP-first (not tool_pack)

| Option | Decision | Why |
|--------|----------|-----|
| **MCP stdio server** (chosen) | Product path | Wraps existing `code-graph` CLI from `xai-codebase-graph`; agents use stock `search_tool` → `use_tool`; no registry double-register; no crate fork |
| **`register_tool_pack`** | Deferred | Required only if in-process Tool trait / zero-spawn latency is mandatory; stock pack order is hard to keep correct ([patterns.md](./grok-build/patterns.md) § Tool packs) |
| **Greenfield index** | Rejected | Fork already owns `crates/codegen/xai-codebase-graph` — never reinvent ([hard-limits.md](./grok-build/hard-limits.md)) |
| **ACP code-nav only** | Insufficient alone | Web-gated eligibility (`x.ai/code/*` extensions in shell); not the primary agent tool surface for do roles |

**Citation (fork evidence):**

| Path | Role |
|------|------|
| `crates/codegen/xai-codebase-graph/` | Graph index + `Navigator` (definition / references by name or position) |
| `crates/codegen/xai-codebase-graph/src/bin/code_graph.rs` | CLI: `index`, `definition`, `references`, `stats` |
| `crates/codegen/xai-grok-shell/src/extensions/code_nav.rs` | ACP extension methods (editor path; web/capability gated) |
| `crates/codegen/xai-grok-workspace/src/file_system/codebase_index.rs` | Workspace FS integration for index manager |
| Stock MCP | `search_tool` / `use_tool` + `[mcp_servers.*]` in `~/.config/do/config.toml` or project `.do/config.toml` |

**Placement:** `plugin` / MCP wrapping local index first; optional `tool_pack` later if MCP latency or install friction forces it (patch-matrix L7). **No crate patch in this ship.**

## Product tools (MCP)

Server: `do-harness/codegraph/mcp_server.py` (stdio). Registered name: **`do-codegraph`**.

| MCP tool | Agent intent | Underlying `code-graph` |
|----------|--------------|-------------------------|
| `codegraph_explore` | Where is symbol X? map definition locations | `definition --symbol` (JSON) |
| `codegraph_impact` | Who calls / references X? | `references --symbol` (JSON) |
| `codegraph_stats` | Index health / top symbols | `stats` |

Optional args: `repo` (default cwd), `symbol`, `file`+`row`+`col` for position lookups, `cache` for index path.

**Index lifecycle:** agents (or operators) run `code-graph index <repo>` once (or after large rewrites). Cache default is crate `get_cache_path` (typically repo `.goto_index.bin`). Server also accepts `DO_CODEGRAPH_CACHE` / tool `cache` arg.

**Fail-open:** missing binary or empty results return guided text: build the binary, run index, fall back to `grep`/`lsp`/`read_file`. No hard crash on unindexed trees.

## Operator enablement

1. Build binary: `cargo build -p xai-codebase-graph --bin code-graph`
2. Optionally install: `cargo install --path crates/codegen/xai-codebase-graph --bin code-graph`
3. Add MCP server (example: `do-harness/codegraph/mcp.toml.example`) into user or project config:

```toml
[mcp_servers.do-codegraph]
command = "python3"
args = ["{repo}/do-harness/codegraph/mcp_server.py"]
enabled = true
```

Absolute paths preferred. Set env `DO_CODEGRAPH_BIN` if the binary is not on `PATH` / `target/debug/code-graph`.

4. In session: progressive MCP — `search_tool` for `codegraph_*`, then `use_tool`.

## Agent guidance

Roster roles that scout or edit should prefer CodeGraph before broad grep:

| Role | Policy |
|------|--------|
| **explorer** | Primary consumer: explore then impact; return map + citations |
| **worker** | Prefer impact before risky renames/edits when symbol is known |
| **oracle** | Impact for architectural “who depends on X” questions |
| **orchestrator** | May spawn explorer with CodeGraph for recon |

Policy pointers live in agent profiles + L1 role fragments.

## Verify

```bash
bash do-harness/scripts/verify-codegraph.sh
```

Checks design doc, server + example config, fixture explore/impact answers, binary presence (build if needed), and agent/doc pointers. Exit 0 is contract evidence for **VAL-M3-CG-001**.

## Non-goals (this ship)

- In-process `tool_pack` registration
- Full pi-ness `@colbymchenry/codegraph` / `.codegraph/` format port
- Changing ACP web eligibility gates
- Replacing `grep` / `lsp` — they remain fallback

## Related

- [capability-map.md](./capability-map.md) L7 row  
- [patch-matrix.md](./patch-matrix.md) L7 (MCP path; no crate log this ship)  
- [limitations.md](./limitations.md) L7  
- [backlog-m1-m3.md](./backlog-m1-m3.md) M3-CG01/CG02  
- [progressive-skills.md](./progressive-skills.md) MCP `search_tool` / `use_tool`  
