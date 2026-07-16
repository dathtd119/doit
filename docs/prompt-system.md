# Prompt system (L0–L6) — stub

**Status:** Stub for M0. Full design lands with roles work (M1) and evidence in `docs/limitations.md` (L2).

## Intent

pi-ness-style **layered prompt assembly** so operators can reason about what the model sees:

| Layer | Working name | Purpose (target) |
|-------|--------------|------------------|
| L0 | Kernel / safety | Non-negotiable safety and product identity |
| L1 | Role | Active role contract (intake, orchestrator, worker, …) |
| L2 | Workspace | Project AGENTS, docs, continuum pointers |
| L3 | Tools | Tool catalog / progressive discovery |
| L4 | Skills | Skill list or dynamic skill surface |
| L5 | Session | Goal / plan / todo / reminders |
| L6 | Turn | Ephemeral injects, gate results, user message framing |

Exact layer names and byte budgets are TBD against forked grok assembly (system prompts, agent profiles, skills, reminders).

## Stock grok today

Different assembly model: system + agent prompts, skills, plugins, reminders — not an explicit L0–L6 registry. Gap tracked as **L2**.

## Role lifecycle

**Binding product rule** (OpenCode-like Tab / Shift+Tab role cycle; keep context clean). Documented M0 (**VAL-ROLE-001** / **F-ROLE-001**); **implement in M1**.

| Phase | Role cycle (Tab / Shift+Tab) | System / role stack | Role→model re-assignment |
|-------|------------------------------|---------------------|---------------------------|
| **Pre-message** — session start, empty transcript, no user messages yet | **Allowed** | Role may change; L1 role layer swaps | **Allowed** — apply assignment for newly selected role |
| **Post-message** — after first user message **or** any conversation content | **Disabled** | Frozen for this session | **Blocked** — do not re-pin model mid-session via role hop |

### Rules

1. **Only at session start** may the user cycle roles (Tab / Shift+Tab).
2. **After the first user message** (or any non-empty conversation content), role switching is **off** — no mid-session role hop that rewrites the system/role stack.
3. To change role after work has started: **start a new session** (do not thrash mid-transcript).
4. Model resolution from role assignment applies only while switch is still allowed; spawn overrides remain separate (subagent path).
5. Full TUI polish may lag; the **lock policy is mandatory** whenever role-cycle UI exists (never ship cycle without the lock).

### Milestone

| Milestone | Work |
|-----------|------|
| **M0** | Document policy (this section, root AGENTS, architecture; M1 note below). **Done** for VAL-ROLE-001. |
| **M1** | Implement lock + wire role→model when switch allowed (see implementation note) |

### M1 implementation note (backlog seed)

Ordered work for M1 (also lands in `docs/backlog-m1-m3.md` under F-BACK-001):

1. **Session state flag** — track `role_switch_allowed` (true only while transcript has no user messages / no conversation content).
2. **Keybind gate** — Tab / Shift+Tab cycle primary-session roles **only** when the flag is true; ignore or no-op after lock.
3. **Prompt stack freeze** — on lock, freeze L1 role layer for the session; do not rebuild system/role prompts from a mid-session hop.
4. **Model re-resolve** — apply do YAML / agent role→model assignment **only** while switch is allowed; after lock, keep active model stack (spawn overrides for subagents unchanged).
5. **UX feedback** — optional: status/hint that role is locked after first message; point user to new session for role change.
6. **Placement order** — prefer session/shell + agent profile seams; crate patch only if keybind/session flag cannot land via extension.

Related gaps: **L1** (primary-session role machine), **L13** (role→model assignment wiring).

## do direction

1. Document mapping of L* → grok surfaces in `docs/capability-map.md`
2. Prefer agent profiles + prompt fragments under `do-harness/prompts/`
3. Implement role lifecycle lock with roles work (M1)
4. Crate patch only if budget/registry cannot be achieved via extension

## Related

- [architecture.md](./architecture.md) L1 / L2 / Session role control
- [models-and-config.md](./models-and-config.md) — model re-resolve only when role switch allowed
- [workspace.md](./workspace.md)
- Root [AGENTS.md](../AGENTS.md) Hard Constraints + Session / role control
