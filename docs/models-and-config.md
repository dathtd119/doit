# Models and config control

**Status:** M0 design + template sealed (F-MODEL-001). M1 apply script ships
`do-harness/scripts/apply-models.sh` (F-M1-MODEL-APPLY / VAL-M1-MODEL-001): maps
YAML `assignment` → agent frontmatter. **F-M1-MODEL-RESOLVE:** primary-session
role cycle re-pins model from agent `model:` **only while** `role_switch_allowed`;
post-lock keeps the model stack; subagent spawn overrides unchanged.
**PRIV F-PRIV-AUTH:** BYOK / `preferred_method=api_key` does not force grok.com
OAuth (see Auth section; crate **P-AUTH-01**).  
**CFG-DOIT sealed:** user home **`~/.config/doit` only** (P-CFG-HOME-DOIT); project discovery
**`.doit/`** (P-CFG-PROJECT-DOIT); env override **`GROK_HOME`** (full root replace;
`DO_HOME` not wired). No silent default dual-read of `~/.grok` or `~/.config/do`.  
**Limitation ID:** **L13**

## Summary

Grok-build already supports **multiple custom models**. The product gap is not “add multi-model” — it is **assignment UX and role→model policy** comparable to OpenCode (orchestrator / explorer / worker / oracle each pin a model and optional reasoning effort), plus a **do-owned YAML** surface that feels controllable without fighting stock TOML.

| Claim | Truth |
|-------|--------|
| Multi-model registry | **Exists** in stock grok (`[model.<name>]` × N + `[models] default`) |
| Subagent model resolution | **Exists** — spawn override > role > persona > parent |
| OpenCode-like assignment table | **Gap** — no single product file that pins role → model (+ effort) |
| do YAML overlay | **Template + apply script** at `do-harness/config.models.yaml` + `scripts/apply-models.sh`; stock TOML remains runtime SoT |

## Evidence (forked tree)

Paths under `/home/datht/code/do` (post F-FORK-001 import):

| Fact | Evidence path |
|------|----------------|
| Custom models user guide (`[model.*]`, `api_backend`, default) | `crates/codegen/xai-grok-pager/docs/user-guide/11-custom-models.md` |
| Config reload watches `[model.*]` / `[models]` | `crates/codegen/xai-grok-shell/src/config/reloader.rs` |
| Subagent resolution crate (spawn > role > persona > parent) | `crates/codegen/xai-grok-subagent-resolution/src/lib.rs` |
| Precedence documented on `EffectiveRuntimeConfig` | `crates/codegen/xai-grok-subagent-resolution/src/types.rs` |
| Role/persona `model` + `reasoning_effort` fields | `crates/codegen/xai-grok-subagent-resolution/src/config.rs` |
| Model cascade in overrides | `crates/codegen/xai-grok-subagent-resolution/src/overrides.rs` |
| Subagent TOML: `[subagents.models]`, `[subagents.roles.*.model]` | `crates/codegen/xai-grok-pager/docs/user-guide/16-subagents.md` |
| `api_backend`: chat_completions / responses / messages | `crates/codegen/xai-grok-sampler/src/config.rs`, user-guide §11 |
| Sampler / client backend dispatch | `crates/codegen/xai-grok-sampler/src/client.rs` |

Do **not** claim single-model-only. Do **not** invent a second runtime registry the binary ignores.

## What grok already has

### Registry (`~/.config/doit/config.toml`)

- **Many** `[model.<name>]` sections (not limited to one custom model)
- `[models] default = "..."` selects the default model name
- Per-model fields (see user-guide §11): `model`, `base_url`, `name`, `description`, `api_key` / `env_key`, **`api_backend`** (`chat_completions` | `responses` | `messages`), sampling, `context_window`, `extra_headers`, …
- Compatible with OpenAI-style, Anthropic Messages, and Responses backends depending on `api_backend`

Illustrative TOML (≥2 models):

```toml
[models]
default = "combo-big"

[model.combo-big]
model = "your-large-model-id"
base_url = "https://api.example.com/v1"
api_backend = "chat_completions"
env_key = "EXAMPLE_API_KEY"
name = "Combo Big"
context_window = 200000

[model.combo-small]
model = "your-small-model-id"
base_url = "https://api.example.com/v1"
api_backend = "chat_completions"
env_key = "EXAMPLE_API_KEY"
name = "Combo Small"
context_window = 128000
```

### Resolution order for subagents

From `xai-grok-subagent-resolution` (crate docs + `EffectiveRuntimeConfig`):

1. **Spawn override** — explicit model on the spawn / `task` call  
2. **Role** default model (`[subagents.roles.<name>] model = "..."`, or `.doit/roles/*.toml`)  
3. **Persona** model (`[subagents.personas.<name>]` or `.doit/personas/*.toml`)  
4. **Parent** session model / default (when resolved model is `None` → inherit)

Also available at type level: `[subagents.models] explore = "…"` (per-type model override; see user-guide §16).

Roles and personas can also pin **`reasoning_effort`** (stringly typed today, e.g. `"low"` / `"medium"` / `"high"`).

Agent definitions / skill frontmatter can set `model` (and effort where supported) — same family of pins OpenCode uses on agent files.

### Primary-session role switch and model re-assignment

Product rule (see [prompt-system.md](./prompt-system.md) Role lifecycle, root AGENTS **Role switch lock**):

| When | Role Tab / Shift+Tab | Role→model re-assignment |
|------|----------------------|---------------------------|
| Session start — no user messages yet | Allowed | **Apply** assignment for the newly selected role |
| After first user message or any conversation content | **Disabled** | **Do not** re-pin model via role hop mid-session |

Spawn overrides for subagents are unchanged and independent of primary-session role lock.

### What this means for do

- Keep **reading and writing** stock `~/.config/doit/config.toml` (or `$GROK_HOME/config.toml`) for native multi-model — do not invent a second runtime registry that the binary ignores
- Product work focuses on **ergonomics**, **role assignment policy**, and optional **YAML → TOML / agent frontmatter** mapping

## What OpenCode does better (learn, don’t clone wholesale)

Reference: user `~/.config/opencode/` (e.g. `opencode.jsonc` agent `model` pins, `agent/*.md` frontmatter `model:`, oh-my-opencode-slim agent model table), and pi-ness notes under `~/code/pi-ness` (read-only).

| OpenCode strength | Why users care | do response |
|-------------------|----------------|-------------|
| Provider catalog + model list | Discover and pin models without tribal knowledge | Document registry templates; optional YAML registry that maps to `[model.*]` |
| **Agent definitions with `model`** | Orchestrator vs explorer vs worker each cost/latency appropriate | `assignment:` table in do YAML + agent frontmatter / role model fields |
| Permissions in config | Same file family as agents | Later; guided hooks first (L6); permission YAML optional later |
| Plugins as installable bundles | Optional power without core fork | do-harness + `.doit/plugins` |

User need (product requirements):

1. Multi-model registry that feels as controllable as OpenCode providers + agent model assignment  
2. Assign models like OpenCode: **intake / orchestrator / explorer / worker / oracle** each can pin model (+ reasoning effort when supported)  
3. Learn OpenCode patterns: agent model+permissions, providers, permission rules, plugins — user control via config files  
4. Prefer **YAML** for do product overlays; stock grok stays **TOML**

## do target design

### Dual surface

| Surface | Format | Authority | Milestone |
|---------|--------|-----------|-----------|
| Stock runtime | `~/.config/doit/config.toml` (`$GROK_HOME`) | **Runtime** multi-model + default + subagent roles | CFG home |
| do product | `do-harness/config.models.yaml` | **Policy** registry ergonomics + role assignment | M1 wire |

### Registry schema (YAML)

```yaml
models:
  default: <registry-name>          # maps to [models] default
  registry:
    <name>:
      model: <provider-model-id>    # API model string
      base_url: <url>               # optional for built-ins
      api_backend: chat_completions | responses | messages
      # api_key_env: ENV_VAR_NAME   # never commit secrets
      # name: Display Name
      # context_window: 200000
```

### Assignment schema (YAML)

```yaml
assignment:
  <role>: <registry-name>           # short form
  # or structured (when effort supported):
  # <role>:
  #   model: <registry-name>
  #   effort: low | medium | high
```

**Product roles (minimum roster):** `intake`, `orchestrator`, `explorer`, `worker`, `oracle` — each may pin a different registry name.

| Role / agent | Typical model class | Notes |
|--------------|---------------------|-------|
| `intake` | small / cheap | Routing, clarification |
| `orchestrator` | large / strong | Planning, coordination |
| `explorer` | small / fast | Scout, grep-heavy |
| `worker` | large / strong | Implementation |
| `oracle` | large / strong | Architecture, hard decisions |

### Example YAML (`do-harness/config.models.yaml`)

≥2 models, ≥3 role assignments (template ships with five roles):

```yaml
# do product model overlay — M0 template (not yet auto-applied by binary)
# Maps to ~/.config/doit/config.toml [model.*] + agent/role model fields.
# See docs/models-and-config.md  |  Limitation: L13

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
| `assignment.<role>` (short) | Role `model` / agent frontmatter `model:` for that role under `do-harness/agents/` and/or `[subagents.roles.<role>]` |
| `assignment.<role>.model` + `.effort` | Role/persona `model` + `reasoning_effort` |
| spawn-time override | Unchanged — still wins over role/persona/parent |

**M0:** document + ship template under `do-harness/config.models.yaml`; operators may hand-sync to TOML.  
**M1:** `do-harness/scripts/apply-models.sh` (`--dry-run` / `--validate` / `--apply`) maps `assignment` into `do-harness/agents/*.md` frontmatter; validate exits non-zero on missing registry names.  
**Later:** optional binary-integrated `do models apply`; still no second runtime that bypasses grok.

### Validation principles

- Registry names referenced in `assignment` must exist in `registry` (or known stock models)
- Prefer env var names for secrets — never commit API keys
- English-only keys and comments in repo templates

## Limitation L13 (full statement)

| Field | Content |
|-------|---------|
| **ID** | L13 |
| **pi-ness / OpenCode idea** | Provider catalog + per-agent model pins + permission/config control via files |
| **Stock grok-build** | Multi-model **already works**: many `[model.<name>]`, default, api_backend; subagent resolution spawn > role > persona > parent; roles/personas/agents can set `model` + `reasoning_effort` |
| **Gap** | Assignment **UX** and **role→model policy** weaker than OpenCode; no first-class do product YAML overlay; operators must hand-edit TOML + agent/role files without a single assignment table |
| **Preferred path** | `do-harness` YAML template + agent frontmatter / role model fields; document mapping; M1 wire; avoid crate patch unless agent discovery cannot express model pins |
| **Risk if ignored** | Users under-use multi-model or thrash config; cost/latency wrong for explorer vs oracle; product feels less controllable than OpenCode |
| **Evidence** | See **Evidence (forked tree)** table above; OpenCode contrast via `~/.config/opencode/` agent `model` pins |

Also listed in [architecture.md](./architecture.md) L1–L13 table. Full inventory row with peer limitations: [limitations.md](./limitations.md) (F-DOC-001 deepens L1–L12). Patch path: [patch-matrix.md](./patch-matrix.md).

## Related files

| Path | Role |
|------|------|
| `do-harness/config.models.yaml` | Product template (registry + assignment) |
| `do-harness/scripts/apply-models.sh` | Validate + apply assignment → agent frontmatter |
| `~/.config/doit/config.toml` | Native multi-model runtime |
| `do-harness/agents/*` | Role profiles; receive `model` pins via apply |
| [architecture.md](./architecture.md) | L1–L13 table |
| [limitations.md](./limitations.md) | Evidence inventory including L13 |
| [patch-matrix.md](./patch-matrix.md) | Gap → path / risk / order |
| [related-projects.md](./related-projects.md) | OpenCode / pi-ness pointers |
| Root [AGENTS.md](../AGENTS.md) | Compact models & config control section |

## Auth: custom models / BYOK without forced Grok OAuth (PRIV)

**Status:** F-PRIV-AUTH / VAL-PRIV-AUTH-001. Config-first; crate gate **P-AUTH-01**.

Stock grok pushes interactive **grok.com OAuth** when there is no session token **and** no advertiseable API-key path. Product policy: operators who run **custom `[model.*]` BYOK** (or global API key) must **not** be forced through that OAuth on startup.

### Config-first (preferred; no secrets in repo)

In `~/.config/doit/config.toml`:

```toml
[models]
default = "my-custom"   # name of a [model.*] with env_key or api_key

[model.my-custom]
model = "provider-model-id"
base_url = "https://api.example.com/v1"
api_backend = "chat_completions"
env_key = "MY_PROVIDER_API_KEY"   # prefer env; never commit raw api_key
context_window = 128000

# Optional hard pin: never advertise or auto-mint OIDC / browser login
[auth]
preferred_method = "api_key"
```

| Knob | Effect |
|------|--------|
| `[model.*]` `api_key` / `env_key` | Resolves as BYOK → ACP advertises `xai.api_key` **first** → `startup_auth_metadata` sets `needs_login = false` |
| `XAI_API_KEY` (or legacy `GROK_CODE_XAI_API_KEY`) / auth.json `xai::api_key` | Same non-interactive path as BYOK |
| `[auth] preferred_method = "api_key"` | Fail-closed pin: only API-key family; **no** automatic OIDC mint / browser fallthrough |
| `[auth] preferred_method = "oidc"` | Session only; API-key path hidden (enterprise IdP) |
| unset `preferred_method` | Multi-method fallthrough; BYOK still puts `xai.api_key` first so the login screen is skipped |

**Product assignment (do YAML):** keep secrets out of `do-harness/config.models.yaml` registry template; map registry names via apply-models into agent frontmatter, but put keys only in local `~/.config/doit/config.toml` / env.

### Runtime paths (fork)

| Path | Behavior |
|------|----------|
| `xai-grok-shell` `agent/auth_method.rs` | `should_advertise_xai_api_key`, `build_auth_methods`, **`config_satisfies_api_key_auth`**, **`should_require_interactive_oauth`** |
| `xai-grok-pager` `acp/mod.rs` | `startup_auth_metadata` / `needs_login` from `auth_methods.first()` |
| `xai-grok-pager-bin` `workspace_start` | Skips `ensure_authenticated` when `!should_require_interactive_oauth(cfg)` (**P-AUTH-01**) |

Evidence tests (package `xai-grok-shell`, `auth_method` unit tests): preferred_method pin skips OAuth gate; resolved BYOK `env_key` skips OAuth gate; stock empty config still requires the interactive gate.

Patch log: [patch-matrix.md](./patch-matrix.md) **P-AUTH-01**.

## Non-goals (this page)

- Replacing `config.toml` multi-model with a YAML-only runtime  
- Implementing OpenCode providers wholesale in Rust in M0  
- Multi-provider auth redesign (parked; see [future-plan.md](./future-plan.md))  
- Mid-session primary role hop that re-pins model (forbidden by role switch lock)
- Committing API keys or auth tokens (always env / local home config)
