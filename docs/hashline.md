# Hashline default edit policy (F-M3-HASH / VAL-M3-HASH-001)

**Status:** M3 product policy **shipped** (2026-07-16).  
**Purpose:** Prefer native **GrokBuildHashline** file tools over Standard for product sessions **where safe**, without reinventing hashline grammar.  
**Native surface:** `GrokBuildHashline:hashline_read|hashline_edit|hashline_grep` via stock `FileToolset::Hashline` (`crates/codegen/xai-grok-shell/src/tools/config.rs`).

## Decision

| Option | Choice | Why |
|--------|--------|-----|
| **Product default** | `file_toolset = "hashline"` | Anchor-based edit is safer against line-number drift; native namespace already complete |
| **Stock Rust default** | Remains `FileToolset::Standard` | Binary/stock Default is unchanged; product installs overlay TOML + agent floors |
| **Grammar rewrite** | **Rejected** | Do not invent a second hashline dialect — use native scheme (`chunk` / `content_only`) |

**Placement:** config + agent guidance (extension) — **no crate patch**. Runtime selection stays stock `resolve_file_toolset` / `override_file_tools`.

## How stock selection works

| Layer | Source | Effect |
|-------|--------|--------|
| Session file toolset | `[toolset] file_toolset` in `~/.config/do/config.toml` or project `.do/config.toml` | `"hashline"` swaps read/edit/search to hashline triple; `"standard"` keeps `read_file` / `search_replace` / `grep` |
| Scheme knobs | `[toolset.hashline]` | `scheme`, `hash_len`, `chunk_size` (validated by stock) |
| Mutual exclusivity | Shell finalization | Hashline and Standard file triples do not ship side-by-side in the active tool server config when override applies |
| Role floors | Agent `tools` / `disallowedTools` | Still filter the finalized set — non-workers never gain `hashline_edit` |

Evidence: `ShellToolsetConfig::resolve_file_toolset`, `FileToolset::tool_configs`, `agent_ops` / subagent `override_file_tools`.

## Product default (where safe)

**Where safe =** product **worker** implementation path (and any session that has chosen hashline via config). Non-implementer roles still **deny** `hashline_edit` (and the rest of the edit surface).

### Enablement (operator)

1. Merge recommended fragment into user or project TOML:

```toml
# Prefer product fragment: do-harness/config.toolset.toml
# (copy/link keys into ~/.config/do/config.toml or .do/config.toml)

[toolset]
file_toolset = "hashline"

[toolset.hashline]
scheme = "chunk"
hash_len = 3
chunk_size = 8
```

Source of truth fragment: [`do-harness/config.toolset.toml`](../do-harness/config.toolset.toml).

2. Install/link product agents (worker already prefers hashline tools in floor + body).

3. New sessions load the toolset after config merge. Existing sessions keep the toolset they started with until restart.

### Agent / role guidance

| Role | Hashline policy |
|------|-----------------|
| **worker** | **Primary editor.** Prefer `hashline_read` → plan anchors → `hashline_edit` → `hashline_grep`. When `file_toolset = "hashline"`, do **not** thrash with Standard IDs if they are absent. Fallback: `write` for new files / whole-file create only. |
| **orchestrator** | Does **not** bulk-edit; keeps `hashline_edit` / `search_replace` / `write` on deny floor. May note “worker uses hashline” in plans. |
| **explorer / intake / oracle** | Read-only floors: may use read/search (hashline or standard depending on toolset). **Never** `hashline_edit`. |

Worker profile + L1: `do-harness/agents/worker.md`, `do-harness/prompts/roles/worker.md`.  
Permission floors: [role-permissions.md](./role-permissions.md), `do-harness/config.permissions.yaml`.

## Workflow (native tools only)

1. **Read with anchors** — `hashline_read` on the target path (region when known).  
2. **Locate** — `hashline_grep` or CodeGraph for symbol → path, then hashline read.  
3. **Edit** — `hashline_edit` with anchors from the latest read (do not invent hashes).  
4. **Verify** — targeted tests / harness scripts / `lsp` as needed.  
5. **Do not** reimplement anchor schemes, custom patch DSLs, or dual write via Standard + Hashline in one turn.

Native docs: [native-tools.md](./grok-build/native-tools.md) (GrokBuildHashline), [patterns.md](./grok-build/patterns.md).

## Rollback path

Operators may leave product hashline **at any time** without code changes:

| Goal | Action |
|------|--------|
| **Session / install rollback** | Set `[toolset] file_toolset = "standard"` (or remove the key so stock Default = Standard) in user or project TOML |
| **Scheme only** | Keep `file_toolset = "hashline"`; change `[toolset.hashline]` scheme / sizes |
| **Agent guidance only** | Worker body still “prefers hashline when active”; with Standard toolset, stock `read_file` / `search_replace` / `grep` return |
| **Role edit deny** | Non-worker `disallowedTools` still block `hashline_edit` under either toolset |

Restart the session after TOML change. Documented verification:

```sh
bash do-harness/scripts/verify-hashline.sh
# expect: exit 0 and "VAL-M3-HASH-001: PASS"
```

## Safety boundaries

- Hashline is **not** a substitute for guided gates (`path-policy-*`, `dangerous-shell-*`, `env-expose-*`).  
- Only **worker** holds the full edit surface floor.  
- Invalid `[toolset.hashline]` fails stock validation (do not ship broken scheme knobs).  
- No new grammar, no crate patch for this feature, no second edit registry.

## Verify

```sh
bash do-harness/scripts/verify-hashline.sh
```

Checks policy doc, toolset fragment default, worker/orchestrator guidance, role floor alignment, native namespace citations, and explicit rollback instructions. Exit 0 is contract evidence for **VAL-M3-HASH-001**.

## Related

| Doc / path | Role |
|------------|------|
| [native-tools.md](./grok-build/native-tools.md) | Hashline namespace inventory |
| [role-permissions.md](./role-permissions.md) | Edit-surface floors (hashline_edit deny) |
| [codegraph.md](./codegraph.md) | Prefer graph before thrashy search; then hashline edit |
| [capability-map.md](./capability-map.md) | pi-ness hashline → GrokBuildHashline |
| [backlog-m1-m3.md](./backlog-m1-m3.md) | M3-H01 / M3-H02 |
| `do-harness/config.toolset.toml` | Product recommended `[toolset]` fragment |
| `do-harness/scripts/verify-hashline.sh` | VAL-M3-HASH-001 evidence |
