# Prompt system (L0–L6)

**Status:** M1 **implementable contract** (F-M1-PROMPT / VAL-M1-PROMPT-001).  
**Limitation:** **L2** (no first-class fragment registry yet — map onto stock grok surfaces).  
**Related:** [capability-map.md](./capability-map.md) §3, [workspace.md](./workspace.md), [models-and-config.md](./models-and-config.md).

## Intent

pi-ness-style **layered prompt assembly** so operators and implementers can reason about what the model sees, without inventing a second prompt runtime. **do** maps L0–L6 onto stock grok inject points; product text lives under `do-harness/`.

**Model-facing vs operator:** the model must learn the **harness** (tools, gates, continuum, role mission) — not the prompt *system* (layer maps, wire checklists, phase ids). L0–L6 numbering is **operator documentation only**; never inject it into `l0-*.md` / `roles/*.md` as self-description.

**Prompts SoT:** `do-harness/prompts/` in the repo. Home config is **config-only** (`scripts/sync-user-config.sh` → `~/.config/doit/config.toml`). Do not sync prompts into `~/.config/doit`.

**Numbering:** This document uses **do’s L0–L6** (role = **L1**, freeze target). pi-ness uses a different number for “role body” (their L4). Map by **purpose**, not number — see [capability-map.md](./capability-map.md) §3.

**pi-ness construction (learned):** shell `SYSTEM.md` + `SYSTEM_GENERAL` via env + `${role_body}` + sequential `${}` replace in patched `system-prompt.js`; role tools/model in role-config, not prompt YAML. Report: [`plans/reports/2026-07-16-piness-prompt-construction.md`](../plans/reports/2026-07-16-piness-prompt-construction.md).

| Layer | Working name | Purpose | Product home |
|-------|--------------|---------|--------------|
| **L0** | Kernel / safety | Stock general + product harness (once) | **Live today:** crate `templates/prompt.md` via `base_template()`. **Product SoT:** `l0-general.md` (`${l0_general}`), `l0-kernel.md` (`${l0_kernel}`), shell `l0-system.md`. Catalog: `placeholders.md` |
| **L1** | Role | Role-static identity / can-cannot / workflow / style | `do-harness/prompts/roles/*` — one `You are **Role**` line OK; no gate catalog, no skills dump; tools/model from `[roles.*]` |
| **L2** | Workspace / project | Project AGENTS, docs, continuum pointers | Project `AGENTS.md` via `agentsMd: true`; [workspace.md](./workspace.md) |
| **L3** | Tools | Tool catalog / contracts (when / when-not) | Stock tool descriptions; **TOML** `[roles.<stem>].tools` / `disallowed_tools` (D2) |
| **L4** | Skills | Skill list or progressive skill surface | Skill discovery + reminders; progressive/curated default (M2 advanced) |
| **L5** | Session | Goal / plan / todo pointers (not full bodies) | Native continuum tools; short injects / reminders |
| **L6** | Turn | Ephemeral: gate results, user message framing, mode notices | PreToolUse deny reasons, plan-mode tool hints, user turn |

Exact stock assembly is **system + agent prompts + skills + plugins + reminders** — not a named L0–L6 registry. Gap **L2**: fragment maxBytes registry is optional later; budgets below are **discipline targets**, not hard CI fails in M1.

---

## L0–L6 → grok injection map (implementable)

| Layer | Grok inject surface (fork evidence) | do product text / config | Byte-budget target (soft) | M1 wire state |
|-------|-------------------------------------|--------------------------|---------------------------|---------------|
| **L0** | `base_template()` today; target = render `l0-system.md` with `${}` expand | Product SoT: `l0-general.md` + `l0-kernel.md` + `l0-system.md`; placeholders in `placeholders.md` | general ~4.6 KiB; product rules ≤ ~4 KiB | **Stock live**; product stack **extracted**, wire phase 02 |
| **L1** | Agent `prompt_body` **appended** after stock base (`promptMode: extend`) | Body: `prompts/roles/<role>.md`; contract: `config.toml` `[roles.<role>]` (seed `config.roles.toml`) | ≤ **12 KiB** per role body | **Roster + lock shipped**; swap body + TOML SoT in plan 260716-2010; **never Full for roster** |
| **L2** | `agentsMd: true` → project `AGENTS.md` (and nested) into context (`xai-grok-agent` prompt `agents_md`) | Root `AGENTS.md` + `docs/` | Prefer pointer + short rules; full AGENTS as discovered | **Mapped** — keep product rules compact in root AGENTS |
| **L3** | Tool `description` / schema; role tool allow/deny | **`[roles.*].tools` / `disallowed_tools`** in config.toml + [role-permissions.md](./role-permissions.md); bridge still in agent frontmatter until strict schema filter (phase 03) | Per-tool: keep descriptions lean | **M2 floors** + **TOML SoT (D2)**; strict visibility gap → plan phase 03 |
| **L4** | Skill tool listing + `SkillDiscoveryReminder` | [progressive-skills.md](./progressive-skills.md) + `do-harness/config.skills.yaml` + agent `discoverSkills` (M2-S02) | Avoid full skill dump; progressive/curated default | **M2 advanced** — all five roles progressive/curated; firehose opt-in; MCP `search_tool`/`use_tool` |
| **L5** | Goal/plan/todo tool results + session state; reminders | Native `update_goal`, plan mode, `todo_write`; [workspace.md](./workspace.md) | **Pointers only** in system; re-read disk/session — no full plan paste | **Mapped tools**; unified continuation = M2 |
| **L6** | Hook deny `reason`, plan enter/exit tool output, user message wrappers | Guided hooks (`[GATE: …]`); turn framing | Gate deny: short + **Do this instead** | **M0 proof hook**; product-wide pack M2 |

### Assembly sketch (primary session)

**Current (stock + product bridge):**

```
base_template()  = templates/prompt.md     ← LIVE core ("You are Grok…")
  + prompt_body  =
      Identity block (product roles only — active role / policy / mission pointer)
      + agent.md / roles/<stem>.md body    ← role mission; swap pre-message (Extend)
  # product l0-system.md / l0-kernel.md extracted — full expander still phase 02
  + L2–L6 as today
```

**Cold-start agent (config-driven):** `config.toml` `[agent] name` → else
`[roles].default` (product seed: `intake`; set any roster stem) when discoverable
under `.doit/agents` or `~/.config/doit/agents` → else stock `grok-build-plan`.
Pager chrome seeds from the same `[roles].default`. Change default without code:

```toml
[roles]
default = "worker"   # or intake | orchestrator | explorer | oracle

[agent]
name = "worker"      # optional; sync-user-config aligns with roles.default
```

Identity is injected at session create and on Tab `set_mode` via
`ensure_product_role_identity` so the model can name its role.

**Target (pi-ness stack / plan 260716-2010):**

```
render(l0-system.md) with:
  ${l0_general}   ← l0-general.md   (stock general)
  ${l0_kernel}    ← l0-kernel.md    (harness rules + gates, once)
  Identity: ${agent} ${role} ${policy}   (no model)
  ${role_body}    ← prompts/roles/<stem>.md
  Session: ${date} ${cwd} ${os} ${shell}
  + MiniJinja ${{ tools.by_kind.* }} inside general
  + tools/model/color from config.toml [roles.<stem>]
  + tool schemas ⊆ allowlist
  + L2 AGENTS + L4 skills (separate inject) + L5/L6 as today
```

Product customizes **`l0-general.md`**, not the encrypted crate blob. Sync from
upstream with `bash do-harness/scripts/sync-l0-general.sh`. Placeholder catalog:
[`do-harness/prompts/placeholders.md`](../do-harness/prompts/placeholders.md).

**Ownership (no duplication):**

| Layer | Owns |
|-------|------|
| l0-general | Stock safety / tools / style — one “You are …” stock opening |
| l0-kernel | Product gates + continuum rules + role-lock |
| Identity | agent / role / policy only |
| role_body | You are / are not, can-cannot, workflow, style, routing (orch) — **not** gates or skills |
| Session | date / cwd / os / shell |

**Rules:**

1. **Do not** dump full L5/L6 continuum bodies into always-on system text — tools and disk re-read exist for that ([workspace.md](./workspace.md)).
2. **Do not** invent a second multi-model registry — pins from `[roles.*].model` / `[model.*]` ([models-and-config.md](./models-and-config.md)).
3. **Do not** put tools/model/color in prompt markdown YAML headers — **TOML only** (D2).
4. **Do not** replace stock `prompt.md` with an invented product kernel. Product L0 is append-or-deliberate-template-patch only.
5. **Do not** use `promptMode: full` for product roster (drops stock base).
6. **Do not** re-list gate catalog or skill firehoses inside role bodies. One Mission identity line (`You are **role**`) is allowed; Identity block still names agent/role/policy.
7. **Do not** inject skill dumps into role bodies — progressive skills are a later system inject.
8. **Fragment registry / hard maxBytes** = future crate only if extension budgets fail (L2 gap). Soft budgets above are authoring discipline.

**Parity matrix:** [`plans/260716-2010-piness-role-kernel-parity/research/piness-do-parity-matrix.md`](../plans/260716-2010-piness-role-kernel-parity/research/piness-do-parity-matrix.md).  
**System prompt truth:** [`plans/260716-2010-piness-role-kernel-parity/research/system-prompt-truth.md`](../plans/260716-2010-piness-role-kernel-parity/research/system-prompt-truth.md) · [code-analysis/system-prompt-assembly.md](../code-analysis/system-prompt-assembly.md).

### Stock grok today (evidence)

| Surface | Fork path (representative) |
|---------|----------------------------|
| Agent discovery | `crates/codegen/xai-grok-agent/src/discovery.rs` — project `.doit/agents/`, `~/.config/doit/agents/` |
| Agent def + `promptMode` / `agentsMd` | `crates/codegen/xai-grok-agent/src/config.rs` (`AgentDefinition`) |
| Prompt context assembly | `crates/codegen/xai-grok-agent/src/prompt/context.rs` |
| Skills listing | `crates/codegen/xai-grok-agent/src/prompt/skills.rs`; `SkillDiscoveryReminder` in tools registry |
| Hooks (L6 denials) | `xai-grok-hooks` + project `.doit/hooks/` |
| Continuum tools | `implementations/grok_build/{update_goal,enter_plan_mode,exit_plan_mode,todo}/` |

---

## Role lifecycle

**Binding product rule** (OpenCode-like Tab / Shift+Tab role cycle; keep context clean). Documented M0 (**VAL-ROLE-001**); **implement lock in M1** (F-M1-LOCK).

| Phase | Role cycle (Tab / Shift+Tab) | System / role stack | Role→model re-assignment |
|-------|------------------------------|---------------------|---------------------------|
| **Pre-message** — session start, empty transcript, no user messages yet | **Allowed** | Role may change; **L1** role layer swaps | **Allowed** — apply assignment for newly selected role |
| **Post-message** — after first user message **or** any conversation content | **Disabled** | **Frozen** for this session | **Blocked** — do not re-pin model mid-session via role hop |

### Rules

1. **Only at session start** may the user cycle roles (Tab / Shift+Tab).
2. **After the first user message** (or any non-empty conversation content), role switching is **off** — no mid-session role hop that rewrites the system/role stack.
3. To change role after work has started: **start a new session** (do not thrash mid-transcript).
4. Model resolution from role assignment applies only while switch is still allowed; spawn overrides remain separate (subagent path: spawn > role > persona > parent).
5. Full TUI polish may lag; the **lock policy is mandatory** whenever role-cycle UI exists (never ship cycle without the lock).

### What freezes on lock

| Layer | On lock |
|-------|---------|
| **L0** | Unchanged (kernel is session-stable) |
| **L1** | **Frozen** — no Tab hop rebuild |
| **L2–L4** | May still update via tools/discovery as stock grok does |
| **L5–L6** | Continue to change every turn (continuum + gates + user) |

### M1 implementation note (role lock + model)

Ordered work — full backlog: [backlog-m1-m3.md](./backlog-m1-m3.md).

1. **Session state flag** — `role_switch_allowed` (true only while transcript has no user messages / no conversation content).
2. **Keybind gate** — Tab / Shift+Tab cycle primary-session roles **only** when the flag is true; no-op after lock.
3. **Prompt stack freeze** — on lock, freeze **L1** for the session; do not rebuild system/role prompts from a mid-session hop.
4. **Model re-resolve** — apply do YAML / agent role→model assignment **only** while switch is allowed; after lock, keep active model stack (spawn overrides for subagents unchanged).
5. **UX feedback** — status/hint that role is locked after first message; point user to new session.
6. **Placement order** — prefer session/shell + agent profile seams; crate patch only if keybind/session flag cannot land via extension.

Related gaps: **L1** (primary-session role machine), **L13** (role→model assignment wiring).

---

## Product roster (L1 roles)

Five primary-session roles.

| Role | Contract (TOML) | Body (L1) | Bridge agent | Mission (one line) |
|------|-----------------|-----------|--------------|--------------------|
| **intake** | `[roles.intake]` | `prompts/roles/intake.md` | `agents/intake.md` | Clarify intent; Intent Pack; no implementation |
| **orchestrator** | `[roles.orchestrator]` | `prompts/roles/orchestrator.md` | `agents/orchestrator.md` | Own goal/plan/todo; spawn specialists |
| **explorer** | `[roles.explorer]` | `prompts/roles/explorer.md` | `agents/explorer.md` | Scout maps / citations; read-only |
| **worker** | `[roles.worker]` | `prompts/roles/worker.md` | `agents/worker.md` | Implement + verify within scope |
| **oracle** | `[roles.oracle]` | `prompts/roles/oracle.md` | `agents/oracle.md` | Architecture / hard decisions; no bulk edit |

**Authoring rule (D2):** edit **`config.roles.toml` / `[roles.*]`** for tools/model/color; edit **`prompts/roles/*.md`** for mission text; run `apply-role-contracts.sh --apply` so agent frontmatter stays a faithful bridge. Do not put product config YAML on prompt files.

Pre-message role switch → load matching role → body + contract change → model re-pin from `[roles.<role>].model` while switch allowed.

**Control (D1 / D1b):** Tab/Shift+Tab = **roles only** (never policy ring). Permission default = **ask**; full auto-accept = **`--yolo`**.

---

## Named gates (must appear in prompts)

Guided denials are incomplete until (1) the gate is **named** in system/role prompts and (2) the result uses `[GATE: …]` + **Do this instead**. Never bare “Permission denied” for do-owned gates.

Canonical list (M0 proof + product rule): `do-harness/prompts/gates.md`.

| Gate id | Surface | Milestone |
|---------|---------|-----------|
| `dangerous-shell-sudo-rm` | PreToolUse shell hook | M0 proof |
| `dangerous-shell-rm-root` | PreToolUse shell hook | M0 proof |
| `dangerous-shell-pkill` | PreToolUse shell hook | M0 proof |
| `dangerous-shell-mkfs` | PreToolUse shell hook | M0 proof |
| `dangerous-shell-dd-device` | PreToolUse shell hook | M0 proof |
| `dangerous-shell-fork-bomb` | PreToolUse shell hook | M0 proof |
| `dangerous-shell-device-redirect` | PreToolUse shell hook | M0 proof |

Additional product gates (path policy, doom-loop, …) land in **M2** guided pack; add ids to `gates.md` and L0/L1 when they ship.

L0 and every L1 role fragment **must** reference the guided-block shape and point at named gates (at least the dangerous-shell family until M2 expands).

---

## do-harness/prompts layout

```
do-harness/prompts/
  README.md           # install + ownership map
  placeholders.md     # operator ${} catalog
  l0-system.md        # shell: ${l0_general} → ${l0_kernel} → Identity → ${role_body} → Session
  l0-general.md       # stock general (${l0_general})
  l0-kernel.md        # harness rules + gates (${l0_kernel})
  gates.md            # named gate catalog (operator)
  roles/
    intake.md
    orchestrator.md
    explorer.md
    worker.md
    oracle.md
```

Agents under `do-harness/agents/` remain the **runtime discovery bridge** (frontmatter regenerated from TOML). Role fragments under `prompts/roles/` are **body-only** mission / workflow / style — no gate catalog, no skills dump. Floors/model/color: [`docs/models-and-config.md`](./models-and-config.md) § Role contracts + [`role-permissions.md`](./role-permissions.md) (F-M2-PERM).

---

## Direction (remaining L2 work)

1. Keep this map current when inject points change in the fork.
2. Prefer agent profiles + `do-harness/prompts/` over crate prompt forks.
3. Implement role lifecycle lock with F-M1-LOCK (session flag + keybind + freeze).
4. Crate patch only if hard fragment budgets / registry cannot be achieved via extension.
5. Progressive skill surface (L4): **shipped M2-S02** progressive/curated default + firehose opt-in — see [progressive-skills.md](./progressive-skills.md).

---

## Related

- [architecture.md](./architecture.md) L1 / L2 / Session role control  
- [models-and-config.md](./models-and-config.md) — model re-resolve only when role switch allowed  
- [workspace.md](./workspace.md) — continuum disk/session layout (L5/L9)  
- [progressive-skills.md](./progressive-skills.md) — L4 progressive/curated presentation (M2 advanced)  
- [capability-map.md](./capability-map.md) — pi-ness ↔ grok layer map  
- [limitations.md](./limitations.md) L2 / L4  
- Root [AGENTS.md](../AGENTS.md) Hard Constraints + Session / role control  
- [do-harness/prompts/](../do-harness/prompts/) — fragments  
- [backlog-m1-m3.md](./backlog-m1-m3.md) M1-P01 / M1-P02 / M1-S01  
