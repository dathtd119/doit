# Grok-build inventory (base understanding)

This section is the **evidence-backed map of forked Grok Build** inside `/home/datht/code/do`. Read it **before** crate work, new tools, or deep forks.

**Purpose for do:** know patterns to adopt, surfaces we can extend, and hard limits that require deep fork (or should not be fought).

**Sealed:** F-GROK-001 / VAL-GROK-001 (M0). Content is from the **forked tree** under `crates/`; not aspirational APIs.

## Documents

| Doc | Owns |
|-----|------|
| [overview.md](./overview.md) | What grok-build is, crate map, entry points |
| [native-tools.md](./native-tools.md) | Native tool inventory by namespace, kinds, toolsets |
| [extension-seams.md](./extension-seams.md) | **Where we can extend** (plugins, hooks, skills, agents, tool packs, config, MCP) |
| [hard-limits.md](./hard-limits.md) | **Where we cannot / hard without deep fork** |
| [patterns.md](./patterns.md) | Reusable patterns to adopt (plan, goal, subagents, hashline, hooks, ACP, …) |

## How to use

1. **Before crate patches** — read [extension-seams.md](./extension-seams.md) first; prefer do-harness / config / plugin / `register_tool_pack`.
2. **Before inventing a tool** — check [native-tools.md](./native-tools.md); use existing GrokBuild / Hashline / MCP tools.
3. **When blocked** — check [hard-limits.md](./hard-limits.md); document any crate patch in `docs/patch-matrix.md`.
4. **When designing product behavior** — adopt patterns from [patterns.md](./patterns.md); map pi-ness ideas via `docs/capability-map.md` (F-DOC-003).

## Evidence base

| Tree | Path | Role |
|------|------|------|
| Fork (writable) | `/home/datht/code/do` | **Primary evidence** (post F-FORK-001) |
| Upstream (read-only) | `/home/datht/code/grok-build` | Sibling reference only — never modify |

All crate paths below are relative to `/home/datht/code/do` unless absolute.

## Related product docs

- [../architecture.md](../architecture.md) — do system layout + L1–L13
- [../models-and-config.md](../models-and-config.md) — multi-model TOML + do YAML (L13)
- [../related-projects.md](../related-projects.md) — grok / pi-ness / OpenCode roles
- Root [../../AGENTS.md](../../AGENTS.md) — gates: read this section before crate work
