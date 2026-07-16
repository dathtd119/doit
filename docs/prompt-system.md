# Prompt system (L0–L6)

**Status:** M1 **implementable contract** (F-M1-PROMPT / VAL-M1-PROMPT-001).  
**Limitation:** **L2** (no first-class fragment registry yet — map onto stock grok surfaces).  
**Related:** [capability-map.md](./capability-map.md) §3, [workspace.md](./workspace.md), [models-and-config.md](./models-and-config.md).

## Intent

pi-ness-style **layered prompt assembly** so operators and implementers can reason about what the model sees, without inventing a second prompt runtime. **do** maps L0–L6 onto stock grok inject points; product text lives under `do-harness/`.

**Numbering:** This document uses **do’s L0–L6** (role = **L1**, freeze target). pi-ness uses a different number for “role body” (their L4). Map by **purpose**, not number — see [capability-map.md](./capability-map.md) §3.

| Layer | Working name | Purpose | Product home |
|-------|--------------|---------|--------------|
| **L0** | Kernel / safety | Non-negotiable identity + guided-gate rules | `do-harness/prompts/l0-kernel.md` + hard constraints in root `AGENTS.md` |
| **L1** | Role | Active role contract (who acts now) | `do-harness/prompts/roles/*` + `do-harness/agents/*.md` bodies |
| **L2** | Workspace / project | Project AGENTS, docs, continuum pointers | Project `AGENTS.md` via `agentsMd: true`; [workspace.md](./workspace.md) |
| **L3** | Tools | Tool catalog / contracts (when / when-not) | Stock tool descriptions in registry; role `tools` / `disallowedTools` floors |
| **L4** | Skills | Skill list or progressive skill surface | Skill discovery + reminders; progressive/curated default (M2 advanced) |
| **L5** | Session | Goal / plan / todo pointers (not full bodies) | Native continuum tools; short injects / reminders |
| **L6** | Turn | Ephemeral: gate results, user message framing, mode notices | PreToolUse deny reasons, plan-mode tool hints, user turn |

Exact stock assembly is **system + agent prompts + skills + plugins + reminders** — not a named L0–L6 registry. Gap **L2**: fragment maxBytes registry is optional later; budgets below are **discipline targets**, not hard CI fails in M1.

---

## L0–L6 → grok injection map (implementable)

| Layer | Grok inject surface (fork evidence) | do product text / config | Byte-budget target (soft) | M1 wire state |
|-------|-------------------------------------|--------------------------|---------------------------|---------------|
| **L0** | Default system / base agent stack; permission + hooks always-on | `do-harness/prompts/l0-kernel.md`; root `AGENTS.md` Hard Constraints | ≤ **4 KiB** always-on product kernel (prefer short) | **Docs + fragment** — not a separate crate registry |
| **L1** | Agent profile markdown body after YAML frontmatter; `promptMode: extend` appends role body onto base | `do-harness/agents/<role>.md` (discovery) + `do-harness/prompts/roles/<role>.md` (canonical L1 fragment) | ≤ **12 KiB** per role body | **Roster shipped**; pre-message cycle swaps agent → L1; freeze on lock (F-M1-LOCK) |
| **L2** | `agentsMd: true` → project `AGENTS.md` (and nested) into context (`xai-grok-agent` prompt `agents_md`) | Root `/home/datht/code/do/AGENTS.md` + `docs/` | Prefer pointer + short rules; full AGENTS as discovered | **Mapped** — keep product rules compact in root AGENTS |
| **L3** | Tool `description` / schema in `ToolRegistryBuilder`; role tool allow/deny lists | Agent frontmatter `tools` / `disallowedTools`; stock tool docs | Per-tool: keep descriptions lean | **Mapped** — floors on five agents (M1 stub OK) |
| **L4** | Skill tool listing + `SkillDiscoveryReminder` | [progressive-skills.md](./progressive-skills.md) + `do-harness/config.skills.yaml` + agent `discoverSkills` (M2-S02) | Avoid full skill dump; progressive/curated default | **M2 advanced** — all five roles progressive/curated; firehose opt-in; MCP `search_tool`/`use_tool` |
| **L5** | Goal/plan/todo tool results + session state; reminders | Native `update_goal`, plan mode, `todo_write`; [workspace.md](./workspace.md) | **Pointers only** in system; re-read disk/session — no full plan paste | **Mapped tools**; unified continuation = M2 |
| **L6** | Hook deny `reason`, plan enter/exit tool output, user message wrappers | Guided hooks (`[GATE: …]`); turn framing | Gate deny: short + **Do this instead** | **M0 proof hook**; product-wide pack M2 |

### Assembly sketch (primary session)

```
Stock base system
  + L0 product kernel (identity, guided-gate rule, role-lock rule)
  + L1 active role body          ← swapped only while role_switch_allowed
  + L2 AGENTS.md section         ← agentsMd
  + L3 tool list / floors        ← registry + agent tools fields
  + L4 skill surface             ← discovery / reminders (progressive)
  + L5 continuum pointers        ← goal/plan/todo tools & session files
  + L6 turn injects              ← gate results, user turn, mode notices
```

**Rules:**

1. **Do not** dump full L5/L6 continuum bodies into always-on system text — tools and disk re-read exist for that ([workspace.md](./workspace.md)).
2. **Do not** invent a second multi-model registry for prompts — model pins come from assignment YAML → agent frontmatter ([models-and-config.md](./models-and-config.md)).
3. **Fragment registry / hard maxBytes** = future crate only if extension budgets fail (L2 gap). Soft budgets above are authoring discipline.

### Stock grok today (evidence)

| Surface | Fork path (representative) |
|---------|----------------------------|
| Agent discovery | `crates/codegen/xai-grok-agent/src/discovery.rs` — project `.do/agents/`, `~/.config/do/agents/` |
| Agent def + `promptMode` / `agentsMd` | `crates/codegen/xai-grok-agent/src/config.rs` (`AgentDefinition`) |
| Prompt context assembly | `crates/codegen/xai-grok-agent/src/prompt/context.rs` |
| Skills listing | `crates/codegen/xai-grok-agent/src/prompt/skills.rs`; `SkillDiscoveryReminder` in tools registry |
| Hooks (L6 denials) | `xai-grok-hooks` + project `.do/hooks/` |
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

Five primary-session roles. Discovery: `do-harness/agents/` → project `.do/agents/` (see `do-harness/README.md`).  
Canonical **L1 fragments** (swap targets): `do-harness/prompts/roles/`.

| Role | Agent profile | L1 fragment | Mission (one line) |
|------|---------------|-------------|--------------------|
| **intake** | `agents/intake.md` | `prompts/roles/intake.md` | Clarify intent; Intent Pack; no implementation |
| **orchestrator** | `agents/orchestrator.md` | `prompts/roles/orchestrator.md` | Own goal/plan/todo; spawn specialists |
| **explorer** | `agents/explorer.md` | `prompts/roles/explorer.md` | Scout maps / citations; read-only |
| **worker** | `agents/worker.md` | `prompts/roles/worker.md` | Implement + verify within scope |
| **oracle** | `agents/oracle.md` | `prompts/roles/oracle.md` | Architecture / hard decisions; no bulk edit |

**Co-evolution rule:** Agent profile body and `prompts/roles/<role>.md` stay aligned. Discovery load path remains the agent file; fragments are the named L1 layer for docs, freeze policy, and future inject control.

Pre-message role switch → load matching agent profile → L1 content changes → model pin from `assignment.<role>` while switch allowed.

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
  README.md           # install + layer map
  l0-kernel.md        # L0 fragment
  gates.md            # named gate catalog
  roles/
    intake.md
    orchestrator.md
    explorer.md
    worker.md
    oracle.md
```

Agents under `do-harness/agents/` remain the **runtime discovery** profiles (`promptMode: extend`, tool floors, model pin). Role fragments under `prompts/roles/` are the **L1 contract** text for assembly reasoning and freeze policy.

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
