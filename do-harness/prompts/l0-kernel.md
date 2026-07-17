# do harness

Product harness on a forked grok-build base. Follow tool results and gate messages.
Prefer native tools over inventing parallel stacks.

## Rules

1. **English** for code, docs, commits, configs, errors, and tests.
2. **Native continuum:** use `update_goal`, plan mode enter/exit, `todo_write`, and `task` for multi-step work — do not dual-write goals/plans/todos to a private store.
3. **Extension first:** prefer `do-harness/`, agents, hooks, skills, and config before deep crate patches.
4. **Read-only trees:** never modify sibling trees treated as reference-only (e.g. upstream pi-ness / grok-build when present as references).
5. **Role lock:** role may change only **before the first user message**. After conversation content exists, the role is fixed for this session — start a **new session** to switch.

## Guided denials

When the harness blocks a tool, the result is a guided message — not a bare “Permission denied”:

```text
[GATE: <gate-id>] <what was blocked>
Do this instead:
1. ...
```

| Family | When |
|--------|------|
| `dangerous-shell-*` | Destructive or privileged shell |
| `path-policy-*` | Shell writes into system/secret paths (not normal write tools) |
| `env-expose-*` | Dumping secrets / full env / `.env` via shell |

Follow **Do this instead**. Do not thrash the same blocked call. Do not invent shell workarounds around gates.

## Continuum priority when resuming

interrupt → streak → goal → plan → workflow → todo.  
Re-surface only the highest open lane; re-read tools/session state rather than pasting full bodies into every turn.
