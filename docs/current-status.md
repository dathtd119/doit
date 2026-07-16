# Current status (expanded)

Date: **2026-07-16**  
Mission: `mis_413072d4`  
Compact status lives in root [AGENTS.md](../AGENTS.md); this file is the narrative expansion.

## Where we are

**do** is a private/local fork of Grok Build intended to absorb pi-ness harness-control ideas without porting OpenTUI. M0 is **not sealed**.

### Done

- Fork import of grok-build tree into `/home/datht/code/do` (feature **F-FORK-001**)
- **Build smoke** (F-FORK-002 / VAL-FORK-002): `cargo check -p xai-grok-pager-bin` exit 0; requires `dotslash` for `bin/protoc`
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
- **Grok-build inventory** **sealed** (F-GROK-001 / VAL-GROK-001):
    - `docs/grok-build/{README,overview,native-tools,extension-seams,hard-limits,patterns}.md`
    - Fork evidence: tool registry, namespaces/kinds, hooks, agents, subagent resolution, hashline `FileToolset`, hard limits
    - Linked from `docs/index.md` under **Grok-build inventory**
    - **Required read before crate work**
- **Limitations L1–L13** **sealed** (F-DOC-001 / VAL-DOC-001):
    - `docs/limitations.md` fully evidence-backed (pi-ness + forked grok paths per row)
    - L13: multi-model registry **exists**; gap is assignment UX / do YAML wire (see models-and-config)

### In progress / pending (M0)

| Item | Feature | Notes |
|------|---------|-------|
| `cargo check -p xai-grok-pager-bin` | F-FORK-002 | **Done** — VAL-FORK-002; needs `dotslash` |
| Grok-build inventory docs | F-GROK-001 / VAL-GROK-001 | **Done** — evidence-backed six-file inventory + index links |
| Limitations L1–L13 deep evidence | F-DOC-001 / VAL-DOC-001 | **Done** — every L1–L13 row has evidence paths |
| patch-matrix + capability-map | F-DOC-002..003 | patch-matrix exists (L13 sealed); refine + write capability-map |
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

1. Refine patch-matrix + write capability-map (F-DOC-002..003)
2. README identity + FORK policy expansion (F-DOC-004)
3. Extension proof path (F-EXT-001..003)
4. Backlog + M0 seal commit

## Links

- [architecture.md](./architecture.md)
- [models-and-config.md](./models-and-config.md)
- [grok-build/README.md](./grok-build/README.md)
- [future-plan.md](./future-plan.md)
- [CHANGELOGS.md](../CHANGELOGS.md)
