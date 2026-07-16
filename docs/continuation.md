# Continuation priority policy

**Status:** M2 product policy (**F-M2-CONT** / **VAL-M2-CONT-001**).  
**Limitation:** **L5** (compose native continuum tools; no full pi-ness TS coordinator crate in M2).  
**Disk contract:** [workspace.md](./workspace.md). **Prompt layer:** L5 in [prompt-system.md](./prompt-system.md).

## Intent

Long work survives interrupts without re-dumping the full continuum every turn.
When several lanes are open, **exactly one highest-priority open lane** drives the
next step. Operators and agents re-read stock surfaces; they do **not** invent a
parallel goal/plan/todo store.

## Priority order (binding)

```
interrupt → streak → goal → plan → workflow → todo
```

| Priority | Lane | Meaning | When open |
|---------:|------|---------|-----------|
| 1 | **interrupt** | User stopped/cancelled mid-turn or disrupted continuum | Recent interrupt/cancel flag in session (hook state) |
| 2 | **streak** | Too many continue-without-progress cycles | No-progress streak ≥ product max (default 3) with open lower work |
| 3 | **goal** | Session north star incomplete | Active goal via `update_goal` (not completed/cancelled) |
| 4 | **plan** | Ordered approach not finished | Plan file present with unfinished work (or plan mode active) |
| 5 | **workflow** | Named product workflow / skill method mid-flight | Active workflow pointer (skills / plan phases) |
| 6 | **todo** | Atomic next actions | Open `todo_write` items (`pending` / `in_progress`) |

**Rule:** Evaluate from interrupt downward. Emit guidance for the **first open**
lane only. Lower lanes stay deferred until higher lanes clear.

## Native tool map (do not reinvent)

| Lane | Read / own with | Write with | Location (CFG) |
|------|-----------------|------------|----------------|
| Interrupt | Session/hook state | User cancel + hook recorder | Session-local `.do/continuation/` state file |
| Streak | Hook counter `no_progress_streak` | PostToolUse progress detect | Same state file |
| Goal | Goal UI / tool status | `update_goal` | Session goal handle (stock) |
| Plan | Read plan file | `enter_plan_mode` / `exit_plan_mode` + edits | `<cwd>/.do/plan.md` |
| Workflow | Active skill/method pointer | Skills / plan phases | Project skills + plan phases (no dual DB) |
| Todo | Todo tool / UI | `todo_write` | Session `TodoState` |
| Specialist (support) | Task output | `task` / Agent(…) | Subagent session; parent owns continuum |

Supporting tools never override the priority ladder: `task` results fold back into
**goal** / **plan** / **todo** updates owned by orchestrator (or the human).

## Nudge shape (short, not a dump)

When re-surfacing a lane, use a **short pointer** — one lane, one focus, tools to
touch. Never paste full plan/goal/todo bodies into system/L0 each turn (L5 rule).

| Lane | Example nudge (compact) |
|------|-------------------------|
| interrupt | `Continue lane: interrupt — resume after cancel; re-read goal then plan before new edits.` |
| streak | `Continue lane: streak — no todo progress for N settles; re-plan or mark blocked; do not spin.` |
| goal | `Continue lane: goal — re-read update_goal; next step must advance or complete the goal.` |
| plan | `Continue lane: plan — re-read .do/plan.md; finish current phase before new scope.` |
| workflow | `Continue lane: workflow — follow active method/skill phase; update todo when step done.` |
| todo | `Continue lane: todo — focus in_progress item; mark completed with todo_write when done.` |

Prefixes used by the product hook engine (stable for fixtures):

| Constant | Prefix |
|----------|--------|
| Interrupt | `Continue lane: interrupt` |
| Streak | `Continue lane: streak` |
| Goal | `Continue lane: goal` |
| Plan | `Continue lane: plan` |
| Workflow | `Continue lane: workflow` |
| Todo | `Continue lane: todo` |

## Resume algorithm (operators + agents)

1. If user interrupted / cancelled → **interrupt** lane: re-orient, then re-evaluate.
2. If open work with no progress across max streak → **streak**: break thrash; re-plan or ask human.
3. Else if active goal incomplete → **goal**: one concrete step toward goal success.
4. Else if plan file / plan mode has unfinished work → **plan**.
5. Else if a named workflow is mid-flight → **workflow**.
6. Else if open todos → **todo** (prefer the single `in_progress` item).
7. Else idle: wait for user or close session cleanly.

**Always:** re-read disk/session sources (`update_goal`, `.do/plan.md`, todos) —
do not trust chat memory alone after compact or long idle.

## Anti-thrash policy (binding)

| Rule | Default | Purpose |
|------|---------|---------|
| **One lane per nudge** | Required | Avoid multi-lane pile-ups |
| **Cooldown** | 45s same lane fingerprint | No re-nudge spam on every tool return |
| **Fingerprint** | `lane + focus_key` | Same focus does not re-emit while cool |
| **Max nudges / session window** | 12 | Hard cap before quiet mode |
| **Quiet after cap** | Until goal/todo/plan **state change** | Resume only when continuum moves |
| **No full continuum inject** | Required | Pointers only (L5) |
| **Progress resets streak** | Required | Completing a todo / advancing plan clears streak counter |
| **Do not invent stores** | Required | Native tools only; no dual-write |

## Session hooks (product surface)

| File | Role |
|------|------|
| [`do-harness/hooks/continuation-nudge.json`](../do-harness/hooks/continuation-nudge.json) | PostToolUse matcher on continuum tools |
| [`do-harness/hooks/bin/continuation-nudge.py`](../do-harness/hooks/bin/continuation-nudge.py) | Priority select + thrash state + compact nudge |

**Events:** `PostToolUse` on native continuum tools:

- `update_goal`
- `todo_write` / `TodoWrite`
- `enter_plan_mode` / `exit_plan_mode`
- `task` / `spawn_subagent` / `Agent` (parent records support activity; does not invent lanes)

**Behavior:**

1. Record tool + compact state snapshot under session state dir.
2. Select highest-priority open lane from flags/paths/tool outcomes.
3. If thrash rules suppress → exit 0 with no new nudge fingerprint.
4. Else write compact `last_nudge` (lane + text) for operators / next resume; stdout JSON for scripted fixtures (runner may treat PostToolUse as passive — verify uses the engine directly).

**Enablement:** install onto project `.do/hooks/` (see [do-harness/README.md](../do-harness/README.md)). Requires project hooks trust (`/hooks-trust`) like other project hooks.

**Disable:** remove the JSON from discovery, or set `DO_CONTINUATION_NUDGE=0`.

## Worked examples

### 1. Interrupt mid worker edit

User cancels mid-turn while goal + todos open.

1. Hook state marks interrupt.
2. Priority → **interrupt**.
3. Nudge: resume, re-read `update_goal` + `.do/plan.md`, then continue one todo.
4. After resume clears interrupt flag → re-eval (likely **goal** or **todo**).

### 2. Goal owns plan and todos

Active goal "Ship F-M2-CONT", plan file has phases, todos open.

→ **goal** until goal completed/cancelled. Plan and todo remain supporting evidence; do not emit plan-lane spam while goal is the north star unless goal is idle/stopped.

### 3. Plan after goal sealed

Goal completed; `.do/plan.md` still has open phases.

→ **plan**. Finish or exit plan mode before raw todo thrash.

### 4. Streak break

Three settles with open todos and zero completed items.

→ **streak**. Agent must re-plan, mark blocked, or ask human — not re-run the same failing tool.

### 5. Todo only

No active goal, no plan body, two open todos one `in_progress`.

→ **todo** with focus on the `in_progress` item. Mark complete via `todo_write` before switching.

### 6. Task support

Orchestrator spawns `task` / worker. Parent keeps continuum; child returns findings.

→ Parent updates **goal** / **todo** with outcomes. Child does not become a parallel coordinator.

## Fixtures / verify

```sh
bash do-harness/scripts/verify-continuation.sh
# expect: exit 0 and "VAL-M2-CONT-001: PASS"
```

The verify script runs a multi-step thrash fixture against the hook engine (priority
selection + cooldown) without requiring a live LLM session.

## Out of scope (M2)

| Item | Notes |
|------|-------|
| Full pi-ness settle follow-up inject | Needs session crate/API; deferred (M2-C03 only if races proven) |
| Dual continuum DB (`.piness/` style) | Forbidden — [workspace.md](./workspace.md) |
| Replacing stock goal classifier | Use `update_goal` |
| OpenTUI dual-stream continue UI | Non-goal |

## Related

- [workspace.md](./workspace.md) — where state lives  
- [prompt-system.md](./prompt-system.md) — L5 pointer rule  
- [limitations.md](./limitations.md) L5  
- [backlog-m1-m3.md](./backlog-m1-m3.md) M2-C01 / M2-C02  
- [do-harness/hooks/README.md](../do-harness/hooks/README.md) — enablement  
