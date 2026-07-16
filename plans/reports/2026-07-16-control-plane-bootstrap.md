# Report: Control plane bootstrap + multi-model design

Date: 2026-07-16  
Work context: `/home/datht/code/do`  
Mission: `mis_413072d4`  
Scope: Docs, AGENTS, mission artifacts only (no Rust product code)

## Outcome

Established pi-ness-style project control plane and documented multi-model + OpenCode-style assignment design (L13). All 15 VAL-* IDs claimed exactly once.

## Files created/updated

### Project (`/home/datht/code/do`)

| File | Action |
|------|--------|
| `AGENTS.md` | Full control contract + models section + L13-aware status |
| `README.md` | Human product overview (do framing) |
| `CHANGELOGS.md` | Bootstrap entry |
| `docs/index.md` | Doc map |
| `docs/architecture.md` | Architecture + L1–L13 + dual config surface |
| `docs/models-and-config.md` | Multi-model design (gork facts, OpenCode gap, YAML, map) |
| `docs/future-plan.md` | Long parking lot |
| `docs/current-status.md` | Expanded status |
| `docs/milestone-ship-discipline.md` | Docs + commit every milestone |
| `docs/related-projects.md` | pi-ness, grok-build, OpenCode |
| `docs/prompt-system.md` | L0–L6 stub |
| `docs/workspace.md` | Continuum stub |
| `do-harness/config.models.yaml` | Registry + assignment template |
| `.opencode/skills/harness-docs-worker/SKILL.md` | Updated for control plane + L13 |

### Mission

| File | Action |
|------|--------|
| `AGENTS.md` | Points at project AGENTS; multi-model + ship discipline |
| `architecture.md` | Dual config + L13 |
| `validation-contract.md` | VAL-CTRL-*, VAL-MODEL-*, L13 in DOC |
| `features.json` | F-CTRL-001, F-MODEL-001 prepended; F-DOC/F-BACK updated |
| `validation/validation-state.json` | All 15 VALs pending |

## VAL coverage (exactly once)

| VAL | Feature |
|-----|---------|
| VAL-CTRL-001 | F-CTRL-001 |
| VAL-CTRL-002 | F-CTRL-001 |
| VAL-CTRL-003 | F-CTRL-001 |
| VAL-MODEL-001 | F-MODEL-001 |
| VAL-MODEL-002 | F-MODEL-001 |
| VAL-FORK-001 | F-FORK-001 |
| VAL-FORK-002 | F-FORK-002 |
| VAL-DOC-001 | F-DOC-001 |
| VAL-DOC-002 | F-DOC-002 |
| VAL-DOC-003 | F-DOC-003 |
| VAL-DOC-004 | F-DOC-004 |
| VAL-EXT-001 | F-EXT-001 |
| VAL-EXT-002 | F-EXT-002 |
| VAL-EXT-003 | F-EXT-003 |
| VAL-BACK-001 | F-BACK-001 |

## Note on feature status

F-CTRL-001 and F-MODEL-001 remain `pending` in features.json for formal worker/orchestrator validation, though content for those VALs is present on disk. Orchestrator may mark them completed after review.

## Not done (out of scope)

- Rust product code / cargo smoke
- limitations.md / patch-matrix / capability-map evidence docs
- FORK.md
- Proof agent + guided hook
- Commit (not requested in this task)
