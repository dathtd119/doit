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

**Binding product rule** (OpenCode-like Tab / Shift+Tab role cycle; keep context clean):

| Phase | Role cycle | System / role stack | Role→model re-assignment |
|-------|------------|---------------------|---------------------------|
| **Pre-message** — session start, empty transcript, no user messages yet | **Allowed** (Tab / Shift+Tab) | Role may change; L1 role layer swaps | **Allowed** — apply assignment for newly selected role |
| **Post-message** — after first user message **or** any conversation content | **Disabled** | Frozen for this session | **Blocked** — do not re-pin model mid-session via role hop |

### Rules

1. **Only at session start** may the user cycle roles (Tab / Shift+Tab).
2. **After the first message** (or any non-empty conversation), role switching is **off** — no mid-session role hop that rewrites the system/role stack.
3. To change role after work has started: **start a new session** (do not thrash mid-transcript).
4. Model resolution from role assignment applies only while switch is still allowed; spawn overrides remain separate (subagent path).

### Milestone

| Milestone | Work |
|-----------|------|
| **M0** | Document policy (this section, AGENTS, architecture, backlog) |
| **M1** | Implement lock in session / TUI / role resolver; wire role→model when switch allowed |

Full TUI polish is not required in M0; the **lock policy is mandatory** whenever role-cycle UI exists.

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
