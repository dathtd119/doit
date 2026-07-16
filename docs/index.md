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
| [../README.md](../README.md) | Human product overview + identity |
| [../FORK.md](../FORK.md) | Fork policy, `~/.config/do` + project `.do/`, dual TOML+YAML, no external upstream PRs |

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
| [limitations.md](./limitations.md) | L1–**L13** evidence-backed inventory; **sealed** F-DOC-001 / VAL-DOC-001 (L13 design also in models-and-config) |
| [patch-matrix.md](./patch-matrix.md) | Gap → extension path / risk / order for **L1–L13**; **sealed** F-DOC-002 / VAL-DOC-002 |
| [capability-map.md](./capability-map.md) | pi-ness modules / L0–L6 / roles / continuum / **model assignment** → grok tools/APIs or `"gap"`; **sealed** F-DOC-003 / VAL-DOC-003 |
| [backlog-m1-m3.md](./backlog-m1-m3.md) | Ordered M1–M3 backlog; M1 **exit criteria sealed** (F-M1-SHIP); next PRIV then M2/M3; plan doc **sealed** F-BACK-001 / VAL-BACK-001 |

## Subsystem contracts

| Doc | Purpose |
|-----|---------|
| [prompt-system.md](./prompt-system.md) | L0–L6 → grok inject map + role lifecycle + fragments under `do-harness/prompts/` (**M1**) |
| [workspace.md](./workspace.md) | Continuum contract: goal / plan / todo → `.do/` + `~/.config/do` sessions; no dual-write (**CFG**) |
| [progressive-skills.md](./progressive-skills.md) | L4 progressive skill presentation policy start + reduced firehose surfaces (**M1**) |

## Agent readiness / quality

| Doc | Purpose |
|-----|---------|
| [testing.md](./testing.md) | Nextest retries, coverage floor, flaky policy |
| [tech-debt.md](./tech-debt.md) | Linked TODO/FIXME enforcement |
| [dependency-policy.md](./dependency-policy.md) | Min 7-day release age + Dependabot cooldown |
| [feature-flags.md](./feature-flags.md) | Flag lifecycle + dead-flag scan |
| [runbooks/README.md](./runbooks/README.md) | Incident, alerting, deploy impact |
| [generated/crate-inventory.md](./generated/crate-inventory.md) | Auto-generated crate list (`scripts/generate-docs.sh`) |
| [generated/smoke-commands.md](./generated/smoke-commands.md) | Auto-extracted smoke commands |

Quality scripts live under `scripts/`; CI: `.github/workflows/ci.yml`. Pre-commit: `.pre-commit-config.yaml`.

## Product surfaces

| Path | Role |
|------|------|
| `do-harness/` | Agents, hooks, skills, prompts, `config.models.yaml` |
| `~/.config/do/config.toml` | Stock multi-model + defaults (native; CFG home) |
| `crates/` | Forked grok-build workspace |

## Mission

Active mission: `mis_413072d4` under OpenCode missions. Mission `AGENTS.md` points here for the whole-idea contract; mission boundaries remain binding for workers.
