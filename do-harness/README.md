# do-harness

Product identity layer for **do** (forked grok-build): agents, hooks, skills,
prompts, and model-assignment YAML. Source of truth lives **here**; install onto
product discovery paths (`~/.config/doit` user home, project `.doit/`).

See root [`AGENTS.md`](../AGENTS.md) Customization Order and
[`docs/grok-build/extension-seams.md`](../docs/grok-build/extension-seams.md).

## Layout

| Path | Role |
|------|------|
| `agents/` | Product roster agent profiles (`.md` with YAML frontmatter) |
| `prompts/` | **L0/L1 fragments** + named gates (`docs/prompt-system.md` map; F-M1-PROMPT) |
| `hooks/` | PreToolUse guided gates + PostToolUse continuation nudge + scripts |
| `fixtures/continuation/` | Multi-step thrash fixture for VAL-M2-CONT-001 |
| `scripts/verify-continuation.sh` | **F-M2-CONT / VAL-M2-CONT-001** policy + hooks + no-thrash fixture |
| `scripts/verify-gates.sh` | **F-M2-GATES / VAL-M2-GATE-001** guided-block standard + expanded pack |
| `config.models.yaml` | Multi-model registry + role→model assignment (policy overlay) |
| `config.skills.yaml` | **F-M2-SKILL / VAL-M2-SKILL-001** progressive/curated skill + MCP presentation overlay |
| `config.permissions.yaml` | **F-M2-PERM / VAL-M2-PERM-001** role tool allow/deny floors policy (applied in agents/) |
| `scripts/apply-models.sh` | **F-M1-MODEL-APPLY / VAL-M1-MODEL-001** YAML assignment → agent frontmatter |
| `scripts/verify-discovery.sh` | **F-EXT-003** end-to-end discovery path check (intake + guided hook) |
| `scripts/verify-roster.sh` | **F-M1-ROSTER / VAL-M1-ROSTER-001** five-agent roster discovery |
| `scripts/verify-progressive-skills.sh` | **F-M2-SKILL / VAL-M2-SKILL-001** progressive/curated default + MCP search/use |
| `scripts/verify-role-permissions.sh` | **F-M2-PERM / VAL-M2-PERM-001** role floors applied + gate alignment |
| `codegraph/` | **F-M3-CG / VAL-M3-CG-001** MCP server wrapping `xai-codebase-graph` (`mcp_server.py` + example TOML) |
| `scripts/verify-codegraph.sh` | **F-M3-CG / VAL-M3-CG-001** design + fixture explore/impact |
| `fixtures/codegraph/` | Small Rust sample for explore/impact contract |
| `config.toolset.toml` | **F-M3-HASH / VAL-M3-HASH-001** product recommended `[toolset] file_toolset = "hashline"` fragment |
| `scripts/verify-hashline.sh` | **F-M3-HASH / VAL-M3-HASH-001** default policy + agent apply + rollback doc |

## Discovery paths (stock grok)

do-harness files are **not** auto-scanned from `do-harness/`. They must land on
paths the forked binary already walks:

| Asset | Runtime discovery path | Evidence in fork |
|-------|------------------------|------------------|
| Agents | `<project>/.doit/agents/*.md` (cwd → git root), then `~/.config/doit/agents/` | `crates/codegen/xai-grok-agent/src/discovery.rs` (`PROJECT_AGENT_SUBDIRS`) |
| Hooks | `<git-root>/.doit/hooks/*.json`, then `~/.config/doit/hooks/` | `crates/codegen/xai-grok-shell/src/util/hooks.rs` (`discover_hook_source_paths`); load via `xai-grok-hooks` `HookSource::Directory` |

**Install pattern:** symlink from project `.doit/` into `do-harness/` so the
repo is the single source of truth.

## Product roster (M1 — F-M1-ROSTER / VAL-M1-ROSTER-001)

Five primary-session roles under [`agents/`](./agents/). Source of truth is
`do-harness/agents/`; install onto project `.doit/agents/` (symlinks preferred).

| Role | Source | Typical use | Tool floor (F-M2-PERM) |
|------|--------|-------------|------------------------|
| **intake** | [`agents/intake.md`](./agents/intake.md) | Clarify intent; Intent Pack; no implementation | `plan`; read/list/grep; **deny** edits + continuum |
| **orchestrator** | [`agents/orchestrator.md`](./agents/orchestrator.md) | Goal/plan/todo; spawn specialists | continuum + task; **deny** bulk write |
| **explorer** | [`agents/explorer.md`](./agents/explorer.md) | Fast scout / maps / citations | `plan`; read-only + MCP; **deny** edits + continuum |
| **worker** | [`agents/worker.md`](./agents/worker.md) | Implementation + targeted verify | `default`; full edit surface; guided gates still apply |
| **oracle** | [`agents/oracle.md`](./agents/oracle.md) | Architecture / hard decisions | `plan`; analysis + MCP; **deny** edits + continuum |

Policy: [`docs/role-permissions.md`](../docs/role-permissions.md) +
[`config.permissions.yaml`](./config.permissions.yaml).

Model pins: `config.models.yaml` `assignment.<role>` applied into agent
frontmatter via `scripts/apply-models.sh` (**F-M1-MODEL-APPLY** / VAL-M1-MODEL-001).
Stock `~/.config/doit/config.toml` remains the runtime multi-model registry — this
script does **not** invent a second runtime.

Role switch lock (product policy): Tab/Shift+Tab **only pre-message**; locked
after first user message — see root `AGENTS.md` / `docs/prompt-system.md`.

### Prompt fragments (F-M1-PROMPT / VAL-M1-PROMPT-001)

| Path | Layer |
|------|-------|
| [`prompts/l0-kernel.md`](./prompts/l0-kernel.md) | L0 identity + guided-gate + role-lock rules |
| [`prompts/gates.md`](./prompts/gates.md) | Named `[GATE: …]` catalog |
| [`prompts/roles/*.md`](./prompts/roles/) | L1 role contracts (aligned with agents) |

Full inject map and budgets: [`docs/prompt-system.md`](../docs/prompt-system.md).  
Continuum disk contract: [`docs/workspace.md`](../docs/workspace.md).

### Verify roster

```sh
bash do-harness/scripts/verify-roster.sh
# expect: exit 0 and "VAL-M1-ROSTER-001: PASS"
```

## Proof assets (M0)

### Intake agent (F-EXT-001 / VAL-EXT-001)

- Source: [`agents/intake.md`](./agents/intake.md)
- Discovery: `.doit/agents/intake.md` → symlink to source
- Role: clarify-only intake; `permissionMode: plan`; no file edits
- **M1:** intake remains part of the five-role product roster (above)

### Guided dangerous-shell hook (F-EXT-002 / VAL-EXT-002)

- Source: [`hooks/guided-dangerous-shell.json`](./hooks/guided-dangerous-shell.json)
  + [`hooks/bin/guided-dangerous-shell.py`](./hooks/bin/guided-dangerous-shell.py)
- Discovery: `.doit/hooks/*` → symlinks to source
- Behavior: PreToolUse on shell tools; deny dangerous patterns with
  `[GATE: …]` + **Do this instead** (never bare “Permission denied”)
- Enablement detail: [`hooks/README.md`](./hooks/README.md)

### Continuation priority nudge (F-M2-CONT / VAL-M2-CONT-001)

- Policy: [`docs/continuation.md`](../docs/continuation.md)
- Source: [`hooks/continuation-nudge.json`](./hooks/continuation-nudge.json)
  + [`hooks/bin/continuation-nudge.py`](./hooks/bin/continuation-nudge.py)
- Behavior: PostToolUse on `update_goal` / plan mode / `todo_write` / `task`;
  re-surfaces highest open lane (interrupt→streak→goal→plan→workflow→todo)
  with cooldown anti-thrash (no full continuum dump)
- Verify: `bash do-harness/scripts/verify-continuation.sh`
- Enablement: [`hooks/README.md`](./hooks/README.md)

### Guided-block product pack (F-M2-GATES / VAL-M2-GATE-001)

- Standard: [`prompts/gates.md`](./prompts/gates.md) + L0/role prompt naming
- Shared helper: [`hooks/bin/guided_block.py`](./hooks/bin/guided_block.py)
- Packs beyond M0 dangerous-shell:
  - **path-policy** — [`hooks/guided-path-policy.json`](./hooks/guided-path-policy.json)
    + [`hooks/bin/guided-path-policy.py`](./hooks/bin/guided-path-policy.py)
    (`path-policy-write-outside`)
  - **env-expose** — [`hooks/guided-env-expose.json`](./hooks/guided-env-expose.json)
    + [`hooks/bin/guided-env-expose.py`](./hooks/bin/guided-env-expose.py)
    (`env-expose-dotenv`, `env-expose-printenv`, `env-expose-secret-echo`)
- Behavior: PreToolUse denials always use `[GATE: …]` + **Do this instead**
  (never bare “Permission denied”)
- Verify: `bash do-harness/scripts/verify-gates.sh`
- Enablement detail: [`hooks/README.md`](./hooks/README.md)

## Enable (project-scoped — recommended)

From the **do** repo root:

```sh
# Full product roster (M1)
mkdir -p .doit/agents
for role in intake orchestrator explorer worker oracle; do
  ln -sfn ../../do-harness/agents/${role}.md .doit/agents/${role}.md
done

# Hooks (M0 guided shell + M2 continuation + M2 path-policy + env-expose)
mkdir -p .doit/hooks/bin
ln -sfn ../../do-harness/hooks/guided-dangerous-shell.json \
  .doit/hooks/guided-dangerous-shell.json
ln -sfn ../../../do-harness/hooks/bin/guided-dangerous-shell.py \
  .doit/hooks/bin/guided-dangerous-shell.py
ln -sfn ../../do-harness/hooks/continuation-nudge.json \
  .doit/hooks/continuation-nudge.json
ln -sfn ../../../do-harness/hooks/bin/continuation-nudge.py \
  .doit/hooks/bin/continuation-nudge.py
ln -sfn ../../do-harness/hooks/guided-path-policy.json \
  .doit/hooks/guided-path-policy.json
ln -sfn ../../../do-harness/hooks/bin/guided-path-policy.py \
  .doit/hooks/bin/guided-path-policy.py
ln -sfn ../../do-harness/hooks/guided-env-expose.json \
  .doit/hooks/guided-env-expose.json
ln -sfn ../../../do-harness/hooks/bin/guided-env-expose.py \
  .doit/hooks/bin/guided-env-expose.py
ln -sfn ../../../do-harness/hooks/bin/guided_block.py \
  .doit/hooks/bin/guided_block.py
chmod +x do-harness/hooks/bin/guided-dangerous-shell.py
chmod +x do-harness/hooks/bin/continuation-nudge.py
chmod +x do-harness/hooks/bin/guided-path-policy.py
chmod +x do-harness/hooks/bin/guided-env-expose.py
```

Project hooks may require `/hooks-trust` in a live session (stock grok).

### Enable (user-global)

```sh
mkdir -p ~/.config/doit/agents ~/.config/doit/hooks/bin
for role in intake orchestrator explorer worker oracle; do
  cp do-harness/agents/${role}.md ~/.config/doit/agents/
done
cp do-harness/hooks/guided-dangerous-shell.json ~/.config/doit/hooks/
cp do-harness/hooks/bin/guided-dangerous-shell.py ~/.config/doit/hooks/bin/
cp do-harness/hooks/continuation-nudge.json ~/.config/doit/hooks/
cp do-harness/hooks/bin/continuation-nudge.py ~/.config/doit/hooks/bin/
cp do-harness/hooks/guided-path-policy.json ~/.config/doit/hooks/
cp do-harness/hooks/bin/guided-path-policy.py ~/.config/doit/hooks/bin/
cp do-harness/hooks/guided-env-expose.json ~/.config/doit/hooks/
cp do-harness/hooks/bin/guided-env-expose.py ~/.config/doit/hooks/bin/
cp do-harness/hooks/bin/guided_block.py ~/.config/doit/hooks/bin/
chmod +x ~/.config/doit/hooks/bin/guided-dangerous-shell.py
chmod +x ~/.config/doit/hooks/bin/continuation-nudge.py
chmod +x ~/.config/doit/hooks/bin/guided-path-policy.py
chmod +x ~/.config/doit/hooks/bin/guided-env-expose.py
```

## Verify discovery (F-EXT-003 / VAL-EXT-003)

VAL-EXT-003 accepts either (a) headless/CLI listing on the forked binary, or
(b) a **scripted** check that exits 0 confirming assets sit on the real
discovery path. Mocks alone are insufficient.

### Primary: scripted discovery path check (b)

```sh
# From do repo root (or any cwd — script resolves paths)
bash do-harness/scripts/verify-discovery.sh
# expect: exit 0 and "VAL-EXT-003: PASS"
```

What the script proves:

1. Source files exist under `do-harness/`
2. Project `.doit/agents/intake.md` and `.doit/hooks/…` exist and resolve to source
3. Agent frontmatter matches grok agent conventions (`name: intake`, …)
4. Hook JSON has `PreToolUse` + shell matcher + `type: command` handler
5. Hook command target exists under the hook `source_dir`
6. Guided deny/allow self-test passes (`[GATE: …]` shape)
7. Forked source still documents `.doit/agents` and `.doit/hooks` as discovery paths

Optional override:

```sh
DO_REPO_ROOT=/path/to/do bash do-harness/scripts/verify-discovery.sh
```

### Optional: forked binary inspect (a)

If you have a built pager/agent binary with `inspect`:

```sh
cargo build -p doit   # when you need a binary
# then, from do root (exact CLI flag may vary by build):
#   target/debug/<binary> inspect --json
# Expect agents[] to include name "intake" and hooks to include PreToolUse /
# guided-dangerous-shell when project trust allows project hooks.
```

The verify script runs this automatically when a built binary is found; path
checks remain the authoritative M0 proof when no binary is present.

### Hook contract only (no discovery)

```sh
python3 do-harness/hooks/bin/guided-dangerous-shell.py --self-test
```

## Model assignment apply (F-M1-MODEL-APPLY / VAL-M1-MODEL-001)

Policy file: [`config.models.yaml`](./config.models.yaml) — registry ergonomics
+ role→model table. Runtime multi-model still lives in stock
`~/.config/doit/config.toml` (`[model.*]` + default). The apply script maps
`assignment.<role>` into `agents/<role>.md` frontmatter `model:` (and optional
`effort:` for structured pins). See
[`docs/models-and-config.md`](../docs/models-and-config.md).

### Commands

```sh
# Dry-run: print role → registry map (default; no writes)
bash do-harness/scripts/apply-models.sh
# or: python3 do-harness/scripts/apply-models.py

# Validate: exit non-zero on missing registry names / broken assignment
bash do-harness/scripts/apply-models.sh --validate
# expect: exit 0 and "validate: PASS" for the stock template

# Apply: write model pins into do-harness/agents/*.md frontmatter
bash do-harness/scripts/apply-models.sh --apply
```

Optional flags (Python script):

| Flag | Effect |
|------|--------|
| `--config PATH` | Alternate YAML (default: `do-harness/config.models.yaml`) |
| `--agents-dir PATH` | Alternate agent directory |
| `--allow-partial-roster` | Skip requiring all five product roles |

**Validate fails when** (exit 1):

- `assignment.<role>` names a model not in `models.registry`
- `models.default` is not in the registry
- Product roster roles are missing from `assignment` (unless partial allowed)
- Assigned role has no agent file under `agents/`

**Does not:** rewrite `~/.config/doit/config.toml`, invent a second runtime registry,
or re-pin mid-session (role lock is F-M1-LOCK / F-M1-MODEL-RESOLVE).

### After editing assignment

1. Ensure registry names exist in both YAML and stock TOML (hand-sync TOML).
2. `bash do-harness/scripts/apply-models.sh --validate`
3. `bash do-harness/scripts/apply-models.sh --apply`
4. Agents under `.doit/agents/` already symlink to `do-harness/agents/` — no
   re-link required for project install.

## Continuation priority (F-M2-CONT / VAL-M2-CONT-001)

```sh
bash do-harness/scripts/verify-continuation.sh
# expect: exit 0 and "VAL-M2-CONT-001: PASS"
```

Also:

```sh
python3 do-harness/hooks/bin/continuation-nudge.py --self-test
python3 do-harness/hooks/bin/continuation-nudge.py \
  --fixture do-harness/fixtures/continuation/multi-step-thrash.json
```

## Guided gates pack (F-M2-GATES / VAL-M2-GATE-001)

```sh
bash do-harness/scripts/verify-gates.sh
# expect: exit 0 and "VAL-M2-GATE-001: PASS"
```

Also:

```sh
python3 do-harness/hooks/bin/guided-path-policy.py --self-test
python3 do-harness/hooks/bin/guided-env-expose.py --self-test
python3 do-harness/hooks/bin/guided-dangerous-shell.py --self-test
```

## Role tool floors (F-M2-PERM / VAL-M2-PERM-001)

Policy: [`docs/role-permissions.md`](../docs/role-permissions.md)  
Overlay: [`config.permissions.yaml`](./config.permissions.yaml)  
Applied: each `agents/<role>.md` frontmatter (`tools`, `disallowedTools`, `permissionMode`)

| Layer | Surface | Shape |
|-------|---------|-------|
| **A — Floors** | agent allow/deny lists | Capability envelope (stock tool visibility) |
| **B — Gates** | PreToolUse guided hooks | `[GATE: …]` + **Do this instead** inside allowed tools |

All five roster roles carry explicit floors. Non-implementers deny the edit surface;
continuum ownership stays on orchestrator/worker. Guided families (`dangerous-shell-*`,
`path-policy-*`, `env-expose-*`) are named in every role prompt.

### Verify role floors

```sh
bash do-harness/scripts/verify-role-permissions.sh
# expect: exit 0 and "VAL-M2-PERM-001: PASS"
```

## Progressive skills / MCP (F-M2-SKILL / VAL-M2-SKILL-001)

Policy: [`docs/progressive-skills.md`](../docs/progressive-skills.md)  
Overlay: [`config.skills.yaml`](./config.skills.yaml)

Stock agents default to `discoverSkills: true` (full CWD skill discovery +
listing seed = **firehose**). Product roster **default** is progressive or
heavily curated for **all five** roles. Firehose is **opt-in only**.

| Role | `discoverSkills` | Mode | Notes |
|------|------------------|------|-------|
| intake | **false** | progressive | no bulk dump |
| explorer | **false** | progressive | MCP `search_tool` / `use_tool` on floor |
| oracle | **false** | progressive | MCP `search_tool` / `use_tool` on floor |
| orchestrator | **false** | curated | empty `skills: []` until operators name workflows |
| worker | **false** | curated | empty `skills: []` until operators name project skills |

Operator ignore/disabled lists still merge into stock `~/.config/doit/config.toml`
`[skills]` (see config overlay `recommended_toml`).

**MCP:** keep stock progressive discovery — **`search_tool`** then **`use_tool`**.
Do not invent a do-harness MCP client or dump every schema every turn.

**Firehose opt-in:** set a role’s `discoverSkills: true` (and optional broad
`[skills] paths`) only for debug; reinstall agents; revert for product demos.
See `presentation.firehose_mode: opt_in` and `firehose_opt_in` in the overlay.

### Verify progressive skills

```sh
bash do-harness/scripts/verify-progressive-skills.sh
# expect: exit 0 and "VAL-M2-SKILL-001: PASS"
```

## Hashline default edit policy (F-M3-HASH / VAL-M3-HASH-001)

Policy: [`docs/hashline.md`](../docs/hashline.md)  
Overlay fragment: [`config.toolset.toml`](./config.toolset.toml)

Product **default** prefers native **GrokBuildHashline** (`file_toolset = "hashline"`)
over Standard. Stock Rust `FileToolset` Default remains Standard until operators
merge the fragment into `~/.config/doit/config.toml` or project `.doit/config.toml`.
**Does not reinvent** hashline grammar — only stock scheme knobs.

| Surface | Product choice |
|---------|----------------|
| Session toolset | `config.toolset.toml` → `file_toolset = "hashline"` |
| Worker | Prefer `hashline_read` / `hashline_edit` / `hashline_grep` |
| Orchestrator | Deny `hashline_edit` (hand edits to worker) |
| Rollback | Set `file_toolset = "standard"` (or remove key) and restart session |

### Enable toolset (operator)

```sh
# Merge [toolset] from do-harness/config.toolset.toml into your config.toml, e.g.:
#   ~/.config/doit/config.toml
#   or <project>/.doit/config.toml
#
# Minimal:
# [toolset]
# file_toolset = "hashline"
```

### Verify hashline policy

```sh
bash do-harness/scripts/verify-hashline.sh
# expect: exit 0 and "VAL-M3-HASH-001: PASS"
```

## Non-goals

- Auto-applying YAML inside the binary on every session start (harness script
  + operator run; optional later `do models apply` CLI)
- Tab cycle + post-message lock implementation (M1 crate/session; not this script)
- Deep crate patches for skill prompt builder (extension path is enough for M2)
- OpenCode-parity path/permission rules surface in do YAML (parking lot; floors + guided gates seal M2)
- BM25 skill_search / skill_load product tools (future optional; stock progressive/curated is the M2 seal)
- Doom-loop circuit breaker as a third M2 pack (path-policy + env-expose satisfy ≥2; doom-loop optional later)
- Changing stock Rust `FileToolset` Default inside the crate (product default is config overlay; M3-H no crate patch)
- Reinventing hashline grammar / dual Standard+Hashline concurrent file toolsets
