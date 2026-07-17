# Agents and prompts (stock-native product)

**Status:** locked 2026-07-17  
**Placement:** layer A (`do-harness`) + thin shell resolve (product agent inject)

## Thesis

One agent system: **Grok stock**. Product customizes **mission bodies** and **contracts**, not a parallel role enum forever.

| Surface | Owns |
|---------|------|
| Stock `BuiltinAgentName` + discovery | Runtime agent identity, tool templates, spawn pipeline |
| `do-harness/prompts/agents/<stem>.md` | Mission body only (Extend `prompt_body`) |
| `~/.config/doit/prompts/agents/` | User body overrides |
| `.doit/prompts/agents/` | Project body overrides |
| `[agents]` in config.toml | Model, color, description, tools, **allowed_subagents**, order, default |
| `~/.config/doit/agents/*.md` | Optional full AgentDefinition (power users only; product does not install here) |

**No product `do-harness/agents/` tree.** Bodies live only under `prompts/agents/`.

## Canonical names and aliases

Short file stems and chrome labels map to **canonical agent ids** (stock family):

| Alias / file stem | Canonical agent name | Notes |
|-------------------|----------------------|--------|
| `intake` | **`grok-build-ask-user`** | Option A — stock ask-user profile + product body |
| `orchestrator` | **`grok-build-orchestrator`** | Stock builtin + body inject |
| `explore` / `explorer` | **`explore`** | Stock subagent type (spawn-native) |
| `worker` | **`grok-build-worker`** | Product specialist (dynamic) |
| `oracle` | **`grok-build-oracle`** | Product specialist (dynamic) |
| (primary) | **`grok-build`** | Stock primary; optional body later |
| `plan` | **`plan`** | Stock plan subagent |

Session / spawn / Task use **canonical** names. Chrome may show the short **alias**.

When a user adds `~/.config/doit/prompts/agents/worker.md`, product ensures config for **`grok-build-worker`** (model, description, spawn list) and registers that id.

## Dynamic agent list

Tab cycle and cold-start are **not** a hardcoded five-name crate forever.

1. If `[agents].order` is set → use that list (canonical names).
2. Else → all agents with a contract under `[agents.*]` that have a resolvable body (or product floors).
3. Fallback → bundled default order (see seed `config.agents.toml`).

```toml
[agents]
default = "grok-build-ask-user"
order = [
  "grok-build-ask-user",
  "grok-build-orchestrator",
  "explore",
  "grok-build-worker",
  "grok-build-oracle",
]
```

Users add specialists by:

1. Body: `prompts/agents/<alias>.md` (or `grok-build-foo.md`)
2. Contract: `[agents.grok-build-foo]` (description, model, tools, `allowed_subagents`)
3. Wire parents: add `"grok-build-foo"` to other agents’ `allowed_subagents`

## How agents call each other (native Grok)

| Mechanism | Use |
|-----------|-----|
| `spawn_subagent` / Task / Agent | Child session |
| `subagent_type` | Canonical agent name (`explore`, `plan`, `general-purpose`, `grok-build-worker`, …) |
| Builtin advertised types | `general-purpose`, `explore`, `plan` (+ discovered customs) |
| `allowed_subagents` / `Agent(…)` floors | Per-parent spawn allowlist from config |
| Personas | Optional overlay (tone/IO), not a second agent system |

**Per-agent spawn graph** (example seed):

```text
grok-build-orchestrator
  ├─ explore
  ├─ plan
  ├─ grok-build-worker ──► explore
  ├─ grok-build-oracle ──► explore
  └─ general-purpose
grok-build-ask-user ──► explore
explore / plan        ──► (leaf)
```

Prompts teach **native** types, e.g. `subagent_type="grok-build-worker"`, not legacy `Agent(worker)` alone.

## Prompt load order

For a resolve key (alias or canonical):

1. Project `.doit/prompts/agents/<stem>.md` (walk repo chain)
2. User `~/.config/doit/prompts/agents/<stem>.md`
3. Compile-time bundled `do-harness/prompts/agents/<stem>.md`

Stem tried: alias first, then canonical file name if different.

## Config schema (seed)

```toml
[agents]
default = "grok-build-ask-user"
order = ["grok-build-ask-user", "grok-build-orchestrator", "explore", "grok-build-worker", "grok-build-oracle"]

[agents.grok-build-worker]
alias = "worker"
description = "Implementation specialist"
model = "combo-medium"
color = "yellow"
base = "grok-build"
allowed_subagents = ["explore"]
tools = ["read_file", "search_replace", "write", "…"]
disallowed_tools = ["Agent(grok-build-orchestrator)", "…"]
```

**Compat:** `[roles]` / `config.roles.toml` still accepted as an alias of `[agents]` during migration; new seed is `config.agents.toml`.

## Runtime resolve

`resolve_product_agent(name)` (formerly product role):

1. Map alias → canonical (and accept already-canonical).
2. Optional full agent file override under `.doit/agents/` or `~/.config/doit/agents/`.
3. Contract from `[agents.<canonical>]` (or floors).
4. Body from `prompts/agents/`.
5. Build `AgentDefinition` with **`name = canonical`**, tools, model, `allowed_subagent_types` from `allowed_subagents`.

Non-product names fall through to stock discovery.

## Non-goals

- Second product-only spawn API beside Task
- Shipping product defaults only as `do-harness/agents/*.md`
- Hardcoding every future specialist in crate enums
- Mid-session agent Tab hop after first user message (lock unchanged)

## Related

- [models-and-config.md](./models-and-config.md) — registry + contracts
- [prompt-system.md](./prompt-system.md) — assembly + role/agent lock
- [FORK.md](../FORK.md) §1.1 — inject-first
- Seed: `do-harness/config.agents.toml`, bodies: `do-harness/prompts/agents/`
