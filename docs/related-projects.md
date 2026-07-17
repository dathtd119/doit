# Related projects

How **doit** learns from neighboring systems without modifying them in place.

**Full learning-source inventory + residual gap register:** [future-plan.md](./future-plan.md) (opens with Learning sources).

---

## grok-build (base)

| | |
|--|--|
| **Path** | `/home/datht/code/grok-build` |
| **Access** | **Read-only** reference; import by **COPY** into `/home/datht/code/doit` only |
| **What we take** | Full Rust harness: pager/TUI, shell, tools registry, agents, plugins, hooks, skills, MCP, LSP, plan/goal/todo continuum |
| **Multi-model** | Native: many `[model.<name>]` in `~/.config/doit/config.toml`, `[models] default`, api_backend, agent/persona/spawn model overrides |
| **What we do not do** | Modify upstream tree; open external upstream PRs as the product path |

Binary lineage after import: `xai-grok-pager-bin` (installed as `grok` upstream; product brand **doit** / historical **do**).

---

## pi-ness (ideas)

| | |
|--|--|
| **Path** | `/home/datht/code/pi-ness` |
| **Access** | **Read-only** reference — never modify |
| **What we take** | Harness-control thesis: roles, L0–L6 prompts, progressive catalogs, guided gates, workspace continuum, continuation discipline, role-as-system |
| **What we do not take** | Full OpenTUI / Node port; wholesale runtime rewrite; 1:1 `.piness/` layout |

Sibling lineage (also read-only when used):

| Path | Use |
|------|-----|
| `/home/datht/code/pi` | Upstream pi runtime pi-ness builds on |
| `/home/datht/code/pi-ness-old` | Historical continuum / `.piness` lessons |
| `/home/datht/code/oh-my-pi` | OMP edit modes / recovery UX |

Also useful inside pi-ness docs for OpenCode notes (e.g. `docs/opencode-harnessing.md`) when studying config control patterns.

---

## OpenCode (config control learnings)

| | |
|--|--|
| **Path** | `/home/datht/code/opencode` |
| **Typical config** | `~/.config/opencode/` |
| **Access** | Read-only reference + user env; not a second product import tree |
| **What we learn** | Provider/model catalogs; **agent definitions with `model` (+ permissions)**; plugins; permission rules merge; Tab = agent cycle; file-driven operator control |
| **What doit does differently** | Runtime multi-model stays stock **TOML** (`config.toml`); product assignment UX prefers **YAML** overlay under `do-harness/` that maps into TOML + agent frontmatter |

Slim / local samples: `/home/datht/code/oh-my-opencode-slim`, `/home/datht/code/.opencode`.

See [models-and-config.md](./models-and-config.md) for the dual-surface design and limitation **L13**.

---

## opencode-missions (mission runner learnings)

| | |
|--|--|
| **Path** | `/home/datht/code/opencode-missions` |
| **Access** | **Read-only** reference — never modify |
| **What we learn** | Mission lifecycle (propose → plan → run → handoff → milestone validation); orchestrator/worker/validator roster; structured handoff tools; slash commands |
| **Key docs** | `docs/mission-lifecycle.md`, `docs/architecture.md`, `src/tools/*` |
| **What doit does differently** | Re-express on grok continuum (`update_goal` / plan / todo / hooks / skills); mission disk under doit share paths — not OpenCode `~/.local/share/opencode/missions` |

Primary parking-lot home: goal-as-mission in [future-plan.md](./future-plan.md).

---

## Other useful neighbors

| Path | Learn |
|------|-------|
| `/home/datht/code/codegraph` | Lean explore/impact (MCP already mapped in doit) |
| `/home/datht/code/codex` | `--yolo` / permission default patterns (D1b) |
| `/home/datht/code/grok-build-no-telemetry` | Privacy patches (PRIV sealed) |
| `/home/datht/code/claudekit-cli` | Validator / journal process discipline |

---

## Mapping summary

```
pi-ness (+ pi / oh-my-pi)     → control ideas (roles, layers, gates, continuum)
OpenCode (+ oh-my-opencode-*) → config ergonomics (agent.model, providers, permissions)
opencode-missions             → goal-as-mission runner (validators, handoffs, lifecycle)
grok-build                    → native implementation (Rust tools, multi-model TOML, agents)
doit                          → fork of grok + do-harness overlay + docs control plane
```

---

## Citation rule

When borrowing a pattern, cite the source path or doc in the plan/report or durable doc. Prefer extension seams before crate patches. Never edit learning trees in place (VAL-CROSS-001).
