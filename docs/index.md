# do documentation index

Agent and human entry point for the **do** product (forked Grok Build + pi-ness harness control + OpenCode-style model assignment).

## Start here

| Doc | Purpose |
|-----|---------|
| [index.md](./index.md) | This documentation map (control-plane entry) |
| [../AGENTS.md](../AGENTS.md) | Operating contract, gates, compact living status |
| [architecture.md](./architecture.md) | System layout, data flow, limitations sketch L1–L13 |
| [models-and-config.md](./models-and-config.md) | Multi-model registry, role assignment, TOML + YAML dual surface |
| [current-status.md](./current-status.md) | Expanded narrative status |
| [future-plan.md](./future-plan.md) | Long parking lot (not root AGENTS) |
| [milestone-ship-discipline.md](./milestone-ship-discipline.md) | Docs + commit every milestone |
| [related-projects.md](./related-projects.md) | pi-ness, grok-build, OpenCode learnings |
| [../CHANGELOGS.md](../CHANGELOGS.md) | What shipped |
| [../README.md](../README.md) | Human product overview |

## Grok-build inventory (base understanding)

Read **before crate work**. Evidence-backed map of the forked Grok Build base: patterns, extendable seams, hard limits.

| Doc | Purpose |
|-----|---------|
| [grok-build/README.md](./grok-build/README.md) | Section index + how to use |
| [grok-build/overview.md](./grok-build/overview.md) | What grok-build is, crate map, entry points |
| [grok-build/native-tools.md](./grok-build/native-tools.md) | Native tools by namespace (GrokBuild, Hashline, Codex, OpenCode, MCP), kinds, toolsets |
| [grok-build/extension-seams.md](./grok-build/extension-seams.md) | **Where we can extend** — plugins, hooks, skills, agents, tool packs, config, MCP |
| [grok-build/hard-limits.md](./grok-build/hard-limits.md) | **Where we cannot / deep-fork only** |
| [grok-build/patterns.md](./grok-build/patterns.md) | Patterns to adopt (plan, goal, subagents, hashline, hooks, ACP, …) |

## Inventory (M0 evidence docs)

| Doc | Purpose |
|-----|---------|
| [limitations.md](./limitations.md) | L1–L13 gaps; **L13 sealed** (F-MODEL-001); L1–L12 deepened under F-DOC-001 |
| [patch-matrix.md](./patch-matrix.md) | Gap → extension path / risk / order; **L13 row sealed** |
| [capability-map.md](./capability-map.md) | pi-ness concepts → grok tools/APIs or `"gap"` (pairs with grok-build inventory; F-DOC-003) |
| [backlog-m1-m3.md](./backlog-m1-m3.md) | Ordered M1–M3 backlog (F-BACK-001) |

## Subsystem stubs

| Doc | Purpose |
|-----|---------|
| [prompt-system.md](./prompt-system.md) | L0–L6 prompt layers (stub) + **Role lifecycle** (Tab cycle lock; M1 note) |
| [workspace.md](./workspace.md) | Session continuum: goal / plan / todo (stub) |

## Product surfaces

| Path | Role |
|------|------|
| `do-harness/` | Agents, hooks, skills, prompts, `config.models.yaml` |
| `~/.grok/config.toml` | Stock multi-model + defaults (native) |
| `crates/` | Forked grok-build workspace |

## Mission

Active mission: `mis_413072d4` under OpenCode missions. Mission `AGENTS.md` points here for the whole-idea contract; mission boundaries remain binding for workers.
