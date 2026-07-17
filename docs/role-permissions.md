# Role tool permission floors (L1 / L3) — M2 product

**Status:** M2 **product floors** (F-M2-PERM / VAL-M2-PERM-001 / M2-P01).  
**Related:** [prompt-system.md](./prompt-system.md) (L1/L3), [progressive-skills.md](./progressive-skills.md),
[continuation.md](./continuation.md), gate catalog `do-harness/prompts/gates.md`.  
**Product surfaces:** `do-harness/agents/*.md` frontmatter +
[`do-harness/config.permissions.yaml`](../do-harness/config.permissions.yaml).

## Intent

Each primary-session role has an **allow/deny tool floor** so capability matches
mission (clarify vs coordinate vs implement). Floors are **applied** in agent
YAML frontmatter (`tools`, `disallowedTools`, `permissionMode`) that stock grok
already enforces — **do not invent a second permission engine**.

Guided PreToolUse gates (F-M2-GATES) sit **on top** of floors: even when shell
or write is allowed, dangerous patterns still get `[GATE: …]` + **Do this instead**.

## Two-layer model

| Layer | Surface | What it does | Failure shape |
|-------|---------|--------------|---------------|
| **A — Role floors** | Agent frontmatter `tools` / `disallowedTools` / `permissionMode` | Capability envelope per role (which tools exist for the model) | Tool absent / stock deny (not a product guided-block) |
| **B — Guided gates** | `do-harness/hooks/guided-*.json` PreToolUse | Pattern policy inside allowed tools (shell, path, env) | **`[GATE: <id>]` + Do this instead** (product standard) |

**Rules:**

1. Floors **deny by construction** (e.g. intake never sees `write`).  
2. Gates **guide when capability exists** (e.g. worker has shell → still blocked on `sudo rm`).  
3. Do-owned denials use guided shape; stock floor denials may stay terse.  
4. Path-policy targets **writes outside cwd**; pure read roles still keep
   edit tools on `disallowedTools` so they do not attempt writes.

## Stock seams (fork evidence)

| Field | Meaning | Source |
|-------|---------|--------|
| `tools: […]` | Allowlist. Omit = inherit all. `[]` = none | `xai-grok-agent` AgentDefinition |
| `disallowedTools: […]` | Denylist; **takes priority** over allowlist | same |
| `permissionMode` | `default` \| `plan` \| `acceptEdits` \| `dontAsk` | same |
| PreToolUse hooks | Pattern denials / guided blocks | `.doit/hooks` + `xai-grok-hooks` |

Schema: `crates/codegen/xai-grok-agent/README.md` frontmatter table.

## Role floors (product roster)

Canonical machine-readable copy:
[`do-harness/config.permissions.yaml`](../do-harness/config.permissions.yaml).  
Applied frontmatter: `do-harness/agents/<role>.md` (install to `.doit/agents/`).

| Role | Mode | Intent | Allow (summary) | Deny floor (summary) |
|------|------|--------|-----------------|----------------------|
| **intake** | `plan` | Clarify only | read/list/grep, light shell, ask user, `Agent(explore)` | edit/write/hashline_edit; continuum (`update_goal`, plan mode, `todo_write`) |
| **orchestrator** | `default` | Coordinate continuum + spawn | read tools, shell, ask, `update_goal` / plan / `todo_write` / `task`, spawn explore/worker/oracle/intake | bulk edit (`write`, `search_replace`, `hashline_edit`) |
| **explorer** | `plan` | Read-only scout | read/list/grep/lsp, light shell, MCP `search_tool`/`use_tool` | edit/write/hashline_edit; continuum; spawn worker/oracle/orchestrator |
| **worker** | `default` | Implement + verify | full read/edit (prefer **search_replace** / **write** under product `file_toolset=standard`; see [hashline.md](./hashline.md)), shell, lsp, `todo_write`/`update_goal`, spawn explore | spawn `Agent(oracle)` / `Agent(orchestrator)`; media tools |
| **oracle** | `plan` | Decide with evidence | read/lsp/shell/ask, MCP search/use, spawn explore | edit/write/hashline_edit; continuum ownership; spawn worker/orchestrator |

### Must-deny families (alignment checks)

Verify script asserts these **deny floors** stay present (defense in depth even
when allowlists already omit them):

| Family | Roles that must deny | Why |
|--------|----------------------|-----|
| **Edit surface** (`search_replace`, `write`, `hashline_edit`) | intake, explorer, oracle, orchestrator | Only **worker** implements bulk edits |
| **Continuum ownership** (`update_goal`, plan enter/exit, `todo_write`) | intake, explorer, oracle | Clarify/scout/decide — not session continuum owners |
| **Re-parent spawns** (`Agent(orchestrator)`, `Agent(oracle)` as needed) | explorer, worker, oracle (partial) | Avoid role thrash; escalate via summary |

### Guided gate alignment (all five roles)

Every role prompt and agent body names the product gate **families**. Shell stays
on most floors for light status, so Layer B still applies:

| Gate family | Applies when | Floor relationship |
|-------------|--------------|--------------------|
| `dangerous-shell-*` | Shell tool used | Floors allow light shell; gates block destructive patterns |
| `path-policy-*` | Write/edit tools or shell redirects outside cwd | Read-only floors remove edit tools; workers still gated on out-of-tree writes |
| `env-expose-*` | Shell dumping secrets / full env | Floors do not grant “safe shell forever”; gates teach safer alternatives |

Catalog + shape: [`do-harness/prompts/gates.md`](../do-harness/prompts/gates.md).  
Verify gates pack: `bash do-harness/scripts/verify-gates.sh`.

## Operator changes

1. Edit floors in **`do-harness/agents/<role>.md`** frontmatter (source of truth).  
2. Keep **`do-harness/config.permissions.yaml`** in sync (policy table + verify).  
3. Re-link/install agents to `.doit/agents/` if not already symlinked.  
4. Run:

```sh
bash do-harness/scripts/verify-role-permissions.sh
# expect: exit 0 and "VAL-M2-PERM-001: PASS"
```

Do **not** maintain a parallel OpenCode-style permission-rules YAML runtime in
M2 — that remains a parking-lot item after floors + guided gates.

## File toolset + hashline (M3; policy flip 2026-07-16)

Product default is **standard** file tools (`file_toolset = "standard"` via
`do-harness/config.toolset.toml`). Workers prefer `search_replace` / `write`.
Hashline (`file_toolset = "hashline"`) is **opt-in**; floors still apply: only
**worker** holds the full edit surface. Media tools (`image_gen` / `image_edit` /
`image_to_video` / `reference_to_video`) are denied on every product role.
Policy + rollback: [hashline.md](./hashline.md). Verify:
`bash do-harness/scripts/verify-hashline.sh`.

## Non-goals (M2)

- Second permission engine or OpenCode-parity path rules surface in do YAML  
- Replacing stock `permissionMode` semantics  
- Making stock floor denials print guided-block prose (hooks own guided shape)  
- Doom-loop circuit breaker (optional later pack)

## Evidence

| Check | Command / path |
|-------|----------------|
| Floors documented | this file + `config.permissions.yaml` |
| Floors applied | five `do-harness/agents/*.md` frontmatter blocks |
| Aligned with gates | gate families in agent/role prompts; `verify-gates.sh` |
| Contract | `bash do-harness/scripts/verify-role-permissions.sh` → VAL-M2-PERM-001 |
