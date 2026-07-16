# Related projects

How **do** learns from neighboring systems without modifying them in place.

## grok-build (base)

| | |
|--|--|
| **Path** | `/home/datht/code/grok-build` |
| **Access** | **Read-only** reference; import by **COPY** into `/home/datht/code/do` |
| **What we take** | Full Rust harness: pager/TUI, shell, tools registry, agents, plugins, hooks, skills, MCP, LSP, plan/goal/todo continuum |
| **Multi-model** | Native: many `[model.<name>]` in `~/.grok/config.toml`, `[models] default`, api_backend, agent/persona/spawn model overrides |
| **What we do not do** | Modify upstream tree; open external upstream PRs as the product path |

Binary lineage after import: `xai-grok-pager-bin` (installed as `grok` upstream; product brand **do** in docs).

## pi-ness (ideas)

| | |
|--|--|
| **Path** | `/home/datht/code/pi-ness` |
| **Access** | **Read-only** reference — never modify |
| **What we take** | Harness-control thesis: roles, L0–L6 prompts, progressive catalogs, guided gates, workspace continuum, continuation discipline |
| **What we do not take (M0–M1)** | Full OpenTUI / Node port; wholesale runtime rewrite |

Also useful inside pi-ness docs for OpenCode notes (e.g. `docs/opencode-harnessing.md`) when studying config control patterns.

## OpenCode (config control learnings)

| | |
|--|--|
| **Typical config** | `~/.config/opencode/` |
| **Access** | User environment + docs; not a second import tree |
| **What we learn** | Provider/model catalogs; **agent definitions with `model` (+ permissions)**; plugins; permission rules; file-driven operator control |
| **What do does differently** | Runtime multi-model stays stock **TOML** (`config.toml`); product assignment UX prefers **YAML** overlay under `do-harness/` that maps into TOML + agent frontmatter |

See [models-and-config.md](./models-and-config.md) for the dual-surface design and limitation **L13**.

## Mapping summary

```
pi-ness          → control ideas (roles, layers, gates, continuum)
OpenCode         → config ergonomics (agent.model, providers, permissions)
grok-build       → native implementation (Rust tools, multi-model TOML, agents)
do               → fork of grok + extension layer (do-harness) + docs control plane
```

## Citation rule

When borrowing a pattern, cite the source path or doc in the plan/report or durable doc. Prefer extension seams before crate patches.
