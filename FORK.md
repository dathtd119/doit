# Fork policy: doit

**Status:** M0 sealed (F-DOC-004 / VAL-DOC-004). **CFG-DOIT sealed** (F-CFG-SHIP) — user home `~/.config/doit` + project `.doit/`. **ORIGIN** — GitHub `dathtd119/doit`; implementation root `/home/datht/code/doit`.  
**Product:** **doit** (historical brand **do**) — private/local fork of Grok Build with pi-ness harness-control ideas and OpenCode-style model assignment UX.

This file is the **fork hygiene and identity** contract. Operating rules for agents live in [AGENTS.md](./AGENTS.md) (includes **Upstream sync checklist**). Multi-model design: [docs/models-and-config.md](./docs/models-and-config.md). Hard limits: [docs/grok-build/hard-limits.md](./docs/grok-build/hard-limits.md).

---

## 1. What doit is

| Claim | Truth |
|-------|--------|
| Base | Forked **Grok Build** (Rust: pager, shell, tools, agent) under **`/home/datht/code/doit`** |
| Ideas | **pi-ness** harness control (roles, L0–L6, guided gates, continuum) — reference only |
| Config ergonomics | **OpenCode-style** role→model assignment — product YAML overlay, not a second runtime |
| Binary / package | Product install package **`doit`** (upstream lineage `xai-grok-pager-bin`; maps to `crates/codegen/doit`) |
| GitHub | `https://github.com/dathtd119/doit.git` |
| Contribution path | **Private/local fork** — not “open external PRs to xAI grok-build” |

**doit** is not a pure overlay on Pi, and not a Node/OpenTUI port. It owns a forked Rust tree plus a product layer (`do-harness/`) that prefers extension seams before crate patches.

### 1.1 Topology thesis (inject-first on a thin fork)

| Model | What it is | Applies to doit? |
|-------|------------|------------------|
| **pi-ness** | Stock pi (npm dep) + ordered `NATIVE_HARNESS_EXTENSION_FACTORIES` + agent overlay + ~3 thin dist patches | **Discipline to copy** — not the topology |
| **doit true-now** | Full git fork of grok-build + `do-harness/` identity + surgical crate pins | **Yes** — hybrid |
| **Pure external inject only** | Unmodified stock binary + external layer only | **No** — grok has no TS ExtensionFactory inject (L3); PRIV/CFG/role-lock need crate pins |

**Binding product thesis:** *inject-first product layer on a thin fork* — not “edit half the monorepo,” not “unfork to pure overlay.”

```
User
  → doit binary (composition root — minimal product pins)
       → config: ~/.config/doit + project .doit/ + do-harness seeds
       → product identity via discovery: hooks, roles, prompts, skills, MCP, plugins
       → optional register_tool_pack (only when MCP/hooks cannot express)
       → surgical crate patches ONLY when seams fail (PRIV / CFG / role lock / auth / package)
```

| Layer | Owns | Upstream merge cost |
|-------|------|---------------------|
| **A. Identity (`do-harness/`)** | Roles, hooks, prompts, YAML overlays, MCP wrappers, verify scripts | **None** (no crate) |
| **B. Composition root** | Package `doit`, default paths, fail-closed privacy, role-switch lock, BYOK start gate | **Bounded** — fixed hotspot allowlist |
| **C. Deep crate / TUI** | Anything beyond A+B | **High** — avoid; last resort |

**Shape of the fork (evidence):** product markers touch ~3% of `crates/**/*.rs`; most shipped harness behavior (M2 gates/skills/continuation, M3 CodeGraph/hashline config) is **extension seal**. Crate work is **shallow-wide** (path rebrand + policy pins), not a second product runtime.

**Copy from pi-ness (discipline, not TS code):**

1. Ordered always-on **inject inventory** (hooks / contracts / skills / MCP) + explicit load order  
2. **Skip / no double-load** when product native and user overlay share a feature  
3. Role **deny floors win** over user unlock attempts  
4. Guided blocks as identity (`[GATE:…]` + **Do this instead**)  
5. Placement ask-first (do-harness → plugin → tool pack → crate → deep TUI)  
6. Rare, marked base mutations — for us: **patch-matrix crate log**, not silent dist hacks  

**Do not copy:** “never fork the base” topology; OpenTUI shell; npm ExtensionFactory factories 1:1.

---

## 2. Source trees (never modify references in place)

| Path | Role | Access |
|------|------|--------|
| `/home/datht/code/doit` | **Implementation root** — product fork + do-harness + docs | **Writable** — **only** tree we change |
| `/home/datht/code/grok-build` | Upstream mirror / import source | **Read-only** — never edit in place (VAL-CROSS-001) |
| `/home/datht/code/pi-ness` | Ideas / harness thesis reference | **Read-only** — never edit in place (VAL-CROSS-001) |
| `/home/datht/code/do` | Stale sibling clone (historical path) | **Deprecated** — not a writable product root; **do not** `rm -rf` without user OK |

**Import / absorb rule:** merge `upstream` (or copy from local grok-build) **into `/home/datht/code/doit` only**. Do not symlink live mutation into the sibling trees. Preserve Apache-2.0, `LICENSE`, and `THIRD-PARTY-NOTICES` on every import refresh.

### Upstream sync (mandatory)

Every upstream update **must** follow the **Upstream sync checklist** in [AGENTS.md](./AGENTS.md), including:

1. Work only in `/home/datht/code/doit`  
2. `git fetch upstream`  
3. **Inventory forked / dual-changed paths** via [docs/patch-matrix.md](./docs/patch-matrix.md) + merge conflict map — re-verify each product patch  
4. Map `xai-grok-pager-bin` → package **`doit`** / `crates/codegen/doit`  
5. Smoke: `cargo check -p doit`  
6. Log the sync in patch-matrix (+ CHANGELOGS on seal)  
7. Never edit `~/code/pi-ness` or `~/code/grok-build` in place

### 2.1 Dual-changed hotspot allowlist (expect conflict; re-verify)

These paths are the **bounded** merge tax of the thin fork. Prefer **Fork** (keep product semantics) when they collide with upstream; do not expand this list casually.

| Band | Paths / themes | Product semantics that must survive |
|------|----------------|-------------------------------------|
| **High** | `crates/codegen/doit/*`, root `VERSION`, `Cargo.lock`, root `README.md` | Package/binary **`doit`** (map from `xai-grok-pager-bin`); product **VERSION** SoT (not upstream 0.2.x lockstep); no resurrect pager-bin install |
| **High** | `xai-grok-config` `paths.rs` (+ loader/managed_cache as needed) | Default user home **`~/.config/doit` only** (P-CFG-HOME-DOIT); no silent `~/.grok` / `~/.config/do` |
| **High** | `xai-grok-pager` dispatch / modes / agent_view / role keybinds | Tab/Shift+Tab role cycle + **post-first-message lock** |
| **Medium** | `xai-grok-shell` `agent/config.rs`, `auth_method.rs`, `session/role_switch*`, `product_role*` | PRIV resolve hard-off; BYOK skip forced OAuth; L1 session flag |
| **Medium-wide** | Discovery string roots (agent, shell hooks, workspace, tools skills/plan, sandbox, pager modals, fixtures) | Project **`.doit/`** (P-CFG-PROJECT-DOIT) |
| **Medium** | `xai-grok-telemetry`, `xai-mixpanel`, shell feedback/trace helpers | P-NOTEL fail-closed SpaceXAI telemetry (env/remote cannot re-enable) |
| **Lower** | Monorepo crates without product markers | Prefer **Upstream** auto-merge |

**Do not** start a third path rebrand (`doit` → something else) without explicit user decision — CFG string sweep is the noisiest dual-change class.

Full conflict history example: patch-matrix **Upstream sync — `8adf901`**.

### 2.2 Product crate pins that must survive every absorb

| ID / theme | Why extension cannot replace it |
|------------|----------------------------------|
| **P-NOTEL-01..06** | Config opt-out is re-enableable via env/remote; product policy is hard-off |
| **P-AUTH-01** | Composition-root / `workspace_start` gate before login — hooks cannot intercept |
| **P-CFG-HOME-DOIT / PROJECT-DOIT** | Hardcoded default resolvers + discovery roots |
| **L1 / L13 role lock + re-pin** | Keybind + turn_count + sampling re-pin live in pager/shell |
| **Package `doit`** | Install identity is the composition root |
| **P-VERSION** | Product semver is root `VERSION` (+ `doit`/`xai-grok-version` package lines); do not adopt upstream monorepo `0.2.x` lockstep for product releases |

Anything **not** in this table defaults to **do-harness / config / hook / plugin / MCP** — not a new crate pin.

---

## 3. Extension-before-deep-fork order

When changing behavior, prefer this order (same as root AGENTS Customization Order):

| Order | Placement | When |
|-------|-----------|------|
| 1 | **do-harness** | Product identity: agents, hooks, skills, prompts, YAML overlays |
| 2 | **`.doit` / `~/.config/doit` config & plugins** | Product discovery root (CFG-DOIT); multi-model TOML |
| 3 | **`register_tool_pack`** | New in-process native tools |
| 4 | **Surgical crate patches** | Only when extension seams fail — log in patch-matrix |
| 5 | **Deep pager / TUI fork** | Last resort (M2+ with explicit decision) |

**Before** a new always-on behavior, tool, or deep fork: ask placement (Native vs Extension vs Crate Patch). Default if “you choose”: identity/safety/roles/model-assignment → do-harness; optional → plugin; in-process tool → tool pack; only then crate patch.

**Feature placement rule (binding for agents):**

| Want… | Prefer | Avoid |
|-------|--------|--------|
| New harness policy / gate / skill catalog / role body | **do-harness** + hooks/prompts/config | Editing random `xai-grok-*` files |
| External capability (graph, search, SaaS) | **MCP** first | Native tool unless MCP proven insufficient |
| Optional installable bundle | **Grok plugin** (manifest) packaging do-harness pieces | Burying identity only under home-dir without repo SoT |
| In-process tool only MCP cannot do | **`register_tool_pack`** from composition root | Scattering tools into unrelated crates |
| Default path / privacy / session lock / binary name | **Documented crate pin** (expand §2.2 only with patch-matrix row) | Silent deep fork |

Do **not** reinvent native tools grok already has (`plan` / plan mode, `update_goal`, hashline, `task`, `lsp`, multi-`[model.*]`, …). See [docs/grok-build/native-tools.md](./docs/grok-build/native-tools.md) and [docs/capability-map.md](./docs/capability-map.md).

### 3.1 Foreign extension compatibility (true-now)

| Ecosystem | Compatible? | How |
|-----------|-------------|-----|
| **Claude** skills / agents / hooks / plugins | **Yes** (gated) | Stock discovery + `CompatConfig` under `.claude/` walks |
| **MCP servers** | **Yes** | First-class `search_tool` / `use_tool`; product CodeGraph is MCP |
| **Grok plugins** (manifest: skills, agents, hooks, MCP, LSP) | **Yes** | Project `.doit/plugins`, user `$GROK_HOME/plugins`, marketplace |
| **Cursor** hooks/skills/rules | **Partial** | Stock compat paths; not full Cursor product parity |
| **OpenCode JS plugins** | **No** | OpenCode appears as a **native tool namespace**, not OpenCode’s plugin runtime |
| **pi-ness / npm ExtensionFactory** | **No** 1:1 | Different stack; copy discipline only (see §1.1) |

“Support extensions from other systems” means **MCP + Claude-layout + grok plugins** — not loading arbitrary OpenCode or pi factory packages.

---

## 4. Config root (CFG-DOIT): `~/.config/doit` + project `.doit/`

| Decision | Choice | Rationale |
|----------|--------|-----------|
| User config home | **`~/.config/doit` only** when `GROK_HOME` unset | P-CFG-HOME-DOIT; no silent `~/.grok` or `~/.config/do` fallback |
| Project discovery | **`.doit/`** (agents, hooks, config, skills, plan, …) | P-CFG-PROJECT-DOIT; product install targets |
| Share cache | **`~/.local/share/doit`** | Install scripts / bin cache |
| MCP server id | **`doit-codegraph`** | CodeGraph MCP surface |
| Product brand | **doit** in runtime paths; harness folder remains `do-harness/` | Repo layout vs discovery roots |
| Compat dirs | Keep **`.claude/`** (and other vendor) project walks | Out of scope to remove |

Link or copy `do-harness/` assets onto discovery paths (`~/.config/doit/...` or project `.doit/...`) as needed for proof agents/hooks.

Environment override: **`GROK_HOME`** replaces the full user home root (document this one; `DO_HOME` not wired). Host operators may keep temporary deprecation symlinks `~/.config/doit` → `doit` and `~/.local/share/do` → `doit`.

---

## 5. Dual config surface (multi-model)

Multi-model is **required product behavior**. Accurate facts (do not mis-document):

| Layer | Format | Owns | Runtime? |
|-------|--------|------|----------|
| **Stock runtime** | TOML `~/.config/doit/config.toml` (via `$GROK_HOME`) | Many `[model.<name>]`, `[models] default`, `api_backend`, agent/role/persona model fields | **Yes** — binary reads this |
| **do product overlay** | YAML `do-harness/config.models.yaml` | Registry ergonomics + **role → model + effort** assignment table | **Wired** via apply-models → agent frontmatter |

```
do-harness/config.models.yaml     (product UX: registry + assignment)
        │ maps / generates / documents
        ▼
~/.config/doit/config.toml        (native multi-model runtime; GROK_HOME override)
  + agent / role frontmatter model pins under project .doit/agents/
```

- Grok **already** supports N custom models via `[model.*]` — gap is **assignment UX** (limitation **L13**), not “add multi-model”
- Subagent resolution: spawn override > role > persona > parent  
- **Do not** replace TOML with a competing runtime registry the binary never loads  
- Full schema, map, and examples: [docs/models-and-config.md](./docs/models-and-config.md)

---

## 6. Upstream PRs are not the product path

| Allowed | Not the product path |
|---------|----------------------|
| Own the fork under **`/home/datht/code/doit`** | Opening external PRs to xAI / public grok-build as the way we ship **doit** |
| Merge `upstream/main` or re-copy from local sibling `~/code/grok-build` **into doit** | Editing `~/code/grok-build` or `~/code/pi-ness` in place |
| Document every crate patch in patch-matrix on each sync | Silent deep forks of pager/TUI without decision |
| Deprecate `/home/datht/code/do` in docs | Treating the sibling clone as the implementation root, or deleting it without user OK |

Upstream grok-build is treated as a **private/local** lineage for this product. Official Grok Build docs may still be useful as reference ([docs.x.ai/build](https://docs.x.ai/build/overview)); they are not the contribution workflow for doit.

---

## 7. License and notices

- Preserve **Apache-2.0** and third-party notices from the grok-build import  
- Keep `LICENSE` / `THIRD-PARTY-NOTICES` (and any crate-level notices) intact on re-import  
- English only for code, docs, commits, configs, errors, tests

---

## 8. Identity checklist (VAL-DOC-004 + ORIGIN)

| Requirement | Where |
|-------------|--------|
| Product intent | [README.md](./README.md) + this file §1 |
| Inject-first thin-fork thesis (not pure overlay, not deep rewrite) | §1.1 + AGENTS **Inject-first fork stance** |
| Implementation root `/home/datht/code/doit` | §2 + [AGENTS.md](./AGENTS.md) Project Direction |
| Sibling `/home/datht/code/do` deprecated (no force-delete) | §2 + AGENTS Hard Constraints |
| Upstream sync + patch-matrix review every absorb | §2 + AGENTS **Upstream sync checklist** |
| Dual-changed hotspot allowlist + must-survive pins | §2.1 / §2.2 + patch-matrix crate log |
| Never edit pi-ness / grok-build in place | §2 + VAL-CROSS-001 |
| Extension-before-deep-fork + feature placement rule | §3 + AGENTS Customization Order |
| Foreign ext = MCP + Claude + grok plugins (not OC/pi factories) | §3.1 |
| Config root `~/.config/doit` + project `.doit/` (CFG-DOIT sealed) | §4 |
| Dual TOML + do YAML model surface | §5 + [docs/models-and-config.md](./docs/models-and-config.md) |
| No external upstream PRs as product path | §6 + Non-Goals in AGENTS |

---

## 9. Related docs

| Doc | Purpose |
|-----|---------|
| [README.md](./README.md) | Human product overview + build smoke |
| [AGENTS.md](./AGENTS.md) | Operating contract + living status |
| [docs/architecture.md](./docs/architecture.md) | System layout + dual config diagram |
| [docs/models-and-config.md](./docs/models-and-config.md) | Multi-model + L13 |
| [docs/patch-matrix.md](./docs/patch-matrix.md) | Gap → path / risk / order (L10 fork hygiene) |
| [docs/grok-build/hard-limits.md](./docs/grok-build/hard-limits.md) | What not to fight |
| [docs/related-projects.md](./docs/related-projects.md) | pi-ness / grok-build / OpenCode mapping |
| [docs/milestone-ship-discipline.md](./docs/milestone-ship-discipline.md) | Docs + commit every milestone |

---

## 10. Non-goals (fork scope)

- Full OpenTUI / Node port of pi-ness TUI  
- Competing multi-model runtime that bypasses `~/.config/doit/config.toml` (or `$GROK_HOME/config.toml`)
- Speculative abstractions before M0 baseline seals  
- Deep pager fork before extension seams are exhausted  
- Public upstream PR workflow as the definition of “done” for do features  
- **Unforking** to a stock unmodified grok binary while keeping PRIV / CFG-DOIT / role-lock product pins (those pins require the thin fork)  
- Loading **OpenCode JS plugins** or **pi-ness ExtensionFactory** packages as if they were native  
- Expanding crate surface for features that fit do-harness / MCP / hooks  
- A third product path rebrand after CFG-DOIT without explicit user OK
