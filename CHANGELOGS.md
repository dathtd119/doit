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
- Formal F-MODEL-001 worker seal

---

## 2026-07-16 — F-ROLE-001 role switch lock policy seal

**Scope:** docs only (AGENTS, prompt-system, architecture, status)  
**Feature:** F-ROLE-001 · **VAL:** VAL-ROLE-001

### Sealed

- **Tab / Shift+Tab** role cycle **only** at session start (empty transcript / no user messages)
- **Disabled** after first user message or any conversation content — no mid-session role hop
- Model re-assignment from role only while switch is still allowed
- **M1** is the implementation milestone (session flag, keybind gate, L1 stack freeze, role→model wire)
- M1 implementation note seeded in `docs/prompt-system.md` and `docs/architecture.md` for F-BACK-001 backlog pickup

### Files

- Root `AGENTS.md` — Hard Constraints + Session / role control + living status
- `docs/prompt-system.md` — Role lifecycle + M1 implementation note
- `docs/architecture.md` — Session / role control table + M1 note
- `docs/current-status.md` — F-ROLE-001 marked done
