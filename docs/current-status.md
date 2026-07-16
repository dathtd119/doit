# Current status (expanded)

Date: **2026-07-16**  
Mission: `mis_413072d4`  
Compact status lives in root [AGENTS.md](../AGENTS.md); this file is the narrative expansion.

## Where we are

**do** is a private/local fork of Grok Build intended to absorb pi-ness harness-control ideas without porting OpenTUI. M0 is **not sealed**.

### Done

- Fork import of grok-build tree into `/home/datht/code/do` (feature **F-FORK-001**)
- Project control plane bootstrap:
  - Root `AGENTS.md` (operating contract + living status)
  - Docs split: index, architecture, future-plan, current-status, milestone-ship-discipline, related-projects, **models-and-config**
  - `CHANGELOGS.md` entry for control-plane bootstrap
  - Human `README.md` product framing (alongside upstream build notes)
- Multi-model design **sealed** (F-MODEL-001 / VAL-MODEL-001..002):
  - Grok already supports many `[model.<name>]` + default + role/persona/spawn resolution (fork evidence cited)
  - Gap is OpenCode-like **assignment UX** and do **YAML overlay** (**L13**)
  - `docs/models-and-config.md` complete (schema, map, ≥2 models / ≥3 role example)
  - Template: `do-harness/config.models.yaml` (`models.registry` + `assignment`)
  - L13 folded into `docs/limitations.md` + `docs/patch-matrix.md`
- **Role switch lock** product rule **sealed** (F-ROLE-001 / VAL-ROLE-001):
  - Tab/Shift+Tab role cycle **only before first user message**
  - **Disabled** after any conversation content (keep system/role context clean)
  - Model re-assignment from role only while switch still allowed
  - M0 = document (done); **M1 = implement** (session flag, keybind gate, stack freeze, role→model wire)
  - Sources of truth: root `AGENTS.md`, `docs/prompt-system.md` (Role lifecycle + M1 note), `docs/architecture.md`

### In progress / pending (M0)

| Item | Feature | Notes |
|------|---------|-------|
| `cargo check -p xai-grok-pager-bin` | F-FORK-002 | Smoke still pending |
| Grok-build inventory docs | F-GROK-001 / VAL-GROK-001 | `docs/grok-build/*` scaffolded with fork evidence; worker may deepen |
| Evidence docs L1–L12 deep pass | F-DOC-001..003 | limitations/patch-matrix exist with L13 sealed; deepen L1–L12 + capability-map (F-DOC-003 depends on F-GROK-001) |
| README identity + FORK policy expansion | F-DOC-004 | Partial README; FORK.md pending |
| Proof intake agent + guided hook | F-EXT-001..003 | do-harness agents/hooks |
| M1–M3 backlog including multi-model wire + role Tab lock | F-BACK-001 | role→model wiring + post-message lock |
| Control plane VAL evidence | F-CTRL-001 | **Done** — VAL-CTRL-001..003; sealed in git |
| Model design VAL | F-MODEL-001 | **Done** — VAL-MODEL-001..002; models-and-config + YAML + L13 in limitations/patch-matrix |
| Role switch lock policy documented | F-ROLE-001 | **Done** — VAL-ROLE-001 sealed in AGENTS + prompt-system + architecture |

### True-now constraints

- Do not modify `~/code/pi-ness` or `~/code/grok-build`
- Extension-before-deep-fork
- Config root remains `~/.grok` for M0; brand as do in docs
- Commit every milestone; handoff needs `commitId` + `repoPath`

## Near-term sequence

1. Cargo smoke (F-FORK-002)
2. Grok-build inventory verify/expand (F-GROK-001) — required before crate work
3. Evidence inventory docs + L13 in limitations/patch-matrix
4. Extension proof path
5. Backlog + M0 seal commit

## Links

- [architecture.md](./architecture.md)
- [models-and-config.md](./models-and-config.md)
- [grok-build/README.md](./grok-build/README.md)
- [future-plan.md](./future-plan.md)
- [CHANGELOGS.md](../CHANGELOGS.md)
