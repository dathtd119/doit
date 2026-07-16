# Backlog: M1–M3

**Status:** M0 **sealed**. **M1 sealed** (F-M1-SHIP / VAL-M1-*). **PRIV sealed** (F-PRIV-SHIP / VAL-PRIV-NOTEL|AUTH|SHIP-001). **CFG sealed** (F-CFG-SHIP / VAL-CFG-HOME|PROJECT|SHIP-001, 2026-07-16). Next: **M2**.  
**Purpose:** Ordered product backlog after M0 (limitations, patch matrix, proof extension).  
**Sources of truth for gaps:** [limitations.md](./limitations.md), [patch-matrix.md](./patch-matrix.md), [capability-map.md](./capability-map.md), [models-and-config.md](./models-and-config.md), [prompt-system.md](./prompt-system.md).

**How to use:** Work top-down within each milestone. Prefer extension seams before crate patches ([FORK.md](../FORK.md), root [AGENTS.md](../AGENTS.md) customization order). Every crate patch must land in the [patch-matrix crate log](./patch-matrix.md#crate-patch-log).

---

## Milestone map

| Milestone | Theme | Primary L* | Done when |
|-----------|--------|------------|-----------|
| **M0** | Limitations, inventory, proof extension | L10, L13 template, L6/L8 proof | Human can read docs, smoke build, run discovery verify |
| **M1** | Harness control v1 — roles, prompts, model assignment | **L1**, **L13 wire**, L2, L9, start L4 | Role cycle + lock ships; YAML assignment applies; L0–L6 map documented and partially wired |
| **M2** | Continuity & safety | **L5**, **L6 harden**, L4 | Continuation priority lanes; guided blocks product-wide |
| **M3** | Native power tools | **L7**, hashline default, L3 as needed | CodeGraph agent surface; hashline default policy |

**Binding product rules (already documented in M0 — implement on schedule):**

1. **Role switch lock (L1):** Tab / Shift+Tab role cycle **only pre-message**; **disabled** after first user message or any conversation content.  
2. **Role→model (L13):** Re-assign model from role **only while switch is still allowed**.  
3. **Dual config:** stock `~/.config/do/config.toml` (`$GROK_HOME`) = runtime multi-model; project discovery **`.do/`**; `do-harness/config.models.yaml` = product assignment overlay — do **not** invent a second runtime registry.  
4. **Guided denials (L6):** incomplete until gate is named in prompts **and** result uses `[GATE: …]` + **Do this instead**.  
5. **No OpenTUI** in M1 (L11 deferred).

---

## M1 — Roles, prompt layers, multi-model wire

**Goal:** Primary-session harness control on grok seams: role roster, post-first-message lock, role→model from do YAML, L0–L6 mapping, workspace continuum contract.

**Matrix slice:** L1 Tab lock + role roster; L13 YAML→agent wire; L2 prompt layers; L9 contract; start L4.  
**Placement default:** `agent` + `config` + `do-harness/prompts/` first; optional `crate_patch` only for session flag / keybind if seams fail.

### Ordered work items

| Order | ID | Work item | L* | Path | Depends on | Acceptance (testable) |
|------:|----|-----------|----|------|------------|------------------------|
| 1 | **M1-R01** | **Session flag `role_switch_allowed`** — true only while transcript has no user messages / no conversation content | L1 | session/shell seam; `crate_patch` only if needed | M0 policy docs | Flag flips false on first user message (or equivalent conversation content); unit/integration test or scripted session fixture |
| 2 | **M1-R02** | **Keybind gate** — Tab / Shift+Tab cycles primary-session roles **only** when flag true; ignore/no-op after lock | L1 | shell keybind + session state | M1-R01 | Pre-message: cycle works across product roster; post-message: cycle does not change active role |
| 3 | **M1-R03** | **Prompt stack freeze** — on lock, freeze L1 role layer for the session; no mid-session system/role rebuild from hop | L1, L2 | agent/prompt assembly | M1-R01 | After lock, role prompt content stable for remainder of session; new role requires new session |
| 4 | **M1-R04** | **Role roster as product agents** — `intake`, `orchestrator`, `explorer`, `worker`, `oracle` under `do-harness/agents/` (intake proof already exists; expand roster) | L1, L8 | `agent` | F-EXT-001 pattern | All five discoverable on `.do/agents/` (or documented install); tool/skill floors documented per role |
| 5 | **M1-M01** | **Wire `do-harness/config.models.yaml` → agent/role model pins** — apply `assignment.<role>` into agent frontmatter and/or `[subagents.roles.*]` / role files | **L13** | `config` + `agent` | M0 template; M1-R04 | Changing assignment + apply step updates model pins; registry names resolve to existing `[model.*]` or documented stock models; **no second runtime registry** |
| 6 | **M1-M02** | **Role→model re-resolve only while switch allowed** — on pre-message role cycle, apply assignment for new role; after lock, keep active model stack | L13 + L1 | model resolution + session | M1-R01, M1-M01 | Pre-message cycle re-pins model; post-message cycle (if attempted) does **not** re-pin; subagent spawn overrides unchanged |
| 7 | **M1-M03** | **Optional apply/validate tooling** — script or `do models validate|apply` that diffs YAML vs `config.toml` + agent frontmatter (may be shell-first) | L13 | `config` / harness script | M1-M01 | Exit non-zero on missing registry name or broken assignment; dry-run prints map |
| 8 | **M1-P01** | **L0–L6 → grok injection map (implementable contract)** — expand [prompt-system.md](./prompt-system.md) from stub to mapping table with byte-budget targets | L2 | docs + `do-harness/prompts/` | capability-map | Each layer names grok surface(s); fragments live under `do-harness/prompts/`; no full L6 disk dump into system |
| 9 | **M1-P02** | **Role-as-system (L1 layer) fragments** — per-role prompt bodies co-located with agents; co-evolve with tool floors | L1, L2 | `agent` + prompts | M1-R04, M1-P01 | Switching role (pre-message) swaps L1 fragment; gates named in role prompts where product denials apply |
| 10 | **M1-W01** | **Workspace continuum contract** — document map of goal / plan / todo onto grok session layout; decide thin `.do/` vs reuse `.grok` only | L9 | `config` + docs | M0 workspace stub | [workspace.md](./workspace.md) is non-stub contract; operators know where state lives; no dual-write without explicit decision |
| 11 | **M1-S01** | **Progressive skill presentation policy (start)** — config/ignore lists + reminder tuning so skill surface is not a firehose | L4 | `config` + `skill` | M1-P01 | Documented policy + at least one do-harness skill discovery setting that reduces dump vs stock default |
| 12 | **M1-U01** | **UX feedback for lock** — status/hint that role is locked after first message; point user to new session | L1 | shell/TUI light touch | M1-R02 | User-visible lock affordance without mid-session hop; polish may lag full TUI work |

### M1 implementation note (role lock + model) — expanded from prompt-system

Canonical six-step seed (keep in sync with [prompt-system.md](./prompt-system.md) Role lifecycle):

1. Session state flag `role_switch_allowed`  
2. Keybind gate on Tab / Shift+Tab  
3. Prompt stack freeze on lock  
4. Model re-resolve only while allowed (YAML assignment)  
5. Optional UX lock feedback  
6. Placement order: session/shell + agent profiles first; crate patch last  

### M1 non-goals

- Mid-session role hop (forbidden)  
- Second multi-model runtime that ignores `config.toml`  
- Full OpenTUI / deep pager fork  
- Product-wide guided-block standardization (M2)  
- CodeGraph product tools (M3)  
- Unified continuation coordinator (M2)

### M1 exit criteria

- [x] Tab cycle works only pre-message; locked after first user message (`verify-role-lock.sh`)  
- [x] Five product roles exist and are discoverable (`verify-roster.sh`)  
- [x] `config.models.yaml` assignment is applied (not hand-sync only) (`apply-models.py --validate`)  
- [x] Role cycle re-pins model only while switch allowed (`verify-model-resolve.sh`)  
- [x] L0–L6 map is implementable (not stub-only) (`docs/prompt-system.md` + `do-harness/prompts/`)  
- [x] Workspace continuum contract documented (`docs/workspace.md`)  
- [x] Docs + CHANGELOGS + conventional commit; handoff `commitId` + `repoPath` (**F-M1-SHIP** / VAL-M1-SHIP-001)

---

## M2 — Continuity and safety

**Goal:** Compose native goal / plan / todo into a **continuation priority** story; harden **guided denials** product-wide; deepen progressive catalog.

**Matrix slice:** L5 continuation; L6 harden; L4 progressive catalog; L11 only if explicit decision.  
**Placement default:** `hook` + session policy first; coordinator `crate_patch` only if multi-lane races remain. Use native tools — do **not** reinvent plan/goal/todo.

### Ordered work items

| Order | ID | Work item | L* | Path | Depends on | Acceptance (testable) |
|------:|----|-----------|----|------|------------|------------------------|
| 1 | **M2-C01** | **Continuation priority policy** — define lanes: interrupt → streak → goal → plan → workflow → todo (pi-ness-shaped, grok-native tools) | L5 | docs + hooks | M1-W01 | Written policy with examples; maps each lane to `update_goal` / plan mode / `todo` / `task` |
| 2 | **M2-C02** | **Session hooks / nudges** — Post-tool or session hooks that re-surface highest-priority open lane without dumping full continuum into every turn | L5 | `hook` | M2-C01 | Interrupt/resume path re-reads disk/session state; no thrash loop in scripted multi-step fixture |
| 3 | **M2-C03** | **Coordinator only if needed** — measure multi-lane races; if hooks insufficient, surgical coordinator (SessionActor / crate) | L5 | `hook` first → optional `crate_patch` | M2-C02 | Races documented; crate patch logged in patch-matrix if used |
| 4 | **M2-G01** | **Guided-block standard product-wide** — all product denials (hooks + permission surfaces we own) use `[GATE: …]` + **Do this instead** (+ human / do-not when needed) | L6 | `hook` + prompt naming | F-EXT-002 proof | No bare “Permission denied” from do-owned gates; gate names appear in system/role prompts |
| 5 | **M2-G02** | **Expand guided hook pack** — beyond dangerous shell: path policy, doom-loop, env-mask patterns as needed (pi-ness-inspired, not 1:1 TS port) | L6 | `hook` / `plugin` | M2-G01 | At least two additional guided denials with verify scripts; enablement docs |
| 6 | **M2-G03** | **Optional tools-api gate format** — only if shared denial shape cannot stay in hooks | L6 | small `crate_patch` | M2-G01 | Format shared; patch-matrix row; extension alternatives exhausted |
| 7 | **M2-S02** | **Progressive skill/MCP catalog** — dynamic mode parity direction: search/load or equivalent progressive discovery; keep MCP via `search_tool` / `use_tool` | L4 | `skill` + `config`; optional crate on skill prompt builder | M1-S01 | Default skill surface is progressive or heavily curated; firehose mode documented as opt-in if retained |
| 8 | **M2-P01** | **Permission/path policy alignment** — floors for roles (deny floors) documented and applied via agent profiles + stock permissions | L1 floors, L6 | `agent` + config | M1-R04 | Role tool allow/deny floors enforced for primary roster; aligned with guided gates |
| 9 | **M2-U01** | **Role-cycle UX polish** (optional) — only after lock policy is solid; still **no mid-session hop** | L1 | shell/TUI | M1-U01 | Polish only; lock remains binding |

### M2 non-goals

- OpenTUI dual-stream side-ask (L8 UI) — park unless explicit decision  
- Deep pager fork for continuation UI  
- Greenfield CodeGraph index  
- Replacing stock permission engine wholesale  

### M2 exit criteria

- [ ] Continuation priority policy shipped and exercised on native continuum tools  
- [ ] Guided-block shape is the product default for do-owned denials  
- [ ] Progressive skill/MCP policy reduced firehose vs M0 stock  
- [ ] Docs + CHANGELOGS + commit with `commitId` / `repoPath`

---

## M3 — Native power tools

**Goal:** Productize high-leverage navigation and edit defaults: **CodeGraph** agent surface, **hashline default** policy; fill always-on harness via tool packs only where plugins fail.

**Matrix slice:** L7 CodeGraph; hashline default; L3 tool packs as needed.  
**Placement default:** MCP / plugin wrapping existing `xai-codebase-graph` first; `tool_pack` if in-process required; hashline via `FileToolset` / config policy — do not reinvent hashline grammar.

### Ordered work items

| Order | ID | Work item | L* | Path | Depends on | Acceptance (testable) |
|------:|----|-----------|----|------|------------|------------------------|
| 1 | **M3-CG01** | **CodeGraph product surface design** — lean explore/impact tools vs MCP; cite existing crate | L7 | design + [capability-map](./capability-map.md) | M0 inventory | Written choice: MCP-first vs `tool_pack`; maps to `xai-codebase-graph` paths |
| 2 | **M3-CG02** | **Ship lean agent tools or MCP server** — explore / impact (or equivalent) usable from agent session | L7 | `plugin` / MCP / optional `tool_pack` | M3-CG01 | Agent can answer “where is X / who calls X” without full-repo grep thrash; verify script or fixture |
| 3 | **M3-H01** | **Hashline as default edit mode policy** — product default prefers hashline namespace over plain Standard where safe | hashline product | `config` + docs; toolset selection | native hashline exists | Documented default; new sessions/agents get hashline unless overridden; rollback path documented |
| 4 | **M3-H02** | **Hashline workflow docs + role floors** — when to use hashline_read/edit/grep; worker role defaults | — | docs + `agent` | M3-H01 | Worker/orchestrator guidance references hashline; capability-map updated |
| 5 | **M3-T01** | **Always-on harness via tool packs (as needed)** — re-express remaining pi-ness always-on modules that hooks cannot cover | L3 | `tool_pack` | M1–M2 surfaces | Each pack registered **before** first `ToolRegistryBuilder::new()`; no double-register; patch-matrix if crate touch |
| 6 | **M3-L01** | **LSP-driven workflows (optional)** — first-class refactors using existing `lsp` tool, not a new language stack | — | skill/workflow | M3-CG02 optional | Documented workflows only unless gap proven |

### M3 non-goals

- Greenfield graph from zero (use existing crate)  
- Full pi-ness TS factory port  
- Multi-provider auth redesign (parking lot)  
- `~/.do` rebrand unless extension path is fully proven  

### M3 exit criteria

- [ ] CodeGraph (or MCP) usable as default power navigation path  
- [ ] Hashline is product default edit policy with override  
- [ ] Any new tool packs documented; no silent crate sprawl  
- [ ] Docs + CHANGELOGS + commit with `commitId` / `repoPath`

---

## Cross-milestone dependency sketch

```
M0 sealed
  │
  ├─► M1-R01 flag ──► M1-R02 keybind ──► M1-R03 freeze ──► M1-U01 UX
  │         │
  │         └─► M1-M02 model re-resolve (with M1-M01)
  │
  ├─► M1-R04 roster ──► M1-M01 YAML wire ──► M1-M03 validate/apply
  │         │
  │         └─► M1-P02 role fragments
  │
  ├─► M1-P01 L0–L6 map ──► M1-S01 progressive skills (start)
  │         │
  │         └─► M1-W01 workspace contract ──► M2-C01 continuation policy
  │
  ├─► M2-C01..C03 continuation
  ├─► M2-G01..G03 guided blocks (builds on F-EXT-002)
  ├─► M2-S02 progressive catalog
  │
  └─► M3-CG* CodeGraph ──► M3-H* hashline default ──► M3-T01 tool packs
```

---

## Explicitly deferred (parking lot)

Parked in [future-plan.md](./future-plan.md) — promote into a milestone only with explicit decision:

| Item | Why deferred |
|------|----------------|
| Goal-as-mission full runner (validators + structured handoffs) | Needs M1–M2 continuum solid |
| Side-ask dual stream UI (L8) | High TUI cost; intake agent first |
| Config home/project rebrand (`~/.config/do` + `.do/`) | **Done (CFG sealed)** — P-CFG-HOME/PROJECT/FIXTURES + F-CFG-SHIP |
| Multi-provider auth beyond stock | Out of M0–M3 core harness (BYOK skip-OAuth shipped PRIV) |
| OpenCode-parity permission rules in do YAML | After L6 hooks + M2 floors |
| Full OpenTUI / Node port | Non-goal |
| Upstream PRs to xAI grok-build | Non-goal (private/local fork) |
| Deep pager/TUI fork | Last resort after extension exhaustion |

---

## Related

| Doc | Role |
|-----|------|
| [patch-matrix.md](./patch-matrix.md) | Gap → path / risk / order (authoritative placement) |
| [limitations.md](./limitations.md) | Evidence-backed “what is missing” |
| [capability-map.md](./capability-map.md) | pi-ness → grok surface map |
| [models-and-config.md](./models-and-config.md) | L13 design + YAML schema |
| [prompt-system.md](./prompt-system.md) | Role lifecycle + L0–L6 stub → M1 expand |
| [workspace.md](./workspace.md) | Continuum contract (M1 non-stub) |
| [architecture.md](./architecture.md) | System layout + milestone sketch |
| [future-plan.md](./future-plan.md) | Long parking lot |
| Root [AGENTS.md](../AGENTS.md) | Living status / next steps (compact) |
| Mission `mis_413072d4` | M0 seal; this backlog unblocks M1 planning |

---

## Validators

| Assertion | Claim |
|-----------|--------|
| **VAL-BACK-001** | This file lists ordered backlog for roles/prompt layers (**including multi-model role→model wiring from do YAML** and **M1 Tab/Shift+Tab role cycle with post-first-message lock**), continuation/safety, and native power tools (codegraph, hashline default). |
