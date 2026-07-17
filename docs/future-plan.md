# Future plan (parking lot)

Long-lived ideas for **doit**. Root `AGENTS.md` **Future Plan** stays short; promote items into **Next steps** when they become near-term work.

**Recheck date:** 2026-07-17 — pi-ness vs doit residual gaps re-scored after M0–M3 + CFG-DOIT + PKG seals and partial role-kernel plan (`260716-2010`).

---

## Learning sources (read-only)

**Rule:** Never edit these trees in place (VAL-CROSS-001). Absorb by re-expressing patterns into `/home/datht/code/doit` only. Cite source path when borrowing.

### Primary harness-control (pi-ness lineage)

| Path | What to learn | Key entry points |
|------|---------------|------------------|
| `/home/datht/code/pi-ness` | **Primary ideas source** — role-as-system, L0–L6 assembly, progressive catalogs, guided gates, workspace continuum, continuation, side-ask | `README.md`, `docs/{prompt-system,hooks,skill-catalog,workspace,side-ask,opencode-harnessing}.md`, `packages/piness-core/src/native/*`, `roles.ts`, `role-body-env.ts`, `role-config/*`, `packages/piness-tui/src/role-cycle.ts` |
| `/home/datht/code/pi` | Upstream pi agent runtime pi-ness builds on | `packages/`, prompt/session assembly |
| `/home/datht/code/pi-ness-old` | Historical pi-ness (`.piness` access, older continuum lessons) | only when current pi-ness lacks the pattern |
| `/home/datht/code/oh-my-pi` | OMP-style edit modes, recovery, tool UX polish | hashline/patch/apply_patch ideas |
| `/home/datht/code/pi_agent_rust` | Rust agent experiments adjacent to pi | optional; do not deep-fork blindly |
| `/home/datht/code/pi-codemode-mcp` | MCP codemode / npx resolver patterns | only if MCP friction forces it |
| `/home/datht/code/pi-dcp` | Pi DCP experiments | low priority |

### Config-control & multi-agent (OpenCode lineage)

| Path | What to learn | Key entry points |
|------|---------------|------------------|
| `/home/datht/code/opencode` | **Config ergonomics** — agent `model` pins, provider catalog, **permission rules**, Tab = agent cycle, plugin surface, subagent UX | `packages/opencode/src/config/`, `packages/opencode/src/cli/cmd/run/permission.shared.ts`, TUI agent cycle, `@opencode-ai/core` permission merge |
| `/home/datht/code/opencode-missions` | **Mission runner** — proposal → plan → run → handoff → milestone validation; orchestrator/worker/validator roster; structured handoffs | `docs/{mission-lifecycle,architecture,configuration}.md`, `src/tools/{propose_mission,start_mission_run,end_feature_run,dismiss_handoff}.ts`, `agents/`, `skills/`, `commands/` |
| `/home/datht/code/oh-my-opencode-slim` | Slim OpenCode agent/plugin patterns, role prompts | `src/`, `docs/`, schema |
| `/home/datht/code/.opencode` | Local OpenCode project config samples | operator-facing layout only |

### Base runtime & power tools

| Path | What to learn | Key entry points |
|------|---------------|------------------|
| `/home/datht/code/grok-build` | **Stock runtime** (read-only) — tools, multi-model TOML, hooks, subagents, pager | import by COPY into doit only |
| `/home/datht/code/grok-build-no-telemetry` | Privacy / no-telemetry patches already absorbed (PRIV) | re-check only on upstream re-sync |
| `/home/datht/code/codegraph` | CodeGraph lean explore/impact (pi-ness ext + MCP already mapped) | package + MCP protocol |
| `/home/datht/code/codex` | Codex permission / `--yolo` / full auto-accept patterns (D1b) | CLI permission UX |
| `/home/datht/code/herdr` | Pane / multi-session chrome ideas (alias-as-pi era) | optional; do not port TUI wholesale |
| `/home/datht/code/serena` | Semantic nav / LSP-adjacent agent tooling | optional power-tool ideas |
| `/home/datht/code/little-coder` | Small coding-agent product patterns | optional |
| `/home/datht/code/meta-harness` | Meta harness research / onboarding patterns | optional |
| `/home/datht/code/claudekit-cli` / `claudekit-engineer` | ClaudeKit skill/mission discipline (validators, journals) | process only |
| `/home/datht/code/bmad-method` | Method / phase routing (pi-ness `native/method`) | skill/agent, not engine port |
| `/home/datht/code/system-prompts-and-models-of-ai-tools` | Prompt/model catalog reference | research only |

### Mapping (product rule)

```
pi-ness (+ pi / oh-my-pi)     → harness-control ideas (roles, layers, gates, continuum)
OpenCode (+ oh-my-opencode-*) → config ergonomics (agent.model, providers, permissions, Tab=agent)
opencode-missions             → goal-as-mission runner (validators, handoffs, lifecycle)
grok-build                    → native implementation (Rust tools, multi-model TOML, agents)
doit                          → fork of grok + do-harness overlay + docs control plane
```

See also: [related-projects.md](./related-projects.md), [capability-map.md](./capability-map.md), plan matrix [`plans/260716-2010-piness-role-kernel-parity/research/piness-do-parity-matrix.md`](../plans/260716-2010-piness-role-kernel-parity/research/piness-do-parity-matrix.md).

---

## pi-ness still better than doit (2026-07-17 recheck)

What pi-ness (and OpenCode / missions where noted) still does **better** than current doit. Ordered by product impact. Status tokens match the role-kernel matrix.

### P0 — Role kernel (active plan `260716-2010`, unfinished)

| # | pi-ness / OpenCode advantage | doit today | Evidence / preferred path |
|---|------------------------------|------------|---------------------------|
| **K1** | **Role-as-system:** thin GENERAL + **role body in base stack** (`${role_body}` via `PN_ROLE_BODY_CONTENT` on Tab) | Stock `base_template()` + Extend agent body; product L0 fragment / body SoT swap **not fully live** | pi-ness `role-body-env.ts`, `session.ts` Gate D; do plan phase **02** |
| **K2** | **Hard tool surface:** `toolsDeclared` → `setActiveToolsByName` — model only sees allowed tools | Soft floors / frontmatter + hooks; schemas still largely visible (**partial → gap**) | pi-ness `native/role-tools/`; do phase **03** + TOML contracts |
| **K3** | **Single contract home:** `config_roles.jsonc` + body-only prompts | `config.roles.toml` seed + `apply-role-contracts` exist; runtime still dual-reads agents/*.md twin | do phase **05** done as seed; full D2 runtime still incomplete |
| **K4** | **Default intake** as cold-start main role | Config says `default = "intake"`; enforcement vs stock discovery still fragile | pi-ness `intakeByDefault`; do phase **04** (keys done; full cold-start seal pending **07**) |
| **K5** | **Permission default = ask**; full auto = explicit yolo | `--yolo` path exists in binary; product cold-start still often always-approve / plan without sealed ask default | OpenCode/Codex D1b; do phase **04** residual |
| **K6** | **Chrome truth:** persistent `role · model · policy`; **only role** accented | Chrome phases landed partially; residual “mode” copy / policy gold / non-persistent strip risk | pi-ness `role-accent.ts`, TUI header; do phase **06** residual + **07** verify |
| **K7** | Tab = **roles only** (OpenCode agent cycle) | M1 lock shipped; D1 roles-only target — verify Shift+Tab never policy ring post-lock | OpenCode TUI agent cycle; do D1 |

**Active workstream:** [`plans/260716-2010-piness-role-kernel-parity/`](../plans/260716-2010-piness-role-kernel-parity/) — phases **02, 03, 07** still pending; 01/04/05/06 partially completed.

### P1 — Continuum & mission quality

| # | Advantage | doit today | Source |
|---|-----------|------------|--------|
| **C1** | **Goal-as-mission full runner** — proposal → milestones → validators → structured handoffs → DONE/DONE_WITH_CONCERNS | `update_goal` + plan/todo continuum; no mission plugin lifecycle | **opencode-missions** `mission-lifecycle.md` + tools; pi-ness goal/blocker/validation natives |
| **C2** | **Interrupt-streak tracker** feeds continuation priority | M2 continuation hooks shipped; dedicated interrupt module = gap | pi-ness `native/interrupt-tracker/` |
| **C3** | **Workflow / method engines** as first-class phase machines | Plan mode + skills only (partial) | pi-ness `native/workflow/`, `native/method/`; bmad-method ideas |
| **C4** | Richer goal status (DONE_WITH_CONCERNS, blocked, partial) + hierarchy | Flat goal classifier | opencode-missions + pi-ness goal hierarchy notes |

### P2 — Catalogs, prompts, safety surface

| # | Advantage | doit today | Source |
|---|-----------|------------|--------|
| **S1** | BM25 **`skill_search` / `skill_load`** progressive pair | M2 progressive/curated defaults without BM25 product tools | pi-ness `native/skill-catalog/` |
| **S2** | Named **fragment registry + maxBytes** budgets + stop sentinel | Soft budgets in docs only | pi-ness `native/prompt-fragments/` |
| **S3** | **OpenCode permission rules** as first-class YAML/JSON merge (path + tool + mode) | Floors + hooks + `config.permissions.yaml`; not OpenCode-parity rule engine surface | OpenCode `ConfigPermissionV1` / permission merge in config |
| **S4** | Tool-alias layer (phantoms → canonical) with hidden aliases off list | Multi-namespace IDs only | pi-ness `native/tool-alias/` |
| **S5** | Context-threshold / compact triggers as explicit module | PreCompact/PostCompact hooks partial | pi-ness `native/context-threshold/` |

### P3 — Session glue & TUI (mostly parked)

| # | Advantage | doit today | Source |
|---|-----------|------------|--------|
| **T1** | **Side-ask dual stream** (stash/restore role body; side composer) | Intake agent only; dual-stream UI = gap (L8) | pi-ness `docs/side-ask.md`, TUI intake-sideask |
| **T2** | Subagent live progress in main chat (OpenCode-class cards / heartbeat) | Task wait/output tools only | OpenCode session-ui; pi-ness future-plan subagent progress |
| **T3** | Full `.piness/` disk continuum layout | Mapped contract under `.doit/` + `~/.config/doit` (different shape — accept L9) | pi-ness `native/workspace/` — **do not port layout** |
| **T4** | OpenTUI / Node harness | Rust ratatui pager — **accept** (L11 non-goal) | pi-ness-tui — **never port wholesale** |

### Already sealed in doit (do not re-park as gaps)

M1 role lock + model re-pin · M2 continuation hooks + guided blocks + progressive skills + role floors · M3 CodeGraph MCP + hashline opt-in · PRIV no-telemetry + BYOK · CFG-DOIT paths · PKG install · multi-model TOML + YAML assignment apply.

---

## Harness control (pi-ness lineage)

### Active residual (promote carefully)

- **Role-kernel finish (K1–K7):** complete plan `260716-2010` phases 02 → 03 → 07 (body swap live, strict TOML allowlist, matrix refresh)
- Goal-as-mission full runner: validators + structured handoffs on grok continuum (`update_goal` / plan / todo) — learn from **opencode-missions** lifecycle, re-express in Rust/hooks/skills (C1)
- Side-ask dual stream / intake productization (L8 / T1)
- Progressive skill/MCP BM25 `skill_search` / `skill_load` parity with pi-ness (L4 / S1; M2 sealed progressive/curated defaults without BM25 crate)
- Explicit L0–L6 fragment registry with maxBytes budgets (L2 / S2)
- Interrupt-streak product module if M2 hooks thrash under multi-lane races (C2)
- User overlay floors formalized: `~/.config/doit/prompts/roles/` + project `.doit/prompts/` body overrides (matrix §4)

### Done (keep shape)

- **M2 continuation hooks (done):** priority lanes + PostToolUse nudge thrash-safe — sealed F-M2-SHIP / VAL-M2-CONT-001. Optional crate coordinator only if multi-lane races reappear
- **M2 guided blocks (done):** product standard + path-policy + env-expose packs beyond dangerous-shell — sealed F-M2-SHIP / VAL-M2-GATE-001. Remaining: any future denials must keep the shape
- **M2 role floors (done):** five-agent allow/deny floors + guided-gate alignment — sealed F-M2-SHIP / VAL-M2-PERM-001. Remaining: OpenCode-parity permission rules YAML surface (S3)
- **M1 role lock (done):** Tab/Shift+Tab only pre-message; lock + toast after first user message; model re-pin only while switch allowed — sealed F-M1-SHIP. Remaining polish: proactive first-message toast; D1 roles-only verify

---

## Models & config (OpenCode lineage)

- **M1 YAML apply (done):** `apply-models.py` maps assignment → agent frontmatter; validate mode; re-pin only while unlocked
- Optional richer `doit models validate|apply` CLI that diffs against `~/.config/doit/config.toml`
- Effort / reasoning level pins per role when backends support them
- **OpenCode-parity permission rules** surface in do YAML/TOML (beyond floors + model assignment) — source: `/home/datht/code/opencode` permission merge (S3)
- Multi-provider auth beyond stock grok paths (deeper redesign; BYOK skip-OAuth shipped PRIV)
- Project-local model overrides (workspace config) without breaking user home registry
- Binary auto-apply of YAML assignment on cold start (today script-driven)

---

## Native power tools

- **Done (F-M3-CG / VAL-M3-CG-001):** CodeGraph MCP-first product surface wrapping `xai-codebase-graph` explore/impact — sealed F-M3-SHIP
- **Done (F-M3-HASH / VAL-M3-HASH-001):** Hashline native surface + product policy (M3 sealed as hashline default; **policy flip 2026-07-16** → product default `file_toolset = "standard"`, hashline **opt-in**; agent floors + media deny + rollback) — sealed F-M3-SHIP; SoT cleanup post-seal
- Optional later: CodeGraph in-process `tool_pack` if MCP latency/install friction forces it
- LSP-driven refactors as first-class workflows (still parking lot)
- Tool-alias product layer if multi-namespace IDs confuse models (S4)
- Extended hashline modes (OMP-style patch / apply_patch) — learn from oh-my-pi only if standard edit path fails

---

## Mission runner (opencode-missions lineage)

Parked until role-kernel P0 is honest:

- `propose_mission` / `start_mission_run` / `end_feature_run` / `dismiss_handoff` semantics on grok continuum
- Milestone validation assertions + worker handoff schema
- Orchestrator-mission slash commands (`/mission`, `/mission-plan`, `/mission-status`) as do skills/commands
- Mission disk root under `~/.local/share/doit/missions/` (mirror opencode-missions share layout; do **not** write into OpenCode paths)
- Status vocabulary: DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT (already in AGENTS protocol — wire into goal tool UX)

Sources: `/home/datht/code/opencode-missions/docs/mission-lifecycle.md`, `src/tools/*`, `agents/`, `skills/`.

---

## Product / process

- Milestone seal automation (VAL checklist → CHANGELOGS stub)
- Plugin packaging for do-harness as installable bundle
- Rebase / sync playbook vs frozen grok-build snapshots (Upstream sync checklist in root AGENTS)
- Capability-map live sync from source indexes after each parity recheck
- Cut first `v*` GitHub Release for prebuilt binstall assets
- Remove host deprecation symlinks `~/.config/do` → `doit` when operators ready

---

## Explicitly deferred (non-goals unless product pivot)

- Full OpenTUI / Node port of pi-ness TUI
- Deep pager/TUI fork before extension seams exhausted
- Upstream PRs to xAI grok-build
- Second multi-model registry (YAML overlays only; TOML remains runtime SoT)
- Mid-session role hop after first user message (do lock stays)
- Porting `.piness/` layout 1:1 (L9 accept different continuum roots)
- Keeping tools/model/color in markdown YAML frontmatter as product SoT

---

## Privacy & offline auth

### Native no-telemetry (from grok-build-no-telemetry)

- **Done (F-PRIV-NOTEL / P-NOTEL-01..06, 2026-07-16):** fail-closed SpaceXAI analytics / Mixpanel / Sentry / internal OTLP / trace upload / feedback. External OTEL via `GROK_EXTERNAL_OTEL` preserved. Scout: [`plans/reports/scout-grok-build-no-telemetry-260716.md`](../plans/reports/scout-grok-build-no-telemetry-260716.md). Patch log: [patch-matrix.md](./patch-matrix.md).

### Custom-models-only / no forced Grok OAuth

- **Done (F-PRIV-AUTH / P-AUTH-01, 2026-07-16):** config-first BYOK + `[auth] preferred_method=api_key`; crate skips `workspace_start` `ensure_authenticated` when satisfied. See [models-and-config.md](./models-and-config.md) Auth section.
- **PRIV ship sealed** (F-PRIV-SHIP / VAL-PRIV-SHIP-001, 2026-07-16).
- Remaining parked: deeper multi-provider auth redesign / full offline product mode UX

---

## Config rebrand (CFG)

- **Done (F-CFG-HOME / P-CFG-HOME):** default user home **`~/.config/doit` only** (no `~/.grok` fallback); override `GROK_HOME`
- **Done (F-CFG-PROJECT / P-CFG-PROJECT + P-CFG-FIXTURES):** project discovery **`.doit/`**; test fixtures aligned
- **Done (F-CFG-SHIP / VAL-CFG-SHIP-001):** docs + CHANGELOGS + living next → M2
- **Done (CFG-DOIT):** paths + share + MCP `doit-codegraph` — sealed brand mission
- **Done (P-BRAND-UI, 2026-07-17):** user-facing chrome + L0 identity + in-product user-guide → **Doit** (`commitId` `da03f34`). System prompt is `You are ${{ system_prompt_label }}.` (default Doit, no “released by xAI”). Does **not** rename crates, `GROK_*` env, or model slugs.

### Brand / identity follow-ups (parked after P-BRAND-UI)

| Item | Why park | Preferred path |
|------|----------|----------------|
| **Per-provider `system_prompt_label`** | OAuth / BYOK for Codex, Claude Code, etc. should set identity so the model behaves as that agent (`You are Codex…`) without a second prompt system | Map provider/agent into existing resolve tiers (`GROK_SYSTEM_PROMPT_LABEL` → per-model → `[agent]` → default). Keep L0 Minijinja `${{ system_prompt_label }}` | 
| **Install / PATH refresh** | Operators often run `~/.local/bin/doit` from an older build; rebrand is source-only until reinstall | Document: `cargo build -p doit --release` + install over `~/.local/bin/doit`; or `cargo run -p doit` from tree. On first launch after upgrade, stock extracts user-guide into `$GROK_HOME/docs/user-guide/` — stale home copies keep saying Grok until binary refresh or delete/re-extract |
| **Live home guide refresh** | Extracted `~/.config/doit/docs/user-guide/*` can lag tree until next extract | On upgrade: re-run extract path (launch new binary) or `rm -rf ~/.config/doit/docs/user-guide` then start Doit |
| **Model catalog display names** | Slug `grok-build` may still show marketing name “Grok Build” from remote/catalog | Product decision: leave as model marketing, or seed `[model.*] name` / assignment YAML display labels |
| **Auth method chrome** | ACP method id `grok.com` still labels picker **Grok** (provider, not product) | Optional: product display “xAI” / “Doit (xAI)” without renaming method id |
| **Theme ids `GrokNight` / `GrokDay`** | Technical theme keys; renaming breaks configs | Optional alias `doit-night` / keep stock ids |
| **Env rename `GROK_*` → `DOIT_*`** | High merge tax; CFG-DOIT already moved paths | Defer unless operator demand; document `GROK_HOME` as override forever if needed |
| **ASCII logo art** | Logo may still feel stock even when wordmark is Doit | Only if word “Grok” appears or product wants a new mark |
| **Central `PRODUCT_DISPLAY_NAME` constant** | P-BRAND-UI used scattered string replace; future absorb may reintroduce Grok literals | Thin composition pin + re-apply checklist on upstream merge (patch-matrix P-BRAND-UI) |

---

## How to re-score pi-ness

1. Read this file § **pi-ness still better** + [capability-map.md](./capability-map.md) §9 gap register.
2. Diff against `/home/datht/code/pi-ness/packages/piness-core/src/native/README.md` and role matrix.
3. Spot-check OpenCode permission + agent model pins; missions lifecycle if continuum work is in scope.
4. Update status tokens only with evidence (shipped / partial / gap / parked / n/a).
5. Promote into root AGENTS **Next steps** only when chosen for near-term cook.
