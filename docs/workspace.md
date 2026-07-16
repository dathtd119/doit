# Workspace continuum contract

**Status:** M1 **non-stub contract** (F-M1-PROMPT / VAL-M1-WORK-001; backlog M1-W01).  
**Limitation:** **L9** (layout differs from pi-ness `.piness/`).  
**Continuation priority (unified coordinator):** **L5** — product policy in M2; tools already exist.

## Intent

A durable **session continuum** so long work survives interrupts. Operators and agents must know **where state lives** and **which tools own it**. **do** maps product semantics onto **product project `.do/` + user home `~/.config/do` session layout** (CFG sealed) — not a parallel `.piness/` tree.

| Concept | Operator meaning | Stock grok surface | Tool(s) |
|---------|------------------|--------------------|---------|
| **Goal** | What success looks like; progress / blocked | Session goal handle + classifier | `update_goal` |
| **Plan** | Ordered approach before large edits | Project plan file | `enter_plan_mode` / `exit_plan_mode` |
| **Todo** | Atomic next actions | In-session todo state | `todo_write` |
| **Role** | Who is acting (primary session) | Agent profile discovery | Tab cycle pre-message only |
| **Model** | Which model for this role | `config.toml` + assignment YAML | [models-and-config.md](./models-and-config.md) |
| **Task** | Specialist subagent | Task spawn + wait/output | `task` / Agent(…) |

---

## Binding decision (CFG): product `.do/` + `~/.config/do`

| Option | Decision |
|--------|----------|
| **Project discovery root** | **`.do/`** (agents, hooks, plan, config, skills, …) — **P-CFG-PROJECT** |
| **User home** | **`~/.config/do` only** when `GROK_HOME` unset — **P-CFG-HOME** (no silent `~/.grok` fallback) |
| **M1 historical note** | M1 documented reuse of stock `.grok` until CFG rebrand; that default is **superseded** |
| **Dual-write** (`.do/` **and** `.grok/` same continuum) | **Forbidden** without an explicit product decision and docs update |

**Rationale:** CFG rebranded discovery roots to product brand paths while keeping **single-writer** native tools (plan file, sessions, goal/todo). Vendor compat dirs (e.g. `.claude/`) still walk where already coded. Env override: **`GROK_HOME`** replaces the full user home root.

pi-ness comparison (ideas only; do **not** port layout): `.piness/session/<id>/{todos,active-plan,active-goal}.json` + project `plans/` / `goals/`. See limitations L9.

---

## Where continuum state lives

### Project tree (cwd / git root)

| State | Path | Owner tool | Notes |
|-------|------|------------|-------|
| **Active plan file** | `<cwd>/.do/plan.md` | `enter_plan_mode` / `exit_plan_mode` | Constant `PLAN_FILE_RELATIVE_PATH` in fork (`xai-grok-tools` resources). Default when no override. |
| **Project agents** | `<cwd>/.do/agents/*.md` | Agent discovery | do roster via symlink to `do-harness/agents/` |
| **Project hooks** | `<cwd>/.do/hooks/*.json` | Hook discovery | e.g. guided dangerous-shell |
| **Project config** | `<cwd>/.do/config.toml` (optional) | Config load | Merges with user `~/.config/do` per product rules |

### User home (product default)

| State | Path | Owner | Notes |
|-------|------|-------|-------|
| **User home** | `$GROK_HOME` or `~/.config/do` | Config / runtime | Multi-model TOML, user agents/hooks; **no** default `~/.grok` |
| **Sessions by CWD** | `~/.config/do/sessions/<encoded-cwd>/` | Session runtime | `sessions_cwd_dir` — URL-encoded or hash slug for long paths |
| **Session instance** | `…/sessions/<encoded-cwd>/<session-id>/` | Session runtime | `session_dir(info)` — transcript, images, session-local artifacts |
| **User agents / hooks** | `~/.config/do/agents/`, `~/.config/do/hooks/` | Discovery | Lower precedence than project for agents (project shadows) |

### In-memory / session-bound (not a second disk continuum)

| State | Storage | Tool | Notes |
|-------|---------|------|-------|
| **Todos** | Session tool state (`TodoState` on tool resources) | `todo_write` | Not a separate do-owned `todos.json` outside session lifecycle. Persist/resume via stock session APIs. |
| **Active goal** | Goal update handle + classifier path | `update_goal` | “No active goal” if handle not registered — use the tool, don’t invent a parallel goal DB. |

**Operator rule:** To inspect continuum, open **`<project>/.do/plan.md`**, use the product UI/session for goal/todo, and look under **`~/.config/do/sessions/<encoded-cwd>/<session-id>/`** for session files — not a project `.piness/` tree and not a dual-written `.grok/` continuum.

---

## Concept → tool → location map

```
User intent
  → Role (L1 agent profile) — pre-message Tab only
  → Goal          update_goal          → session goal handle (not dual-written)
  → Plan          enter/exit plan mode → <cwd>/.do/plan.md
  → Todo          todo_write           → session TodoState
  → Specialist    task / Agent(…)      → subagent session; spawn model overrides
```

| Lane | Read with | Write with | Disk / session |
|------|-----------|------------|----------------|
| Goal | `update_goal` status / UI | `update_goal` | Session goal system (stock) |
| Plan | read `.do/plan.md` | plan mode tools + file edit | `<cwd>/.do/plan.md` |
| Todo | todo tool / UI | `todo_write` | Session state |
| Role | active agent | Tab pre-message / new session | Agent files under `.do/agents` |
| Model | assignment + TOML | apply script + config | YAML overlay → frontmatter; TOML runtime |

---

## L5 prompt rule (do not paste full continuum)

Aligned with [prompt-system.md](./prompt-system.md) L5/L6:

1. System/role prompts carry **pointers and rules**, not full plan/goal bodies.
2. Models **re-read** plan file and continuum tools when resuming.
3. Gate results and user turns are **L6** (ephemeral) — not frozen with L1.

---

## Continuation priority (M2 — shipped policy)

Product lanes (pi-ness-shaped, grok-native tools):

```
interrupt → streak → goal → plan → workflow → todo
```

**Canonical policy + thrash rules + verify:** [continuation.md](./continuation.md) (**F-M2-CONT** / VAL-M2-CONT-001).

| Lane | Surface |
|------|---------|
| Interrupt / streak | Session hook state under `.do/continuation/` (nudge engine; not a dual continuum DB) |
| Goal | `update_goal` + PostToolUse continuation hook |
| Plan | `.do/plan.md` + plan mode + hooks |
| Workflow | Skill/method pointer (optional) |
| Todo | `todo_write` + hooks |

**Operators:** on resume, re-read highest open lane only (policy order). Hooks re-surface a **short** pointer — never full plan/goal/todo dump every turn.

---

## Subagent / work context convention

When spawning specialists (`task` / Agent):

| Field | Convention |
|-------|------------|
| **Work context** | Primary git/cwd root of the files being changed |
| **Reports** | `{work_context}/plans/reports/` when project uses that layout |
| **Plans (human docs)** | `{work_context}/plans/` or mission paths — **not** a dual continuum DB |
| **Child prompt** | Scoped files + acceptance criteria; **omit** full parent chat history |

Subagents use stock resolution (spawn > role > persona > parent) for models. Continuum ownership for multi-step work stays with **orchestrator** (or human) unless explicitly handed off.

---

## Anti-patterns

| Don’t | Do instead |
|-------|------------|
| Dual-write continuum to `.do/` **and** `.grok/` / `.piness/` | Single writer: native tools + `.do/` + `~/.config/do` session layout |
| Paste entire plan into system prompt every turn | Point at `.do/plan.md`; re-read |
| Mid-session Tab role hop to “switch continuum owner” | New session for new role (L1 freeze) |
| Second multi-model registry for continuum | TOML runtime + YAML assignment only |
| Bare “Permission denied” thrash on continuum tools | Guided `[GATE: …]` + **Do this instead** for do-owned denials |

---

## Evidence (fork)

| Fact | Path |
|------|------|
| Session dir | `crates/codegen/xai-grok-shared/src/session/mod.rs` → `sessions_cwd_dir(cwd)/{id}` |
| Sessions CWD encoding | `crates/codegen/xai-grok-config/src/paths.rs` (`sessions_cwd_dir`, `encode_cwd_dirname`) |
| Plan file default | `crates/codegen/xai-grok-tools/src/types/resources.rs` — `PLAN_FILE_RELATIVE_PATH = ".do/plan.md"` |
| Continuum tools | `implementations/grok_build/{update_goal,enter_plan_mode,exit_plan_mode,todo}/` |
| Patterns | [grok-build/patterns.md](./grok-build/patterns.md) § Plan / update_goal |
| Capability map | [capability-map.md](./capability-map.md) §5 |

---

## Related

- [prompt-system.md](./prompt-system.md) — L5/L6 and role freeze  
- [architecture.md](./architecture.md) — continuum in system layout  
- [limitations.md](./limitations.md) L5, L9  
- [backlog-m1-m3.md](./backlog-m1-m3.md) M1-W01, M2 continuation  
- [models-and-config.md](./models-and-config.md) — model assignment, not continuum disk  
