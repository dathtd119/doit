# Hashline edit policy (F-M3-HASH / VAL-M3-HASH-001)

**Status:** Available as **opt-in** (product default is **standard** as of 2026-07-16).  
**Purpose:** Document native **GrokBuildHashline** file tools and how to enable them without reinventing hashline grammar.  
**Native surface:** `GrokBuildHashline:hashline_read|hashline_edit|hashline_grep` via stock `FileToolset::Hashline` (`crates/codegen/xai-grok-shell/src/tools/config.rs`).

## Decision

| Option | Choice | Why |
|--------|--------|-----|
| **Product default** | `file_toolset = "standard"` | Shorter tool defs (`read_file` / `search_replace` / `grep`); less prompt cost; simpler agent surface |
| **Stock Rust default** | `FileToolset::Standard` | Binary/stock Default matches product |
| **Hashline** | **Opt-in** | Set `file_toolset = "hashline"` when anchor-based edit is preferred |
| **Grammar rewrite** | **Rejected** | Do not invent a second hashline dialect — use native scheme (`chunk` / `content_only`) |

**Placement:** config + agent guidance (extension) — **no crate patch**. Runtime selection stays stock `resolve_file_toolset` / `override_file_tools`.

## How stock selection works

| Layer | Source | Effect |
|-------|--------|--------|
| Session file toolset | `[toolset] file_toolset` in `~/.config/doit/config.toml` (primary) | `"hashline"` swaps read/edit/search to hashline triple; `"standard"` keeps `read_file` / `search_replace` / `grep` |
| Scheme knobs | `[toolset.hashline]` | `scheme`, `hash_len`, `chunk_size` (validated by stock; ignored when not hashline) |
| Mutual exclusivity | Shell finalization | Hashline and Standard file triples do not ship side-by-side when override applies |
| Role floors | Agent `tools` / `disallowedTools` | Filter the finalized set |

Evidence: `ShellToolsetConfig::resolve_file_toolset`, `FileToolset::tool_configs`, `agent_ops` / subagent `override_file_tools`.

**Note:** Product agent config for toolset is loaded from user effective config (`~/.config/doit/config.toml`). After changing SoT, run `python3 do-harness/scripts/sync-user-config.py --apply` and **restart the session**.

## Product default

```toml
# do-harness/config.toolset.toml (merged by sync-user-config)
[toolset]
file_toolset = "standard"
```

Worker prefers `search_replace` / `write`. Hashline tools are **not** on the worker allowlist by default.

### Opt-in to hashline (operator)

1. Set in `~/.config/doit/config.toml` (or change SoT `config.toolset.toml` then sync):

```toml
[toolset]
file_toolset = "hashline"

[toolset.hashline]
scheme = "chunk"
hash_len = 3
chunk_size = 8
```

2. Optionally add `hashline_read` / `hashline_edit` / `hashline_grep` to worker `tools` in `config.roles.toml` and re-run `apply-role-contracts.sh --apply`.

3. Restart the session.

### Agent / role guidance (standard default)

| Role | File edit policy |
|------|------------------|
| **worker** | Primary editor: `read_file` / `search_replace` / `write` / `grep` |
| **orchestrator** | No bulk edit (`write` / `search_replace` denied) |
| **explorer / intake / oracle** | Read-only floors |

## Workflow (standard tools)

1. **Read** — `read_file` (offset/limit for large files).  
2. **Locate** — `grep` or CodeGraph.  
3. **Edit** — `search_replace` or `write`.  
4. **Verify** — tests / `lsp` as needed.

### Hashline workflow (when opt-in)

1. **Read with anchors** — `hashline_read`.  
2. **Locate** — `hashline_grep`.  
3. **Edit** — `hashline_edit` with anchors from the latest read.  
4. Do not invent hashes or dual-write Standard + Hashline in one turn.

Native docs: [native-tools.md](./grok-build/native-tools.md), [patterns.md](./grok-build/patterns.md).

## Rollback / switch

| Goal | Action |
|------|--------|
| **Use standard (product default)** | `file_toolset = "standard"` (or remove key) + restart |
| **Use hashline** | `file_toolset = "hashline"` + restart |
| **Scheme only** | Keep hashline; change `[toolset.hashline]` knobs |

```sh
bash do-harness/scripts/verify-hashline.sh
# documents native surface + opt-in path; exit 0 = contract OK
```

## Safety boundaries

- Hashline is **not** a substitute for guided gates (`path-policy-*`, `dangerous-shell-*`, `env-expose-*`).  
- Only **worker** holds the full edit surface floor.  
- Invalid `[toolset.hashline]` fails stock validation.  
- No new grammar, no crate patch for this feature, no second edit registry.

## Related

| Doc / path | Role |
|------------|------|
| [native-tools.md](./grok-build/native-tools.md) | Hashline namespace inventory |
| [role-permissions.md](./role-permissions.md) | Edit-surface floors |
| `do-harness/config.toolset.toml` | Product `[toolset]` fragment (standard default) |
| `do-harness/scripts/verify-hashline.sh` | Native surface + policy checks |
