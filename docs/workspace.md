# Workspace continuum — stub

**Status:** Stub for M0. Full contract after import smoke and capability mapping (L5, L9).

## Intent

A durable **session continuum** so long work survives interrupts:

| Concept | Operator meaning | Stock grok surface (starting point) |
|---------|------------------|-------------------------------------|
| Goal | What success looks like | `update_goal` / goal classifier |
| Plan | Ordered approach | plan mode enter/exit, plan files |
| Todo | Atomic next actions | todo tools / `todo_write` |
| Role | Who is acting | agent profiles / personas |
| Model | Which model for this role | config.toml + assignment (see models-and-config) |

## Disk layout

pi-ness uses a dedicated workspace disk state (e.g. `.piness/`). Grok uses session directories, plan files, and goals. **do** will either:

- Map product semantics onto existing `.grok` session layout, or
- Introduce a thin `.do/` overlay later without breaking native tools

Tracked as **L9**. Unified priority across interrupt → streak → goal → plan → workflow → todo is **L5**.

## Related

- [architecture.md](./architecture.md)
- [prompt-system.md](./prompt-system.md)
- [models-and-config.md](./models-and-config.md)
