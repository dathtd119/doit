# CHANGELOGS

Append-only ship log for **do**. Not a status essay — one entry per substantive milestone or control-plane change.

---

## 2026-07-16 — F-CTRL-001 control plane seal

**Scope:** docs / AGENTS / README / CHANGELOGS (no Rust product code)  
**Feature:** F-CTRL-001 · **VALs:** VAL-CTRL-001, VAL-CTRL-002, VAL-CTRL-003

### Added / sealed

- Root `AGENTS.md` as pi-ness-style operating contract (direction, hard constraints, customization order, gates, documentation rules, living status, models & config control)
- Docs split under `docs/` (all linked from `docs/index.md`):
  - `index.md`, `architecture.md`, `future-plan.md`, `current-status.md`
  - `milestone-ship-discipline.md`, `related-projects.md`
  - **`models-and-config.md`** — grok multi-model facts, OpenCode gap, do YAML overlay design, **L13**
  - Stubs: `prompt-system.md`, `workspace.md`
- `CHANGELOGS.md` + product-framed `README.md`
- Mission `AGENTS.md` points workers at `/home/datht/code/do/AGENTS.md` and keeps mission boundaries
- Ship discipline: verify → document under `docs/` + CHANGELOGS → conventional commit every milestone → handoff with `commitId` + `repoPath`

### Product decisions recorded

- Stock multi-model remains `~/.grok/config.toml` (many `[model.*]`, default, role/persona/spawn resolution)
- do product YAML overlay for assignment UX; map into TOML + agent frontmatter
- Multi-model assignment is a first-class M0 requirement (L13), M1 wire
- Role Tab/Shift+Tab cycle only pre-message; lock after first user message (document M0, implement M1)

### Not in this entry

- `cargo check` smoke (F-FORK-002)
- Evidence limitations / patch-matrix / capability-map (F-DOC-001..003)
- Proof agent + guided hook (F-EXT-*)
- Formal F-MODEL-001 / F-ROLE-001 worker seals (content may already exist on disk)
