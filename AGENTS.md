## Project Direction

`doit` (product brand historically **do**) is a forked **Grok Build** coding-agent harness that absorbs **pi-ness** harness-control ideas and **OpenCode-style** multi-model / config control ergonomics.

| Surface | True-now |
|---------|----------|
| **Implementation root** | **`/home/datht/code/doit` only** — sole writable product tree |
| **GitHub origin** | `https://github.com/dathtd119/doit.git` |
| **Upstream remote** | `xai-org/grok-build` (fetch/merge into this tree; never edit the sibling clone in place) |
| Sibling `/home/datht/code/do` | **Deprecated** as a writable product root (stale clone; docs only — do **not** `rm -rf` without user OK) |

Current stance:
- Base = forked grok-build (Rust: pager, shell, tools, agent) under **`/home/datht/code/doit`**
- Ideas source = pi-ness (read-only reference at `~/code/pi-ness`)
- OpenCode learnings = provider catalog + agent model pins + permission config (see `docs/related-projects.md`, `docs/models-and-config.md`)
- Upstream grok-build at `~/code/grok-build` is **read-only**; absorb via **git remote merge** or **COPY** into **`/home/datht/code/doit` only**
- Prefer extension (agents / hooks / plugins / skills / config) before crate patches
- **Inject-first thin fork** (not pure overlay, not deep rewrite) — full thesis: [`FORK.md`](./FORK.md) §1.1
- Full map: [`docs/related-projects.md`](./docs/related-projects.md), [`docs/architecture.md`](./docs/architecture.md), fork hygiene: [`FORK.md`](./FORK.md)

Objective:
- Harness control on a native-rich base: roles, L0–L6 prompt layers, progressive catalogs, guided gates, workspace continuum, continuation
- **Config-first product:** users customize roles, models, tools, skills, permissions, and defaults via files — not crate edits
- **Multi-model registry + role→model assignment** as controllable as OpenCode agents (intake / orchestrator / explorer / worker / oracle each pin model + effort)
- Use grok native tools (`plan`, `update_goal`, hashline, `task`, `lsp`, …) — do not reinvent
- Dual config surface: stock `~/.config/doit/config.toml` (`$GROK_HOME`) for runtime; project **`.doit/`** discovery; **do-harness/** seeds + YAML overlays for product assignment UX

## Architecture (see docs/architecture.md)

Target layout after M0 import:

| Surface | Role | Notes |
|---------|------|--------|
| `crates/` + codegen | Forked grok-build workspace | Binary lineage `xai-grok-pager-bin` |
| `do-harness/` | Product identity | agents, hooks, skills, prompts, `config.models.yaml` |
| `docs/` | Durable design + inventory | architecture, models-and-config, limitations, patch-matrix, … |
| Root `AGENTS.md` | Operating contract + compact living status | This file |
| `CHANGELOGS.md` | What shipped | Append on every milestone |

```
User → doit binary (xai-grok-pager lineage)
         → shell / agent runtime
           → effective config (~/.config/doit + project .doit/ + do-harness seeds)
           → roles / models / tools / skills from config (not hardcoded product defaults)
           → agents / hooks / skills / prompts (discovery + do-harness)
           → session continuum (goal / plan / todo via native tools)
```

**Folder docs:** after import, keep human `README` + agent maps where surfaces change. Maintenance under **Documentation Rules**.

## Inject-first fork stance (binding when changing / syncing)

**Thesis:** inject-first product layer on a **thin fork** — copy pi-ness *discipline* (ordered inject, floors, placement), not pi-ness *topology* (stock binary + TS factories). Full write-up: [`FORK.md`](./FORK.md) §1.1 / §2.1 / §3.1.

| Layer | Path | Merge tax |
|-------|------|-----------|
| **A. Identity** | `do-harness/` (hooks, roles, prompts, YAML, MCP, verify) | **Zero crate** — default home for new features |
| **B. Composition pins** | `crates/codegen/doit` + logged policy paths (PRIV, CFG, role lock, auth) | **Bounded** hotspot allowlist — see FORK §2.1 |
| **C. Deep crate / TUI** | Broad `xai-grok-*` rewrites | **Forbidden** unless seams exhausted + explicit decision |

**True-now shape:** ~3% of `crates/**/*.rs` product-touched; M2/M3 harness features mostly **extension seal**. Upstream pain is real but **concentrated** (paths, package map, pager keybind, PRIV) — not “half the monorepo rewritten.”

**When implementing a feature:**

1. Prefer **do-harness / config / hook / plugin / MCP** first  
2. Use **`register_tool_pack`** only for in-process tools MCP/hooks cannot express  
3. Add a **crate pin** only if extension cannot enforce the policy — log in patch-matrix; prefer expanding the known pin set (FORK §2.2) over new scatter  
4. **Never** grow dual-changed surface for convenience (no third path rebrand; no hard-coding roster/model defaults when TOML/YAML can express them)

**Foreign extensions (true-now):** Claude layout + MCP + grok plugins = **yes**. OpenCode JS plugins / pi-ness ExtensionFactory packages = **no** (different runtime). Details: FORK §3.1.

**Upstream absorb mindset:** re-apply product semantics on the **hotspot allowlist**; take upstream elsewhere. Do **not** “unfork” and drop PRIV/CFG/role-lock to ease merges.

## Hard Constraints

- **Only writable product tree:** `/home/datht/code/doit` — never treat `/home/datht/code/do` as the implementation root
- **NEVER modify** `/home/datht/code/pi-ness` or `/home/datht/code/grok-build` in place — both are **read-only** references (VAL-CROSS-001). Absorb upstream by merge/copy into **doit** only
- **Import / sync** into `/home/datht/code/doit` only (see **Upstream sync checklist** below)
- **Deprecate sibling clone:** `/home/datht/code/do` is stale; document deprecation only — **no `rm -rf`** without explicit user OK
- **Extension-before-deep-fork order** (see Customization Order 1–5)
- **Inject-first thin fork** — new product behavior lands in layer A (`do-harness`) unless proven crate-forced; see **Inject-first fork stance** + [`FORK.md`](./FORK.md) §1.1
- **Freeze crate surface** — do not expand dual-changed paths beyond FORK §2.1 / patch-matrix pins without explicit user OK; no third config-path rebrand after CFG-DOIT
- **Guided blocks (mandatory when gates exist):** tool denied/blocked/gated is incomplete until (1) the gate is named in system/role prompts and (2) the result uses `[GATE: …]` + **Do this instead** (+ human involvement / do-not thrash). Never bare “Permission denied”
- **Config root (CFG-DOIT sealed):** default user home **`~/.config/doit` only** (no silent `~/.grok` or `~/.config/do` fallback); project discovery **`.doit/`**; env override **`GROK_HOME`**; `do-harness/` is the repo source of truth linked/copied onto discovery paths
- **Multi-model is required product behavior** — registry already exists in grok; fill assignment UX + YAML overlay (see L13)
- **No OpenTUI port** in M0–M1 unless reopened
- **English only** for code, docs, commits, configs, errors, tests
- **Conventional commits**; commit **every** milestone; handoff must include `commitId` + `repoPath=/home/datht/code/doit`
- **Preserve Apache-2.0** + `THIRD-PARTY-NOTICES` / LICENSE from import
- Document every crate patch in [`docs/patch-matrix.md`](./docs/patch-matrix.md) — **required on every upstream sync**
- Style: complete-word names; no comments that restate names; comments only for non-obvious trade-offs; don’t touch unrelated code (surface smells separately)
- Do not kill unrelated processes (`pkill`/`killall` by name; no port kills outside mission `services.yaml`)
- **No rust-analyzer / Serena in agent sessions:** do **not** start, invoke, or rely on `rust-analyzer`, Serena MCP (it spawns RA + `cargo check --workspace --all-targets`), or IDE “check on save” / full workspace analysis. Full-workspace RA is too expensive for this monorepo. Prefer `cargo check -p <crate>`, `cargo test -p <crate> --lib`, **codegraph** MCP, and targeted `rg` / file reads. If the user already has an IDE-attached analyzer, leave it alone unless they explicitly ask to stop a known PID (`kill <pid>` only — never `pkill` by name). Do not re-register Serena in MCP configs.
- **Role switch lock:** Tab/Shift+Tab role cycle only when session has no user messages yet. After the first user message (or non-empty conversation), role switching is disabled — keep system/role context clean. Model re-assignment from role only applies when switch is still allowed.

## Upstream sync checklist

**Mandatory** whenever pulling/merging `upstream` (or re-importing from `~/code/grok-build`) into the product tree. Do **not** skip patch-matrix review. Read [`FORK.md`](./FORK.md) §2.1–§2.2 before resolving conflicts.

1. **Work only in** `/home/datht/code/doit`. Never edit `/home/datht/code/pi-ness` or `/home/datht/code/grok-build` in place.
2. **`git fetch upstream`** (remote: `xai-org/grok-build`). Prefer **merge** of `upstream/main` over full-rebase of long product history unless orchestrator says otherwise.
3. **Inventory forked / dual-changed paths** before seal:
   - Read [`docs/patch-matrix.md`](./docs/patch-matrix.md) — every applied / pending crate and product patch row
   - Walk the **hotspot allowlist** in [`FORK.md`](./FORK.md) §2.1 (package `doit`, CFG paths, pager role keybinds, shell PRIV/auth/role_switch, `.doit` discovery strings, telemetry)
   - List dual-changed paths (merge dry-run / conflict map vs upstream tip)
   - Re-verify each forked/patched file still holds product semantics after the merge
4. **Map package path:** upstream `crates/codegen/xai-grok-pager-bin/*` → product **`crates/codegen/doit`** / package **`doit`** (do not resurrect pager-bin as the install package).
5. **Product patches that must survive** (re-check after conflict resolution — FORK §2.2):
   - **P-NOTEL** fail-closed SpaceXAI telemetry (env/remote cannot re-enable)
   - **P-AUTH** BYOK skip forced OAuth at composition-root / `workspace_start`
   - **L1** role switch lock (Tab cycle only pre-message) + role→model re-pin only while unlocked
   - **P-CFG-HOME-DOIT / PROJECT-DOIT** — `~/.config/doit` + project `.doit/` (no silent `~/.grok` / `~/.config/do`)
   - **Package identity** `doit` / `crates/codegen/doit`
   - **P-VERSION** product `VERSION` SoT — do **not** overwrite root `VERSION` / product `doit` package semver with upstream monorepo `0.2.x` lockstep
6. **Conflict default:** hotspot paths → keep **product Fork** semantics; pure monorepo without product markers → take **Upstream**. Do not drop PRIV/CFG/role-lock to “make merge easy.”
7. **Smoke:** `cargo check -p doit` (and `bash do-harness/scripts/verify-install.sh` when install surfaces change). Prefer targeted package checks — not full-workspace RA.
8. **Log the sync** in [`docs/patch-matrix.md`](./docs/patch-matrix.md) (new section or rows for the upstream tip SHA) + append [`CHANGELOGS.md`](./CHANGELOGS.md) when sealing.
9. **Commit** with conventional message; handoff includes `commitId` + `repoPath=/home/datht/code/doit`.

Fork hygiene detail: [`FORK.md`](./FORK.md). Merge playbook: mission architecture / [`docs/architecture.md`](./docs/architecture.md).

## Session / role control

OpenCode-style **Tab / Shift+Tab** role cycling is a product requirement with a hard lifecycle rule:

| Phase | Role cycle (Tab / Shift+Tab) | Model re-resolve from role |
|-------|------------------------------|----------------------------|
| Session start — empty transcript, no user messages | **Allowed** | Yes — switch may apply role→model assignment |
| After first user message **or** any conversation content | **Disabled** | No mid-session hop; keep active role + model stack |

**Why:** Mid-session role hops pollute the system/role prompt stack and mix control contracts in one transcript. Cleaner to pick a role before work starts (or start a new session).

**Implementation:** **Documented in M0** (F-ROLE-001 / VAL-ROLE-001); **implement in M1** (role + prompt layers: session flag, keybind gate, stack freeze, role→model wire). Full TUI polish may lag; the lock policy is binding whenever role cycle UI exists. Details: [`docs/prompt-system.md`](./docs/prompt-system.md) (Role lifecycle + M1 note), [`docs/architecture.md`](./docs/architecture.md).

## Config-driven customization (prefer this over code)

**Product rule:** anything an operator should tune for *their* workflow belongs in config (or do-harness seeds → sync), **not** hard-coded in Rust. Agents implementing features must wire knobs to `config.toml` / harness YAML first; crate constants are last-resort fallbacks only.

### Config roots (CFG-DOIT)

| Layer | Path | Owns |
|-------|------|------|
| **User runtime** | `~/.config/doit/config.toml` (`$GROK_HOME`) | Live settings: roles, models, agent pin, UI, telemetry, tools |
| **Project** | **`.doit/`** | Project agents, hooks, plan, optional project config |
| **Repo seed (SoT)** | `do-harness/` | Product defaults to merge/sync — never the only copy users edit |
| **Env** | `GROK_HOME` | Full replace of user config home |

**Sync (apply seeds → user home):**

```bash
bash do-harness/scripts/sync-user-config.sh --apply   # roles, agent name, agent symlinks, defaults
bash do-harness/scripts/apply-role-contracts.sh --apply  # bridge [roles.*] → agents/*.md frontmatter
bash do-harness/scripts/apply-models.sh --apply       # optional: YAML assignment → frontmatter
```

### What users can customize (no rebuild)

| Need | Config | Seed / docs |
|------|--------|-------------|
| **Cold-start role** | `[roles] default = "worker"` (+ optional `[agent] name`) | `do-harness/config.roles.toml` · chrome + shell both read this |
| **Per-role model / color / tools** | `[roles.<stem>]` `model`, `color`, `tools`, `disallowed_tools`, `permission_mode` | same · D2 contracts |
| **Default model** | `[models] default` + many `[model.<name>]` | `config.models.yaml` + stock TOML |
| **Primary agent pin** | `[agent] name` or `definition` | aligned to `roles.default` by sync |
| **Permission UX default** | `[ui] yolo`, permission mode | `config.defaults.toml` (ask, not always-approve) |
| **Skills progressive vs firehose** | skills / role `discover_skills` | `config.skills.yaml` |
| **Toolset floors** | toolset overlays | `config.toolset.toml` |
| **Hooks / gates** | `.doit/hooks` + do-harness hooks pack | guided-block + continuation |
| **Role mission text** | body-only `prompts/roles/<stem>.md` or agents `*.md` | **no** product config in prompt frontmatter |
| **Telemetry off** | `[features]` / `[telemetry]` | `config.defaults.toml` + P-NOTEL |

Illustrative cold-start (edit `~/.config/doit/config.toml`):

```toml
[roles]
default = "worker"   # intake | orchestrator | explorer | worker | oracle

[agent]
name = "worker"

[roles.worker]
model = "combo-medium"
color = "yellow"
# tools / disallowed_tools / permission_mode — see config.roles.toml

[models]
default = "combo-big"
```

Ensure the agent is discoverable: `~/.config/doit/agents/<stem>.md` or project `.doit/agents/` (sync symlinks the roster). Then restart or `/clear`.

### Resolution order (true-now)

**Primary session agent:**

1. Strict model `agent_type` (codex-class) when applicable  
2. ACP / CLI agent profile  
3. `[agent] name` or `definition`  
4. `GROK_AGENT` env  
5. **`[roles].default`** when discoverable  
6. Stock `grok-build-plan` only if product stem missing  

**Subagent model:** spawn override > role > persona > parent.

**Role cycle (Tab):** only pre-first-message; model re-pin from `[roles.<stem>].model` / agent frontmatter while unlocked.

### Agent implementation rules (config-first)

1. **New user-facing default** → add key under `[roles]` / `[agent]` / `[models]` / harness YAML seed + document here or in `docs/models-and-config.md`. Do **not** bake product stems into pager/shell constants except as fallback after config load fails.
2. **Default role / model pin / tools** already config-driven — extend `RolesConfig` / contracts, not `PRODUCT_ROSTER[0]` hard paths for behavior.
3. Prefer **generate/sync into stock TOML** over inventing a second runtime registry the binary ignores.
4. Prompt bodies stay mission-only; contracts stay in TOML (`docs/prompt-system.md`).

Full design, schema, OpenCode mapping: [`docs/models-and-config.md`](./docs/models-and-config.md).  
Prompt assembly / cold-start: [`docs/prompt-system.md`](./docs/prompt-system.md).

## Native vs Extension vs Crate Patch (ask first)

**Before** a new tool, always-on behavior, or deep fork — **ask** placement. Do not silently choose.

| Placement | When | Where |
|-----------|------|--------|
| **Native tool pack** | Must implement Rust `Tool` trait / in-process tools | `register_tool_pack` / `xai-grok-tools` (or successor crate) |
| **do-harness** | Product identity: agents, hooks, skills, prompts, YAML model assignment | `do-harness/` |
| **Plugin** | Installable optional bundle | `.doit/plugins` / user plugins under `$GROK_HOME` or do-harness packaged as plugin |
| **Crate patch** | Only when extension seams fail | Documented in `docs/patch-matrix.md` |
| **Deep pager/TUI fork** | Last resort UI/runtime change | Avoid until M2+ and only with explicit decision |

### Rules

1. Always ask when adding always-on behavior or promoting config → crate
2. Default if user says “you choose”: identity/safety/roles/model-assignment → **do-harness**; optional → **plugin**; in-process tool → **tool pack**; only then **crate patch**
3. Do not bury long-term product identity only under home-dir overlays without a repo `do-harness/` source of truth
4. Record placement in plan/report when non-trivial
5. Prefer generating or documenting mapping into stock `config.toml` over forking the TOML schema

## Customization Order

When changing behavior, prefer (most user-customizable first):

1. **User / project config** — `~/.config/doit/config.toml`, project `.doit/` (roles, models, agent, UI, plugins)
2. **do-harness seeds** — `config.roles.toml`, `config.models.yaml`, agents, hooks, skills, prompts + apply/sync scripts
3. **`register_tool_pack`** for new native tools
4. **Surgical crate patches** (document in patch-matrix) — only when config cannot express the knob
5. **Deep pager / TUI fork** last

**Anti-pattern:** hard-coding product defaults (default role, model pins, tool allowlists) in Rust when a TOML/YAML key would let operators opt in. Config + discovery first.

**Anti-pattern (fork hygiene):** implementing a new harness feature by editing scattered `xai-grok-*` crates when hooks/MCP/do-harness would work — that **raises** every future upstream absorb cost. Prefer layer A; crate pins only for FORK §2.2-class policy.

**Foreign ext placement:** external capability → **MCP**; Claude-shaped assets → stock compat discovery; installable product bundle → **grok plugin**; do **not** attempt OpenCode JS plugin load or pi factory inject.

Learning sources: [`docs/related-projects.md`](./docs/related-projects.md).  
Limitations L1–L13: [`docs/architecture.md`](./docs/architecture.md) (detail in `docs/limitations.md` after M0 docs; L13 in `docs/models-and-config.md`).  
Fork inject thesis + hotspot allowlist: [`FORK.md`](./FORK.md).

## Gates

### Read (before tool / prompt / extension / crate work)

1. [`docs/index.md`](./docs/index.md) — open matching subsystem docs
2. **Before any crate work** (tool packs, surgical patches, deep fork): read [`docs/grok-build/`](./docs/grok-build/) — at least [README](./docs/grok-build/README.md), [extension-seams](./docs/grok-build/extension-seams.md), [hard-limits](./docs/grok-build/hard-limits.md); use [native-tools](./docs/grok-build/native-tools.md) and [patterns](./docs/grok-build/patterns.md) when adding or choosing tools
3. Minimum: [`docs/architecture.md`](./docs/architecture.md); `docs/patch-matrix.md` and `docs/limitations.md` when relevant; **`docs/models-and-config.md`** for any model/role/config-surface work
4. Subsystem stubs as needed: [`docs/prompt-system.md`](./docs/prompt-system.md), [`docs/workspace.md`](./docs/workspace.md); harness seeds under `do-harness/config*.{toml,yaml}`
5. Read **source** in learning repos before borrowing (pi-ness, OpenCode, grok-build) — cite what you copied; prefer forked tree under `do/crates/` as primary evidence
6. Tool optimization order: extension behavior → tool pack → crate tool contract → prompt guidance

Use scout for maps/seams; ask before major architecture; keep docs current after substantive drift.

### Smoke (after code / import / upstream sync)

```bash
cd /home/datht/code/doit
cargo check -p doit
```

(Legacy package name `xai-grok-pager-bin` may still appear in older docs; product package is **`doit`**.) Targeted packages only unless full workspace is required to fix import breakage.

### Quality

- During iteration: targeted `cargo check` / `cargo test -p <crate>`
- Full workspace only when needed (import breakage, release prep)
- Docs-only milestones: file existence + link consistency; no full cargo required
- Universal ship process: [`docs/milestone-ship-discipline.md`](./docs/milestone-ship-discipline.md)

## Documentation Rules

Keep current:

- `docs/` + [`docs/index.md`](./docs/index.md)
- **`CHANGELOGS.md`** — append on ship (not a second Status essay)
- **`docs/future-plan.md`** — long parking lot; root Future Plan stays short
- **`docs/current-status.md`** — optional expanded status; root AGENTS stays compact
- This file — operating contract + compact living status

After milestone:

1. Update `docs/` for that milestone
2. Append [`CHANGELOGS.md`](./CHANGELOGS.md)
3. Update **Current Status** / **Next steps** in this file if true-now changed
4. Conventional commit for the milestone; handoff includes `commitId`

| Artifact | For |
|----------|-----|
| `docs/*.md` | Durable design / inventory / APIs |
| `CHANGELOGS.md` | What shipped |
| Root AGENTS living | Compact Status + Next steps + short Future Plan |
| `docs/current-status.md` | Expanded narrative status |
| `docs/future-plan.md` | Long parking lot |
| `plans/reports/` | Multi-step evidence, scorecards |

**Never** dump long future backlog into root `AGENTS.md` — park it in `docs/future-plan.md`.

## Living status and backlog

| Where | When |
|-------|------|
| **`CHANGELOGS.md`** | Always append on substantive ship |
| **Current Status** | Only if compact “true *now*” would be wrong (≤ ~15 bullets) |
| **Next steps** | Ordered near-term; remove completed |
| **Future Plan** (this file) | Short active ideas only |
| **`docs/future-plan.md`** | Long parking lot; promote into root Future Plan / Next steps when ready |

## Development Flow

When task is **done** (see also [`docs/milestone-ship-discipline.md`](./docs/milestone-ship-discipline.md)):

1. **Verify** — code: `cargo check -p doit` (or agreed package); docs-only: existence + VAL coverage
2. **Document** — under `docs/`; CHANGELOGS; Next steps / Status if needed
3. **Commit** — conventional `type(scope): subject`; atomic; every milestone; no secrets
4. **Handoff** — include `commitId` + `repoPath=/home/datht/code/doit` (missing = incomplete/fail)

Skip commit only if user says so or no file changes. Working-tree-only “done” without commit is incomplete.

## Current Status

Date: 2026-07-17

**Ship history:** [`CHANGELOGS.md`](./CHANGELOGS.md) · **Expanded status:** [`docs/current-status.md`](./docs/current-status.md) · **Long Future parking lot:** [`docs/future-plan.md`](./docs/future-plan.md) · **Models:** [`docs/models-and-config.md`](./docs/models-and-config.md) · **Fork thesis:** [`FORK.md`](./FORK.md) §1.1

- **Mission** — Factory `mis_e0bdf86b` backlog M1–M3 **complete**; brand mission `mis_89367de7` (M0 ORIGIN → M2 UPSTREAM → M1 CFG-DOIT → **M3 PKG sealed**)
- **M3 PKG packaging** — **sealed** (F-PKG-SHIP / VAL-PKG-004|005): CI/release/binstall → `dathtd119/doit`; README Install no crates.io; `verify-install.sh` BIN+REL+README exit 0 (`2c773fe` / `f0cc688`)
- **CFG-DOIT** — **sealed** (F-CFG-SHIP / VAL-CFG-007|008): user home `~/.config/doit`; project `.doit/`; share `~/.local/share/doit`; MCP `doit-codegraph` (`12ed80c` / `43bb3b2` / `de07cc1`)
- **Upstream merge** — **sealed** (`6cdf160` absorb `8adf901`); product patches survived (PRIV/CFG/role/`doit` package)
- **M3 native power tools** — **sealed** (F-M3-SHIP): CodeGraph MCP explore/impact (`7a55c75`); hashline product default (`ef06622`)
- **M2 continuity & safety** — **sealed** (F-M2-SHIP): continuation + guided-block pack + progressive skills + role floors
- **CFG (historical `~/.config/do` + `.do/`)** — prior seal under `mis_e0bdf86b`; superseded by CFG-DOIT paths above
- **PRIV privacy** — **sealed** (F-PRIV-SHIP): P-NOTEL fail-closed SpaceXAI telemetry; P-AUTH BYOK skip forced OAuth
- **M1 harness control** — **sealed** (F-M1-SHIP): five agents; Tab lock; YAML apply-models; L0–L6 + workspace
- **M0** — fork import, control plane, multi-model L13, inventory, patch-matrix — **sealed**
- **Fork topology (true-now)** — **inject-first thin fork**: layer A `do-harness/` + layer B bounded crate pins (~3% product-touched crates); not pure overlay (no TS factories); not deep monorepo rewrite. Hotspot allowlist + must-survive pins in [`FORK.md`](./FORK.md) §2.1–§2.2
- **Config root (true-now)** — user **`~/.config/doit`** (`$GROK_HOME` override) + project **`.doit/`** + `do-harness/` overlay; dual TOML registry + YAML assignment (no second runtime registry)
- **Config-driven defaults (true-now)** — cold-start role = `[roles].default` (chrome + shell); per-role model/tools/color = `[roles.<stem>]`; stock `grok-build-plan` only if product agent not discoverable. Prefer editing config over hard-coding product stems
- **Product version (true-now)** — root **`VERSION`** (`0.1.0`) is SoT for `doit --version`, GitHub tags `v{VERSION}`, and binstall archives. Upstream monorepo crate lines (e.g. pager/shell `0.2.x`) may differ — absorb must not overwrite product `VERSION` (P-VERSION)
- **Power tools (true-now)** — CodeGraph via MCP **`doit-codegraph`** + `xai-codebase-graph`; product hashline toolset overlay (stock Rust Default remains Standard until TOML merge)
- **Process** — git at **`/home/datht/code/doit`**; commit every milestone; English + conventional commits; handoff needs `commitId` + `repoPath`
- **Worktree (true-now)** — **implementation root = `/home/datht/code/doit` only**. Sibling `/home/datht/code/do` is **deprecated** as writable product root (do not edit; do not delete without user OK). Origin: `dathtd119/doit`. Config **`~/.config/doit`** + project **`.doit/`**; harness folder `do-harness/`; CLI package/binary **`doit`**
- **Origin / upstream (true-now)** — origin `https://github.com/dathtd119/doit.git`; upstream `xai-org/grok-build`. Every upstream absorb follows **Upstream sync checklist** (hotspot allowlist + patch-matrix review mandatory)

### Next steps

1. Finish role-kernel parity plan `260716-2010` (phases 02 body swap, 03 strict TOML tools, 07 verify) — see residual K1–K7 in [`docs/future-plan.md`](./docs/future-plan.md)
2. Promote parking-lot items only when chosen (goal-as-mission from opencode-missions, side-ask dual stream, BM25 skill_search, multi-provider auth, OpenCode permission-rules YAML)
3. Optional: cut first `v0.1.0` GitHub Release (tag must match `VERSION`) for prebuilt binstall assets; proactive first-message role-lock toast; CodeGraph in-process `tool_pack` if MCP friction forces it; remove host deprecation symlinks `~/.config/do` → `doit` when operators ready
4. Optional inject-layer hardening (when chosen): ordered product inject inventory + skip double-load; package do-harness as formal grok plugin; thin composition-root `register_tool_pack` path; config-first `PRODUCT_ROSTER` (reduce crate hardcode)

### Future Plan

_Short list only. Full parking lot: [`docs/future-plan.md`](./docs/future-plan.md). Promote to Next steps when ready._

- Role-kernel finish (role-as-system body + hard tool allowlist + chrome truth) — learning: pi-ness
- Inject inventory SoT (ordered always-on hooks/contracts/MCP like pi-ness factories) + crate surface freeze discipline
- Goal-as-mission full runner (validators + structured handoffs) — learning: opencode-missions + pi-ness goal
- Side-ask dual stream / intake productization — learning: pi-ness side-ask
- Multi-provider auth beyond stock grok paths (deeper redesign; BYOK skip-OAuth already shipped)
- Progressive skill/MCP BM25 `skill_search`/`skill_load` parity with pi-ness
- OpenCode-parity permission rules surface in do YAML (beyond floors + model assignment)
- More product knobs as config (permissions rules, skill firehose per-role, roster order) — avoid new hard-coded tables
- Role-cycle UX polish (proactive first-message toast deferred; no mid-session hop)
- Optional CodeGraph `tool_pack` if MCP latency/install forces it
- Brand follow-ups after P-BRAND-UI (parked): per-provider `system_prompt_label`; install/PATH + home user-guide refresh; optional model/auth/theme display polish — see [`docs/future-plan.md`](./docs/future-plan.md) § Config rebrand

## Non-Goals

- Full OpenTUI / Node port of pi-ness TUI
- Reinventing native tools grok already has (`plan`, `update_goal`, hashline, `task`, `lsp`, …)
- Replacing stock multi-model TOML with a competing registry (overlay + map, don’t fight the base)
- Hard-coding operator-facing defaults in crates when config can express them
- Upstream PRs to xAI grok-build (private/local fork path)
- Speculative abstractions before M0 baseline seals
- Deep pager/TUI fork before extension seams are exhausted
- Unforking to stock unmodified grok while keeping PRIV / CFG-DOIT / role-lock (those require the thin fork)
- Loading OpenCode JS plugins or pi-ness ExtensionFactory packages as native
- Expanding crate dual-change surface for features that fit do-harness / MCP / hooks
