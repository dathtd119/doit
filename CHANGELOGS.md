# CHANGELOGS

Append-only ship log for **doit** (historical brand **do**). Not a status essay — one entry per substantive milestone or control-plane change.

---
## 2026-07-17 — Stock-native product agents (prompts/agents)

**Scope:** agent naming + prompt inject + dynamic spawn floors  
**Feature:** P-AGENTS-NATIVE (stock-native product agents)

### What landed

- **Thesis:** [docs/agents-and-prompts.md](./docs/agents-and-prompts.md) — one Grok agent system; product = bodies + contracts
- **Bodies:** `do-harness/prompts/roles/` → **`prompts/agents/`** (user override: `~/.config/doit/prompts/agents/`)
- **No product `do-harness/agents/`** — mission text only under prompts; full AgentDefinition dirs remain user override
- **Canonical names (stock family):**
  - `intake` → `grok-build-ask-user` (option A)
  - `orchestrator` → `grok-build-orchestrator`
  - `explore` / `explorer` → `explore`
  - `worker` → `grok-build-worker`
  - `oracle` → `grok-build-oracle`
- **Contracts:** seed **`config.agents.toml`** with `order`, `allowed_subagents`, native `Agent(explore|plan|grok-build-*)` floors; legacy `[roles]` / `config.roles.toml` still accepted
- **Runtime:** alias map + canonical resolve in `role_switch` / `product_role`; `allowed_subagent_types` from contracts; dynamic custom agents via config contract
- **Orchestrator prompt** teaches native `subagent_type` names
- Verify scripts updated for agents paths + TOML contracts

### Evidence

- `cargo test -p xai-grok-shell --lib -- role_switch product_role` — 21 ok
- `cargo test -p xai-grok-shell --test role_switch_policy` — 10 ok
- `bash do-harness/scripts/verify-role-contracts.sh` — pass
- `bash do-harness/scripts/verify-roster.sh` — pass
- `bash do-harness/scripts/verify-hashline.sh` — VAL-M3-HASH-001 pass

---

## 2026-07-17 — P-VERSION product-owned VERSION

**Scope:** product semver SoT + release/tag alignment  
**Feature:** P-VERSION (fork version ownership)

### What landed

- Repo-root **`VERSION`** (`0.0.2`) is product SoT (comments allowed; first non-`#` line wins)
- Build stamp precedence: `DOIT_VERSION` → `GROK_VERSION` → root `VERSION` → `CARGO_PKG_VERSION`
- Packages `doit` + `xai-grok-version` at `0.0.2`; clap CLI name **`doit`**
- Release workflow: tag must match `v{VERSION}`; injects `DOIT_VERSION` into release builds; notes from **this** repo’s git history
- Upstream monorepo crate versions (e.g. pager/shell `0.2.x`) may diverge — absorb must **not** overwrite product `VERSION`

### Evidence

- `docs/patch-matrix.md` § P-VERSION
- `cargo check -p doit` + `doit --version` → `doit 0.0.2 (<sha>)`

---

## 2026-07-17 — P-BRAND-UI user-facing Grok → Doit

**Scope:** runtime UX + L0 identity + in-product user-guide + light product docs  
**Feature:** P-BRAND-UI (user-visible product brand)

### What landed

- System prompt default label **Doit**; L0 opening is `You are ${{ system_prompt_label }}.` (no “released by xAI”)
- Dual L0: `do-harness/prompts/l0-general.md` + agent `templates/prompt.md`; subagent/apply_patch templates rebranded
- Config seed: `[agent] system_prompt_label = "Doit"` in `do-harness/config.defaults.toml`
- TUI chrome: welcome / hero / minimal welcome / notifications / CLI about / billing & trust copy
- In-product tool guide (`xai-grok-pager/docs/user-guide/**`): product noun **Doit**, CLI `doit`, paths `~/.config/doit` / `.doit/`
- Root README title **doit**; install path already product binary

### Not in this entry

- Crate renames, `GROK_*` env rename, model slug / catalog marketing names
- Per-provider OAuth → `system_prompt_label` mapping (parked; tiers already exist)

### Evidence

- `docs/patch-matrix.md` § P-BRAND-UI
- `cargo check -p doit` (smoke)

---
## 2026-07-17 — Upstream absorb `98c3b24` (F-UPSTREAM-MERGE)

**Scope:** merge `upstream/main` (`98c3b24`) into product history on `sync/upstream-98c3b24`  
**Feature:** F-UPSTREAM-MERGE · **VALs:** VAL-UP-001..005

### What landed

- Merge monorepo sync tip `98c3b24` (one commit ahead of prior absorb `8adf901`)
- Product identity preserved: package/binary **`doit`**, lockstep version **`0.2.102`**
- Product pins re-verified: P-NOTEL fail-closed telemetry, CFG-DOIT paths, L1 role-switch lock, P-AUTH BYOK skip OAuth
- Conflict map + dual-changed notes: [`docs/patch-matrix.md`](./docs/patch-matrix.md) § Upstream sync — `98c3b24`

### Evidence

- `cargo check -p doit` — exit 0
- `git merge-base --is-ancestor 98c3b24 HEAD` — true after merge

### Not in this entry

- Push to origin / merge into `main` (operator choice)
- Restoring local WIP stash `wip: pre-upstream-sync-98c3b24`

---

## 2026-07-17 — Fork inject-first thesis docs (FORK + AGENTS)

**Scope:** docs only — capture inject-first thin-fork stance for future upstream absorbs  
**Feature:** control-plane / fork hygiene (no runtime code)

### What landed

- [`FORK.md`](./FORK.md):
  - §1.1 topology thesis (pi-ness discipline vs doit hybrid vs pure-overlay non-goal)
  - §2.1 dual-changed hotspot allowlist
  - §2.2 must-survive product crate pins
  - §3 feature placement rule + §3.1 foreign extension compatibility
  - Non-goals: unfork, OC/pi factory load, third path rebrand
- Root [`AGENTS.md`](./AGENTS.md):
  - **Inject-first fork stance** section (binding for implement + sync)
  - Hard Constraints: inject-first + freeze crate surface
  - **Upstream sync checklist** expanded (hotspot walk, conflict default, FORK §2.2 pins)
  - Customization Order anti-patterns + foreign ext placement
  - Current Status / Next steps / Non-Goals updated for thesis

### Evidence

- File existence + cross-links FORK ↔ AGENTS; no cargo required (docs-only)

### Not in this entry

- Runtime inject inventory implementation, plugin packaging of do-harness, or `PRODUCT_ROSTER` config-first code

---

## 2026-07-16 — F-PKG-SHIP packaging seal (VAL-PKG-004, VAL-PKG-005)

**Scope:** seal M3 PKG leftovers — README Install + `verify-install.sh` gates  
**Feature:** F-PKG-SHIP · **VALs:** VAL-PKG-004, VAL-PKG-005  
**Mission:** `mis_89367de7` M3 PKG **complete**

### Sealed product surface (prior implement commits)

| Track | Commit | Surface |
|-------|--------|---------|
| **F-PKG-RETARGET** | `2c773fe` | CI/docs smoke → `cargo check -p doit`; verify-install VAL-PKG-001 |
| **F-PKG-REL** | `f0cc688` | `release.yml` 6-target matrix; package/binary `doit`; binstall for `dathtd119/doit` |
| **F-PKG-SHIP** | this | verify-install BIN+REL+README; README Install no crates.io claim |

### Evidence (this ship)

| Command | Result |
|---------|--------|
| `bash do-harness/scripts/verify-install.sh` | PASS — 41 checks (BIN + REL matrix/binstall + README Install); VAL-PKG-004 |
| README `## Install` | PASS — `doit` + `dathtd119/doit`; binstall/git/path; explicit non-crates.io; VAL-PKG-005 |
| `cargo check -p doit` | PASS (via verify-install section 5) |

### Docs / script this ship

- [do-harness/scripts/verify-install.sh](./do-harness/scripts/verify-install.sh): sections 7–9 (REL matrix, binstall, README Install, optional NPM skip)
- Root [AGENTS.md](./AGENTS.md) / [docs/current-status.md](./docs/current-status.md): M3 PKG sealed
- This CHANGELOGS entry

### Not in this entry

- Live GitHub Release publish (tag `v*` when operators ready)
- npm product package tree (gate intentionally skipped; no live npm)

### Key commits (implement lineage)

- `2c773fe` RETARGET · `f0cc688` REL · this SHIP

---

## 2026-07-16 — F-CFG-SHIP CFG-DOIT seal (VAL-CFG-007, VAL-CFG-008)

**Scope:** seal CFG-DOIT living docs + build smoke after path rebrand implement commits  
**Feature:** F-CFG-SHIP · **VALs:** VAL-CFG-007, VAL-CFG-008  
**Mission:** `mis_89367de7` M1 CFG-DOIT

### Sealed product surface (prior implement commits)

| Track | Commit | Surface |
|-------|--------|---------|
| **F-CFG-HOME** | `12ed80c` `feat(config): default user home ~/.config/doit` | P-CFG-HOME-DOIT — `DEFAULT_USER_HOME_REL` → `.config/doit`; synced resolvers |
| **F-CFG-PROJECT** | `43bb3b2` `feat(config): project discovery under .doit/` | P-CFG-PROJECT-DOIT — agents/hooks/plan/skills under `.doit/` |
| **F-CFG-MIGRATE** | `de07cc1` `feat(config): migrate host paths and MCP id to doit` | Host `~/.config/doit` + share `~/.local/share/doit`; MCP `doit-codegraph` |

### Evidence (this ship)

| Command | Result |
|---------|--------|
| `cargo check -p doit` | PASS — VAL-CFG-007 (exit 0) |
| Living docs path truth | PASS — VAL-CFG-008: `~/.config/doit`, `.doit/`, worktree `/home/datht/code/doit` in AGENTS / current-status / architecture |

### Docs this ship

- Root [AGENTS.md](./AGENTS.md): CFG-DOIT **sealed**; true-now config/share/MCP; next = M3 packaging
- [docs/current-status.md](./docs/current-status.md): CFG-DOIT section + brand mission status
- [docs/architecture.md](./docs/architecture.md): dual-surface + boundaries use `~/.config/doit` / `.doit/`
- [FORK.md](./FORK.md) §4, [docs/models-and-config.md](./docs/models-and-config.md), [docs/workspace.md](./docs/workspace.md) + related living docs path rebrand
- This CHANGELOGS entry

### Not in this entry

- M3 packaging leftovers (CI/release/binstall → `dathtd119/doit`)
- Removal of host deprecation symlinks `~/.config/do` → `doit` (optional ops)

### Key commits (implement lineage)

- `12ed80c` HOME · `43bb3b2` PROJECT · `de07cc1` MIGRATE

---

## 2026-07-16 — F-ORIGIN-AGENTS worktree + upstream sync rule

**Scope:** docs / operating contract only  
**Feature:** F-ORIGIN-AGENTS · **VALs:** VAL-ORIGIN-003, VAL-ORIGIN-004, VAL-CROSS-001  
**Mission:** `mis_89367de7` M0 ORIGIN

### Shipped

- Root [AGENTS.md](./AGENTS.md): **Upstream sync checklist** (fetch → patch-matrix inventory of forked/dual-changed paths → map pager-bin→`doit` → smoke → log sync; never edit pi-ness/grok-build in place)
- Implementation root **`/home/datht/code/doit` only**; sibling `/home/datht/code/do` **deprecated** as writable product root (no force-delete)
- Origin true-now: `https://github.com/dathtd119/doit.git`; smoke package **`doit`**
- [FORK.md](./FORK.md): source-tree table + mandatory patch-matrix review on absorb
- [CONTINUE.md](./CONTINUE.md), [docs/current-status.md](./docs/current-status.md): worktree / boundary truth

### Not in this entry

- Upstream merge itself (F-UPSTREAM-MERGE)
- CFG path rebrand to `~/.config/doit` / `.doit/` (later mission track)

---

## 2026-07-16 — F-M3-SHIP native power tools seal (VAL-M3-SHIP-001)

**Scope:** seal M3 implement evidence + living docs / capability-map; no new product harness code this commit  
**Feature:** F-M3-SHIP · **VALs:** VAL-M3-CG-001, VAL-M3-HASH-001, VAL-M3-SHIP-001  
**Mission:** `mis_e0bdf86b` backlog M1–M3 **complete**

### Sealed product surface (prior implement commits)

| Track | Commit | Surface |
|-------|--------|---------|
| **F-M3-CG** | `7a55c75` `feat(codegraph): ship MCP explore/impact surface` | MCP-first `do-codegraph` wrapping `xai-codebase-graph` (`codegraph_explore` / `codegraph_impact` / `codegraph_stats`); design [docs/codegraph.md](./docs/codegraph.md); fixture + `verify-codegraph.sh` |
| **F-M3-HASH** | `ef06622` `feat(harness): hashline default edit policy` | Product `file_toolset = "hashline"` via `do-harness/config.toolset.toml`; worker/orchestrator guidance + floors; rollback `file_toolset = "standard"`; [docs/hashline.md](./docs/hashline.md); `verify-hashline.sh` |

### Evidence (this ship)

| Command | Result |
|---------|--------|
| `bash do-harness/scripts/verify-codegraph.sh` | PASS — VAL-M3-CG-001 (29 checks) |
| `bash do-harness/scripts/verify-hashline.sh` | PASS — VAL-M3-HASH-001 (45 checks) |

### Docs this ship

- Root `AGENTS.md` Status/Next: M3 **sealed**; mission backlog complete; next = parking-lot promotions only
- [docs/current-status.md](./docs/current-status.md) narrative refreshed for M3 seal
- [docs/backlog-m1-m3.md](./docs/backlog-m1-m3.md) M3 exit criteria **all checked** (including no silent tool-pack sprawl)
- [docs/capability-map.md](./docs/capability-map.md) — L1–L13 master map + gap register refreshed for post-M3 truth
- [docs/future-plan.md](./docs/future-plan.md) — M3 CodeGraph/hashline marked done
- [docs/index.md](./docs/index.md) — backlog header notes M3 sealed
- Prior implement docs already present: [codegraph.md](./docs/codegraph.md), [hashline.md](./docs/hashline.md)
- This CHANGELOGS entry

### Placement notes

- **No crate patch** for M3 power tools: CodeGraph = MCP extension; hashline = config + agent overlay on stock `FileToolset::Hashline`
- M3-T01 tool packs: none required this milestone (documented as such on exit checklist)

### Next (not in this seal)

1. Parked polish from [future-plan.md](./docs/future-plan.md): goal-as-mission runner, side-ask dual stream, BM25 skill_search, multi-provider auth, permission-rules YAML, optional CodeGraph `tool_pack`
2. Proactive first-message role-lock toast (optional UX)

### Key commits (implement lineage)

- `7a55c75` CG · `ef06622` HASH

---

## 2026-07-16 — F-M2-SHIP continuity & safety seal (VAL-M2-SHIP-001)

**Scope:** seal M2 implement evidence + living docs; no new product harness code this commit  
**Feature:** F-M2-SHIP · **VALs:** VAL-M2-CONT-001, VAL-M2-GATE-001, VAL-M2-SKILL-001, VAL-M2-PERM-001, VAL-M2-SHIP-001

### Sealed product surface (prior implement commits)

| Track | Commit | Surface |
|-------|--------|---------|
| **F-M2-CONT** | `1e523b2` `feat(harness): continuation priority policy and nudges` | Priority lanes interrupt→streak→goal→plan→workflow→todo; PostToolUse `continuation-nudge`; multi-step thrash fixture |
| **F-M2-GATES** | `324c959` `feat(harness): product guided-block gates pack` | Product standard `[GATE: …]` + **Do this instead**; path-policy + env-expose packs beyond dangerous-shell; gates in all five role prompts |
| **F-M2-SKILL** | `803f415` `feat(harness): progressive skill MCP catalog default` | Progressive/curated default on five roster roles (`discoverSkills: false`); firehose opt-in; MCP via `search_tool`/`use_tool` |
| **F-M2-PERM** | `0b63f7b` `feat(harness): role tool floors on five agents` | Allow/deny floors via agent frontmatter + `config.permissions.yaml`; aligned with guided gate families |

### Evidence (this ship)

| Command | Result |
|---------|--------|
| `bash do-harness/scripts/verify-continuation.sh` | PASS — VAL-M2-CONT-001 (21 checks) |
| `bash do-harness/scripts/verify-gates.sh` | PASS — VAL-M2-GATE-001 (39 checks) |
| `bash do-harness/scripts/verify-progressive-skills.sh` | PASS — VAL-M2-SKILL-001 (32 checks) |
| `bash do-harness/scripts/verify-role-permissions.sh` | PASS — VAL-M2-PERM-001 (floors + deny families + gate naming) |

### Docs this ship

- Root `AGENTS.md` Status/Next: M2 **sealed**; next **M3** (CodeGraph + hashline default)
- [docs/current-status.md](./docs/current-status.md) narrative refreshed for M2 seal
- [docs/backlog-m1-m3.md](./docs/backlog-m1-m3.md) M2 exit criteria checked
- [docs/future-plan.md](./docs/future-plan.md) — M2-shipped items marked done; M3 remains active
- Prior implement docs already present: [continuation.md](./docs/continuation.md), [progressive-skills.md](./docs/progressive-skills.md), [role-permissions.md](./docs/role-permissions.md), gates catalog under `do-harness/prompts/gates.md`
- This CHANGELOGS entry

### Next (not in this seal)

1. **M3** — CodeGraph product surface + hashline default edit policy; final seal
2. Parked polish: proactive first-message role-lock toast; BM25 skill_search/load parity; deep multi-provider auth

### Key commits (implement lineage)

- `1e523b2` CONT · `324c959` GATES · `803f415` SKILL · `0b63f7b` PERM

---

## 2026-07-16 — F-CFG-SHIP config rebrand seal (VAL-CFG-SHIP-001)

**Scope:** seal CFG implement evidence + living docs; no new product crate code this commit  
**Feature:** F-CFG-SHIP · **VALs:** VAL-CFG-HOME-001, VAL-CFG-PROJECT-001, VAL-CFG-SHIP-001

### Sealed product surface (prior implement commits)

| Track | Commit | Surface |
|-------|--------|---------|
| **P-CFG-HOME** | `12a5c20` `feat(config): default user home ~/.config/do` | `default_grok_home` / `DEFAULT_USER_HOME_REL` → `.config/do`; synced worktree/agent resolvers; **no** silent `~/.grok` fallback; override `GROK_HOME` |
| **P-CFG-PROJECT** | `9039f68` `feat(config): project discovery under .do/` | Agents/hooks/plan/config/skills/plugins product paths under **`.do/`**; do-harness verify/install updated |
| **P-CFG-FIXTURES** | `53bf77b` `test(config): align project fixtures with .do/` | Test fixtures seed `.do/` to match product discovery |

### Evidence (this ship)

| Command | Result |
|---------|--------|
| `bash do-harness/scripts/verify-discovery.sh` | PASS — project `.do/agents` + `.do/hooks`; crate evidence for `.do/` discovery |
| `bash do-harness/scripts/verify-roster.sh` | PASS — five agents on `.do/agents/` |

### Docs this ship

- [FORK.md](./FORK.md) §4 — `~/.config/do` + project `.do/` (already applied by implement; status header sealed)
- [docs/models-and-config.md](./docs/models-and-config.md) — CFG paths + dual surface table
- [docs/workspace.md](./docs/workspace.md) — continuum under `.do/` + `~/.config/do` sessions
- [docs/architecture.md](./docs/architecture.md), [docs/index.md](./docs/index.md), [README.md](./README.md) — discovery roots
- [docs/patch-matrix.md](./docs/patch-matrix.md) — **applied** P-CFG-HOME / P-CFG-PROJECT / P-CFG-FIXTURES
- Root `AGENTS.md` Status/Next + [docs/current-status.md](./docs/current-status.md): CFG **sealed**; next **M2**
- [docs/future-plan.md](./docs/future-plan.md), [docs/backlog-m1-m3.md](./docs/backlog-m1-m3.md) — CFG parked items marked done
- This CHANGELOGS entry

### Next (not in this seal)

1. **M2** — continuation priority + guided-block pack + progressive deepen + role floors
2. **M3** — CodeGraph product surface + hashline default

### Key commits (implement lineage)

- `12a5c20` P-CFG-HOME · `9039f68` P-CFG-PROJECT · `53bf77b` P-CFG-FIXTURES

---

## 2026-07-16 — F-PRIV-SHIP privacy seal (VAL-PRIV-SHIP-001)

**Scope:** seal PRIV implement evidence + living docs; no new product code this commit  
**Feature:** F-PRIV-SHIP · **VALs:** VAL-PRIV-NOTEL-001, VAL-PRIV-AUTH-001, VAL-PRIV-SHIP-001

### Sealed product surface (prior implement commits)

| Track | Commit | Surface |
|-------|--------|---------|
| **P-NOTEL-01..06** | `4458c69` `feat(privacy): fail-closed SpaceXAI telemetry` | Product analytics, Mixpanel, Sentry, internal OTLP, trace upload, feedback — fail-closed; **preserve** `GROK_EXTERNAL_OTEL` + `OTEL_*` |
| **P-AUTH-01** | `11d8752` `feat(privacy): skip forced OAuth for BYOK` | BYOK / `[auth] preferred_method=api_key` skips interactive grok.com OAuth at `workspace_start`; ACP already preferred `xai.api_key` first |

### Docs this ship

- `docs/patch-matrix.md` — **applied** rows for P-NOTEL-01..06 + P-AUTH-01 (from implement commits; restated in ship narrative)
- `docs/models-and-config.md` — Auth section: custom models / BYOK config-first + P-AUTH-01 runtime paths
- Root `AGENTS.md` Status/Next: PRIV **sealed**; next **CFG** (`~/.config/do` + project `.do/`) **then** M2 (not M2 immediately)
- `docs/current-status.md` narrative refreshed (AGENTS.md may be gitignored — this file is the committed living mirror)
- `docs/future-plan.md` — P-NOTEL + P-AUTH parked items marked done
- This CHANGELOGS entry

### Next (not in this seal)

1. **CFG** — default user home `~/.config/do` only (no `~/.grok` fallback); project discovery `.do/`; docs + CHANGELOGS seal
2. **M2** — continuation priority + guided-block pack + progressive deepen + role floors
3. **M3** — CodeGraph product surface + hashline default

### Key commits (implement lineage)

- `4458c69` P-NOTEL-01..06 · `11d8752` P-AUTH-01

---

## 2026-07-16 — F-M1-SHIP M1 harness control seal (VAL-M1-SHIP-001)

**Scope:** seal M1 implement evidence + living docs; no new product code  
**Feature:** F-M1-SHIP · **VALs:** VAL-M1-ROSTER-001, VAL-M1-LOCK-001, VAL-M1-MODEL-001, VAL-M1-PROMPT-001, VAL-M1-WORK-001, VAL-M1-SKILL-001, VAL-M1-SHIP-001

### Evidence (all exit 0)

| Command | Result |
|---------|--------|
| `bash do-harness/scripts/verify-roster.sh` | PASS — five agents + `.grok/agents/` discovery |
| `bash do-harness/scripts/verify-discovery.sh` | PASS — intake + guided shell hook path |
| `python3 do-harness/scripts/apply-models.py --validate` | PASS — 5 role pins (combo-big / combo-small) |
| `bash do-harness/scripts/verify-role-lock.sh` | PASS — 10 `role_switch_policy` tests |
| `bash do-harness/scripts/verify-model-resolve.sh` | PASS — re-pin only while unlocked |
| `bash do-harness/scripts/verify-progressive-skills.sh` | PASS — progressive default + reduced firehose |

### M1 product surface sealed (prior implement commits)

- **Roster** — intake / orchestrator / explorer / worker / oracle under `do-harness/agents/` + project `.grok/agents/` symlinks
- **Role switch lock** — `role_switch_allowed` pre-message only; Tab/Shift+Tab gated; L1 freeze after first user message
- **Lock UX** — locked-attempt toast points to new session (`c8bf39f` `feat(session): toast when role switch locked`; `role_switch_locked_toast`)
- **YAML→agent models** — `apply-models.py` maps `config.models.yaml` `assignment.*` into agent frontmatter; stock TOML remains runtime registry
- **Model re-resolve** — role cycle re-pins model only while switch allowed
- **L0–L6 + workspace** — `docs/prompt-system.md` implementable map; role fragments in `do-harness/prompts/`; `docs/workspace.md` non-stub continuum (reuse `.grok` only)
- **Progressive skills (start)** — `docs/progressive-skills.md` + `config.skills.yaml`; intake/explorer/oracle `discoverSkills: false`

### Docs / process this ship

- Root `AGENTS.md` Status/Next: M0 + **M1 sealed**; next **PRIV** then M2
- `docs/current-status.md` narrative refreshed for M1 seal
- `docs/backlog-m1-m3.md` M1 exit criteria checked
- This CHANGELOGS entry

### Next (not in this seal)

- **PRIV** — P-NOTEL fail-closed + custom-models/BYOK no forced OAuth
- **M2** — continuation priority + guided-block pack + progressive deepen + role floors
- Proactive first-message lock toast (deferred polish)

### Key commits (implement lineage)

- `9338619` roster · `07a19ca` prompt/workspace docs · `a0aed58` apply-models  
- `baef230` role lock · `2f7c725` model re-pin · `71d19b3` progressive skills · `c8bf39f` lock UX toast  

---

## 2026-07-16 — F-M1-LOCK role switch lock (VAL-M1-LOCK-001)

**Scope:** primary-session product role cycle gate + L1 freeze  
**Feature:** F-M1-LOCK · **VAL:** VAL-M1-LOCK-001

### Sealed

- Pure policy module `xai-grok-shell::session::role_switch`:
  - `role_switch_allowed(turn_count, has_user_message_content)`
  - product roster cycle: intake → orchestrator → explorer → worker → oracle
  - `gate_role_cycle` Apply / Locked outcomes
- Shell: product-role `session/set_mode` refused when flag is false (plan/default/ask remain switchable)
- Pager: pre-message Tab / Shift+Tab cycle product roles; after lock, Shift+Tab falls through to stock CycleMode (plan/yolo)
- Integration tests `tests/role_switch_policy.rs` (6 cases) + `do-harness/scripts/verify-role-lock.sh`
- Crate patches logged in `docs/patch-matrix.md`

### Not in scope

- Visible lock toast / “start new session” UX (F-M1-UX)
- Model re-pin from YAML only while unlocked (F-M1-MODEL-RESOLVE)
- Full lib unit-test suite (pre-existing cfg(test) seams unrelated to this feature)

### Files

- `crates/codegen/xai-grok-shell/src/session/role_switch.rs`
- `crates/codegen/xai-grok-shell/tests/role_switch_policy.rs`
- `crates/codegen/xai-grok-shell/src/session/acp_session_impl/session_mode.rs`
- `crates/codegen/xai-grok-pager/src/app/dispatch/modes.rs`, `router.rs`, `agent_view/prompt.rs`, actions
- `do-harness/scripts/verify-role-lock.sh`
- `docs/patch-matrix.md`, this CHANGELOGS entry

---

## 2026-07-16 — F-BACK-001 M1–M3 ordered backlog

**Scope:** docs backlog for post-M0 product work  
**Feature:** F-BACK-001 · **VAL:** VAL-BACK-001

### Sealed

- `docs/backlog-m1-m3.md` — ordered backlog with testable acceptance per item:
  - **M1:** role session flag + Tab/Shift+Tab keybind gate + post-first-message lock; five-role roster; **wire `do-harness/config.models.yaml` assignment into agents**; role→model re-resolve only while switch allowed; L0–L6 map; workspace continuum contract; progressive skills start
  - **M2:** continuation priority lanes on native goal/plan/todo; guided-block product-wide; progressive skill/MCP catalog; role permission floors
  - **M3:** CodeGraph lean surface (MCP/`tool_pack`); **hashline default** edit policy; always-on tool packs as needed
- Cross-links from `docs/index.md`; dependency sketch + deferred parking lot pointer to `future-plan.md`

### Not in scope

- Implementing M1–M3 code (planning only)
- M0 seal commit (orchestrator / follow-up)

### Files

- `docs/backlog-m1-m3.md`
- `docs/index.md` (status line)
- This CHANGELOGS entry
- Living status: root `AGENTS.md`, `docs/current-status.md`

---

## 2026-07-16 — F-EXT-003 proof extension discovery verified

**Scope:** do-harness discovery verification + product README  
**Feature:** F-EXT-003 · **VAL:** VAL-EXT-003

### Sealed

- `do-harness/scripts/verify-discovery.sh` — scripted discovery-path check (exit 0):
  - project `.grok/agents/intake.md` and `.grok/hooks/*` on real grok paths
  - symlinks resolve to `do-harness/` source of truth
  - agent frontmatter + hook PreToolUse JSON shape
  - guided deny/allow self-test (`[GATE: …]`)
  - forked evidence citations (`discovery.rs`, `util/hooks.rs`)
  - optional binary `inspect` when a pager binary is built
- `do-harness/README.md` — layout, enablement, **verify commands** for VAL-EXT-003

### Not in scope

- Full binary-built inspect e2e when no binary is present (path check is authoritative per VAL-EXT-003(b))
- YAML→agent wiring / role Tab cycle (M1)
- M0 seal commit / backlog-m1-m3 (F-BACK-001)

### Files

- `do-harness/scripts/verify-discovery.sh`
- `do-harness/README.md`
- This CHANGELOGS entry

---

## 2026-07-16 — F-EXT-002 guided PreToolUse hook proof

**Scope:** do-harness hooks + project discovery install  
**Feature:** F-EXT-002 · **VAL:** VAL-EXT-002

### Sealed

- `do-harness/hooks/guided-dangerous-shell.json` — PreToolUse matcher for shell tools (`Bash` / `run_terminal_cmd` / …)
- `do-harness/hooks/bin/guided-dangerous-shell.py` — deny dangerous patterns (`rm -rf /`, `sudo rm`, `pkill`/`killall`, `mkfs`, `dd … of=/dev/…`, fork bombs, device redirects) with **guided-block** reason:
  - `[GATE: …]` + **Do this instead** (+ optional Human involvement / Do not)
  - never bare “Permission denied”
- `do-harness/hooks/README.md` — enablement (project symlink / user-global copy) + verify commands
- Project discovery install: `.grok/hooks/guided-dangerous-shell.json` + `.grok/hooks/bin/guided-dangerous-shell.py` → symlinks to do-harness (same pattern as intake agent)

### Not in scope

- F-EXT-003 end-to-end discovery binary/script + top-level `do-harness/README.md`
- Full always-on guided-block productization (M2)

### Files

- `do-harness/hooks/guided-dangerous-shell.json`
- `do-harness/hooks/bin/guided-dangerous-shell.py`
- `do-harness/hooks/README.md`
- `.grok/hooks/*` (symlinks)
- This CHANGELOGS entry

---

## 2026-07-16 — F-EXT-001 intake agent profile proof

**Scope:** do-harness agent + project discovery install  
**Feature:** F-EXT-001 · **VAL:** VAL-EXT-001

### Sealed

- `do-harness/agents/intake.md` — grok-compatible agent definition (YAML frontmatter + prompt body):
  - `name: intake`, `permissionMode: plan`, clarify-only tools floor
  - Allowlist: `read_file`, `list_dir`, `grep`, `run_terminal_cmd`, `ask_user_question`, `Agent(explore)`
  - Denylist: edits, plan/goal/todo ownership tools
  - Intent Pack capture fields; no implementation; M1 model pin noted (`model: inherit` for M0)
- Project discovery install: `.grok/agents/intake.md` → symlink to `do-harness/agents/intake.md` (source of truth under do-harness; on path used by `xai-grok-agent` discovery walk)

### Not in scope

- F-EXT-002 guided PreToolUse hook
- F-EXT-003 end-to-end binary/scripted discovery verification + `do-harness/README.md`
- Full role roster / Tab cycle (M1)

### Files

- `do-harness/agents/intake.md`
- `.grok/agents/intake.md` (symlink)
- This CHANGELOGS entry

---

## 2026-07-16 — F-DOC-004 README + FORK policy seal

**Scope:** docs only (`README.md`, `FORK.md`, index, living status)  
**Feature:** F-DOC-004 · **VAL:** VAL-DOC-004

### Sealed

- `README.md` product intent: forked Grok Build + pi-ness harness control + OpenCode-style multi-model ergonomics; dual config; build smoke
- `FORK.md` fork hygiene and identity:
  - Extension-before-deep-fork order (do-harness → config/plugins → tool packs → crate patch → deep TUI)
  - Config root **`~/.grok` reuse for M0** (brand as do in docs; optional `~/.do` later)
  - Dual multi-model surface: stock TOML runtime + do YAML assignment overlay (L13 accurate facts)
  - No external upstream PRs as product path; sibling trees read-only; import by copy
  - License/notices and VAL-DOC-004 checklist
- Cross-linked from `docs/index.md`, living status, limitations L10 pointer

### Not in scope

- F-EXT proof agent/hook; F-BACK-001 backlog; YAML→agent runtime wire (M1)

### Files

- `README.md`
- `FORK.md` (new)
- `docs/index.md`
- Root `AGENTS.md` living status + next steps
- `docs/current-status.md`
- `docs/limitations.md` / `docs/patch-matrix.md` (FORK status cross-ref)
- This CHANGELOGS entry

---

## 2026-07-16 — F-DOC-003 capability-map seal

**Scope:** docs only (`docs/capability-map.md`, index, living status)  
**Feature:** F-DOC-003 · **VAL:** VAL-DOC-003

### Sealed

- `docs/capability-map.md` maps:
  - pi-ness **native modules** (tools, safety, continuum, session glue, subagent) → grok tools/APIs/hooks/config or `"gap"`
  - **L0–L6 / layer purposes** → grok inject points + do-harness homes
  - **Roles** and **continuum** (goal / plan / todo / continuation)
  - **Model registry + assignment** (L13 dual TOML + do YAML; resolution chain; M1 wire)
  - Explicit `"gap"` register with L* / milestone / preferred path
  - “Use, don’t reinvent” native tool table
- Cross-linked from `docs/index.md`, `docs/limitations.md`, living status

### Not in scope

- F-DOC-004 README/FORK; runtime wiring of any gap
- Implementation of L1 Tab lock or L13 YAML auto-apply

### Files

- `docs/capability-map.md` (new)
- `docs/index.md`
- `docs/limitations.md` (cross-ref)
- Root `AGENTS.md` living status + next steps
- `docs/current-status.md`
- This CHANGELOGS entry

---

## 2026-07-16 — F-DOC-002 patch-matrix L1–L13 seal

**Scope:** docs only (`docs/patch-matrix.md`, index, living status)  
**Feature:** F-DOC-002 · **VAL:** VAL-DOC-002

### Sealed

- `docs/patch-matrix.md` maps **every L1–L13** gap to:
  - Preferred path (`plugin` | `hook` | `agent` | `skill` | `tool_pack` | `crate_patch` | `defer` + `config` overlay)
  - Risk band
  - Recommended implementation **order** (master table + expanded rows)
- Expanded per-gap fields: seams, avoid, milestone, links to limitations + grok-build extension-seams / hard-limits
- Crate patch log scaffold (empty — no product crate patches yet)
- Milestone → matrix slice (M0–M3)
- Living status + `docs/index.md` updated

### Not in scope

- F-DOC-003 capability-map
- Runtime implementation of any L* gap

### Files

- `docs/patch-matrix.md`
- `docs/index.md`
- Root `AGENTS.md` living status + next steps
- `docs/current-status.md`
- `docs/limitations.md` (cross-ref only)
- This CHANGELOGS entry

---

## 2026-07-16 — F-DOC-001 limitations L1–L13 seal

**Scope:** docs only (`docs/limitations.md`, index, living status)  
**Feature:** F-DOC-001 · **VAL:** VAL-DOC-001

### Sealed

- `docs/limitations.md` complete evidence-backed inventory for **L1–L13**:
  - Each row: idea (pi-ness / OpenCode) → stock grok status → gap → preferred path → absolute evidence paths
  - L1 role control + post-message lock; L2 prompt layers; L3 native factories; L4 progressive catalog; L5 continuation; L6 guided blocks; L7 CodeGraph; L8 side-ask/intake; L9 workspace disk; L10 fork hygiene; L11 Rust UI cost; L12 patch mergeability
  - **L13:** multi-model registry **already exists** (`[model.*]`, spawn > role > persona > parent); gap is **assignment UX** + do YAML wire (cross-link models-and-config)
- Linked from `docs/index.md`; living status updated (root `AGENTS.md`, `docs/current-status.md`)

### Evidence sources

- pi-ness (read-only): `packages/piness-core/src/native/*`, `docs/{prompt-system,hooks,skill-catalog,workspace,side-ask}.md`
- Fork: `crates/codegen/xai-grok-{agent,hooks,tools,subagent-resolution,codebase-graph,...}`; `docs/grok-build/*`

### Not in scope

- F-DOC-002 patch-matrix refine; F-DOC-003 capability-map
- Runtime implementation of any L* gap

### Files

- `docs/limitations.md`
- `docs/index.md`
- Root `AGENTS.md` living status + next steps
- `docs/current-status.md`
- This CHANGELOGS entry

---

## 2026-07-16 — F-GROK-001 grok-build inventory seal

**Scope:** docs only (`docs/grok-build/*`, index already linked, living status)  
**Feature:** F-GROK-001 · **VAL:** VAL-GROK-001

### Sealed

- `docs/grok-build/` complete and evidence-backed from forked tree:
  - `README.md` — section index + how to use
  - `overview.md` — crate map, entry points (pager-bin → shell headless/leader/stdio), multi-model + registry note
  - `native-tools.md` — namespaces, `ToolKind`, full builder registration list, version-managed IDs, hashline vs standard `FileToolset`
  - `extension-seams.md` — do-harness, agents, hooks, plugins, skills, config, `register_tool_pack`, MCP, subagent resolution, ACP
  - `hard-limits.md` — process + architecture limits; dual-registry ban; what not to reinvent
  - `patterns.md` — plan/goal/task/hashline/hooks/registry/MCP/scheduler/ACP patterns + anti-patterns
- All six files linked from `docs/index.md` under **Grok-build inventory**
- Living status updated (root `AGENTS.md`, `docs/current-status.md`)

### Evidence highlights (fork paths)

- `ToolRegistryBuilder::new()` registration: `crates/codegen/xai-grok-tools/src/registry/types.rs`
- `ToolNamespace` / `ToolKind`: `crates/codegen/xai-grok-tools/src/types/tool.rs`
- Agent discovery order: `crates/codegen/xai-grok-agent/src/discovery.rs`
- Subagent precedence: `crates/codegen/xai-grok-subagent-resolution/`
- Hooks: `xai-hooks-plugins-types` + `xai-grok-hooks`
- Hashline config: `xai-grok-shell/src/tools/config.rs` (`FileToolset`)

### Not in scope

- L1–L12 deep limitations rewrite (F-DOC-001)
- capability-map (F-DOC-003)
- Runtime wiring of do-harness

### Files

- `docs/grok-build/*` (six docs)
- Root `AGENTS.md` living status + next steps
- `docs/current-status.md`
- This CHANGELOGS entry

---

## 2026-07-16 — F-FORK-002 cargo check smoke seal

**Scope:** build environment + docs note (no product crate patches)  
**Feature:** F-FORK-002 · **VAL:** VAL-FORK-002

### Sealed

- `cargo check -p xai-grok-pager-bin` from `/home/datht/code/do` exits **0** (locked workspace)
- Host prerequisite: **`dotslash`** on `PATH` so repo `bin/protoc` (dotslash wrapper → protoc 29.3) executes; without it, `xai-grok-tools-api` build.rs fails
- Documented in `README.md` Build section

### Not required / not done

- No import/path source fixes were needed for check
- Full workspace `cargo test` not in scope

### Files

- `README.md` — Build requirements (`dotslash`, smoke command)
- Root `AGENTS.md` living status + next steps
- `docs/current-status.md`
- This CHANGELOGS entry

---

## 2026-07-16 — F-CTRL-001 control plane seal

**Scope:** docs / AGENTS / README / CHANGELOGS (no Rust product code)  
**Feature:** F-CTRL-001 · **VALs:** VAL-CTRL-001, VAL-CTRL-002, VAL-CTRL-003

### Added / sealed

- Root `AGENTS.md` as pi-ness-style operating contract (direction, hard constraints, customization order, gates, documentation rules, living status, models & config control)
- Docs split under `docs/` (all linked from `docs/index.md`):
  - `index.md`, `architecture.md`, `future-plan.md`, `current-status.md`
  - `milestone-ship-discipline.md`, `related-projects.md`
  - **`models-and-config.md`** — grok multi-model facts, OpenCode gap, do YAML overlay design, **L13**
  - Stubs: `prompt-system.md`, `workspace.md`
- `CHANGELOGS.md` + product-framed `README.md`
- Mission `AGENTS.md` points workers at `/home/datht/code/do/AGENTS.md` and keeps mission boundaries
- Ship discipline: verify → document under `docs/` + CHANGELOGS → conventional commit every milestone → handoff with `commitId` + `repoPath`

### Product decisions recorded

- Stock multi-model remains `~/.grok/config.toml` (many `[model.*]`, default, role/persona/spawn resolution)
- do product YAML overlay for assignment UX; map into TOML + agent frontmatter
- Multi-model assignment is a first-class M0 requirement (L13), M1 wire
- Role Tab/Shift+Tab cycle only pre-message; lock after first user message (document M0, implement M1)

### Not in this entry

- `cargo check` smoke (F-FORK-002)
- Evidence limitations / patch-matrix / capability-map (F-DOC-001..003)
- Proof agent + guided hook (F-EXT-*)
- Formal F-MODEL-001 worker seal

---

## 2026-07-16 — F-ROLE-001 role switch lock policy seal

**Scope:** docs only (AGENTS, prompt-system, architecture, status)  
**Feature:** F-ROLE-001 · **VAL:** VAL-ROLE-001

### Sealed

- **Tab / Shift+Tab** role cycle **only** at session start (empty transcript / no user messages)
- **Disabled** after first user message or any conversation content — no mid-session role hop
- Model re-assignment from role only while switch is still allowed
- **M1** is the implementation milestone (session flag, keybind gate, L1 stack freeze, role→model wire)
- M1 implementation note seeded in `docs/prompt-system.md` and `docs/architecture.md` for F-BACK-001 backlog pickup

### Files

- Root `AGENTS.md` — Hard Constraints + Session / role control + living status
- `docs/prompt-system.md` — Role lifecycle + M1 implementation note
- `docs/architecture.md` — Session / role control table + M1 note
- `docs/current-status.md` — F-ROLE-001 marked done

---

## 2026-07-16 — F-MODEL-001 multi-model + L13 seal

**Scope:** docs + do-harness YAML template (no Rust product code)  
**Feature:** F-MODEL-001 · **VALs:** VAL-MODEL-001, VAL-MODEL-002

### Sealed

- `docs/models-and-config.md` — grok multi-`[model.*]` facts with **fork evidence paths**, subagent resolution spawn > role > persona > parent, OpenCode assignment gap, do YAML schema, map to TOML + agent/role model fields, full **L13** statement; example ≥2 models and ≥3 role assignments
- `do-harness/config.models.yaml` — template with `models.registry` + `assignment` (intake/orchestrator/explorer/worker/oracle) and comments; not auto-applied in M0
- `docs/limitations.md` — L1–L13 inventory; L13 detail with evidence table
- `docs/patch-matrix.md` — every L1–L13 → path/risk/order; L13 = `config` + `agent`, low risk, M1 wire

### Product decisions confirmed

- Multi-model registry **already exists** in stock grok — do not reimplement
- Gap is assignment UX / role→model **policy** (L13)
- Dual surface: stock TOML runtime + do YAML product overlay
- M1 wires YAML assignment into agents/roles; no second runtime registry

### Files

- `docs/models-and-config.md`, `docs/limitations.md`, `docs/patch-matrix.md`, `docs/index.md`
- `do-harness/config.models.yaml`
- Root `AGENTS.md` living status, `docs/current-status.md`, this CHANGELOGS entry
