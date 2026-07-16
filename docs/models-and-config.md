# Models and config control

**Status:** M0 design + template. Runtime wiring of do YAML → agents is M1.  
**Limitation ID:** **L13**

## Summary

Grok-build already supports **multiple custom models**. The product gap is not “add multi-model” — it is **assignment UX and role→model policy** comparable to OpenCode (orchestrator / explorer / worker / oracle each pin a model and optional reasoning effort), plus a **do-owned YAML** surface that feels controllable without fighting stock TOML.

## What grok already has

Document these accurately; do not claim single-model-only.

### Registry (`~/.grok/config.toml`)

- **Many** `[model.<name>]` sections (not limited to one custom model)
- `[models] default = "..."` selects the default model name
- Per-model fields typically include provider endpoints, API keys (env refs), and **`api_backend`**: `chat_completions` | `responses` | `messages`
- Compatible with OpenAI / Anthropic / custom-compatible backends depending on backend choice

Illustrative TOML shape (field names may vary slightly by version — always verify against forked docs / source):

```toml
[models]
default = "combo-big"

[model.combo-big]
# model id, base_url, api_key env, api_backend, etc.

[model.combo-small]
# lighter / cheaper model for scouting and intake
```

### Resolution order for subagents

When a subagent runs, model selection follows approximately:

1. **Spawn override** (explicit model on the spawn / task call)
2. **Role** definition model (if the role pins one)
3. **Persona** model
4. **Parent** session model / default

Agent definitions can set `model` in frontmatter or equivalent agent config.

### Primary-session role switch and model re-assignment

Product rule (see [prompt-system.md](./prompt-system.md) Role lifecycle, root AGENTS **Role switch lock**):

| When | Role Tab / Shift+Tab | Role→model re-assignment |
|------|----------------------|---------------------------|
| Session start — no user messages yet | Allowed | **Apply** assignment for the newly selected role |
| After first user message or any conversation content | **Disabled** | **Do not** re-pin model via role hop mid-session |

Spawn overrides for subagents are unchanged and independent of primary-session role lock.

### What this means for do

- Keep **reading and writing** stock `~/.grok/config.toml` for native multi-model — do not invent a second runtime registry that the binary ignores
- Product work focuses on **ergonomics**, **role assignment policy**, and optional **YAML → TOML / agent frontmatter** mapping

## What OpenCode does better (learn, don’t clone wholesale)

Reference: user `~/.config/opencode/`, and pi-ness notes in `docs/opencode-harnessing.md` (under pi-ness; read-only).

| OpenCode strength | Why users care | do response |
|-------------------|----------------|-------------|
| Provider catalog + model list | Discover and pin models without tribal knowledge | Document registry templates; optional YAML registry that maps to `[model.*]` |
| **Agent definitions with `model`** | Orchestrator vs explorer vs worker each cost/latency appropriate | `assignment:` table in do YAML + agent frontmatter |
| Permissions in config | Same file family as agents | Later; guided hooks first (L6); permission YAML optional later |
| Plugins as installable bundles | Optional power without core fork | do-harness + `.grok/plugins` |

User need (product requirements):

1. Multi-model registry that feels as controllable as OpenCode providers + agent model assignment
2. Assign models like OpenCode: **intake / orchestrator / explorer / worker / oracle** each can pin model (+ reasoning effort when supported)
3. Learn OpenCode patterns: agent model+permissions, providers, permission rules, plugins — user control via config files
4. Prefer **YAML** for do product overlays; stock grok stays **TOML**

## do target design

### Dual surface

| Surface | Format | Authority | Milestone |
|---------|--------|-----------|-----------|
| Stock grok | `~/.grok/config.toml` | **Runtime** multi-model + default | M0 (document) |
| do product | `do-harness/config.models.yaml` (later also `~/.do/config.yaml`) | **Policy** registry ergonomics + role assignment | M0 template; M1 wire |

### Registry

- N named models (OpenAI / Anthropic / compat)
- `default` name
- Each entry carries enough to map into a `[model.<name>]` section

### Assignment table

| Role / agent | Typical model class | Notes |
|--------------|---------------------|-------|
| `intake` | small / cheap | Routing, clarification |
| `orchestrator` | large / strong | Planning, coordination |
| `explorer` | small / fast | Scout, grep-heavy |
| `worker` | large / strong | Implementation |
| `oracle` | large / strong | Architecture, hard decisions |

Optional per assignment: `effort` / reasoning level when the backend supports it.

### Example YAML (`do-harness/config.models.yaml`)

```yaml
# do product model overlay — M0 template (not yet auto-applied by binary)
# Maps to ~/.grok/config.toml [model.*] + agent frontmatter model fields.
# See docs/models-and-config.md

models:
  default: combo-big
  registry:
    combo-big:
      model: your-large-model-id
      base_url: https://api.example.com/v1
      api_backend: chat_completions
      # api_key_env: EXAMPLE_API_KEY
    combo-small:
      model: your-small-model-id
      base_url: https://api.example.com/v1
      api_backend: chat_completions

assignment:
  intake: combo-small
  orchestrator: combo-big
  explorer: combo-small
  worker: combo-big
  oracle: combo-big
  # optional effort pins (when supported by backend / agent schema):
  # orchestrator:
  #   model: combo-big
  #   effort: high
```

### How YAML maps to grok

| YAML | Stock grok |
|------|------------|
| `models.registry.<name>` | `[model.<name>]` block in `config.toml` |
| `models.default` | `[models] default = "<name>"` |
| `assignment.<role>` | Agent definition `model:` field for that role’s profile under `do-harness/agents/` (and/or persona) |
| spawn-time override | Unchanged — still wins over role/persona/parent |

**M0:** document + ship template under `do-harness/config.models.yaml`; operators may hand-sync to TOML.  
**M1:** tooling or harness convention applies assignment into agent frontmatter (and optionally emits/diff-checks TOML).  
**Later:** optional `do models apply` / validate command; still no second runtime that bypasses grok.

### Validation principles

- Registry names referenced in `assignment` must exist in `registry` (or known stock models)
- Prefer env var names for secrets — never commit API keys
- English-only keys and comments in repo templates

## Limitation L13 (full statement)

| Field | Content |
|-------|---------|
| **ID** | L13 |
| **pi-ness / OpenCode idea** | Provider catalog + per-agent model pins + permission/config control via files |
| **Stock grok-build** | Multi-model **already works**: many `[model.<name>]`, default, api_backend; subagent resolution spawn > role > persona > parent; agents can set model |
| **Gap** | Assignment **UX** and **role→model policy** weaker than OpenCode; no first-class do product YAML overlay; operators must hand-edit TOML + agent files without a single assignment table |
| **Preferred path** | `do-harness` YAML template + agent frontmatter; document mapping; M1 wire; avoid crate patch unless agent discovery cannot express model pins |
| **Risk if ignored** | Users under-use multi-model or thrash config; cost/latency wrong for explorer vs oracle; product feels less controllable than OpenCode |

## Related files

| Path | Role |
|------|------|
| `do-harness/config.models.yaml` | Product template (registry + assignment) |
| `~/.grok/config.toml` | Native multi-model runtime |
| `do-harness/agents/*` | Role profiles; receive `model` pins |
| [architecture.md](./architecture.md) | L1–L13 table |
| [related-projects.md](./related-projects.md) | OpenCode / pi-ness pointers |
| Root [AGENTS.md](../AGENTS.md) | Compact models & config control section |

## Non-goals (this page)

- Replacing `config.toml` multi-model with a YAML-only runtime
- Implementing OpenCode providers wholesale in Rust in M0
- Multi-provider auth redesign (parked; see future-plan)
