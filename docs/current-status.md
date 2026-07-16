# Current status (expanded)

Date: **2026-07-16**  
Mission: Factory **M1 seal → PRIV → M2/M3** (`mis_e0bdf86b`; prior history `mis_413072d4` / OpenCode `mis_3ce18e2a`)  
Compact status lives in root [AGENTS.md](../AGENTS.md); this file is the narrative expansion.

## Where we are

**do** is a private/local fork of Grok Build intended to absorb pi-ness harness-control ideas without porting OpenTUI. **M0 is sealed.** **M1 is sealed** (F-M1-SHIP). Next product track is **PRIV**, then M2/M3 per [backlog-m1-m3.md](./backlog-m1-m3.md).

### M0 sealed (summary)

- Fork import + `cargo check -p xai-grok-pager-bin` smoke
- Control plane (AGENTS + docs split + CHANGELOGS + README/FORK)
- Multi-model design (L13): stock multi-`[model.*]` facts + do YAML assignment template
- Role switch lock **policy** documented (implement later sealed in M1)
- Grok-build inventory, limitations L1–L13, patch-matrix, capability-map
- Proof extension: intake agent, guided dangerous-shell hook, `verify-discovery.sh`
- Ordered backlog `docs/backlog-m1-m3.md`

### M1 sealed (harness control v1)

| Surface | Evidence |
|---------|----------|
| Five product agents | `verify-roster.sh` — intake, orchestrator, explorer, worker, oracle on `.grok/agents/` |
| Role switch lock | `verify-role-lock.sh` — 10 `role_switch_policy` tests; Tab only pre-message |
| Lock UX toast | `c8bf39f` — locked-attempt toast points to new session (`role_switch_locked_toast`) |
| YAML → agent pins | `apply-models.py --validate` — 5 assignment pins; stock TOML remains runtime |
| Model re-pin gate | `verify-model-resolve.sh` — re-pin only while `role_switch_allowed` |
| L0–L6 + workspace | `docs/prompt-system.md` implementable; `docs/workspace.md` non-stub (reuse `.grok` only) |
| Progressive skills start | `verify-progressive-skills.sh` + `config.skills.yaml`; reduced firehose on intake/explorer/oracle |

M1 exit criteria in [backlog-m1-m3.md](./backlog-m1-m3.md) are **checked**. Full seal entry: [CHANGELOGS.md](../CHANGELOGS.md) F-M1-SHIP.

### In progress / next

| Item | Track | Notes |
|------|-------|-------|
| No-telemetry fail-closed | **PRIV** | P-NOTEL-01..06 from `~/code/grok-build-no-telemetry` (manual port) |
| Custom models / BYOK no forced OAuth | **PRIV** | Config-first; P-AUTH-01 if crate needed |
| Continuation priority + guided pack | **M2** | Native goal/plan/todo; ≥2 more gates |
| CodeGraph + hashline default | **M3** | After M2 |

### True-now constraints

- Do not modify `~/code/pi-ness`, `~/code/grok-build`, or `~/code/grok-build-no-telemetry` (read-only)
- Extension-before-deep-fork
- Config root remains `~/.grok` for M0/M1; brand as do in docs
- Role cycle remains **pre-message only** (no mid-session hop)
- Commit every milestone; handoff needs `commitId` + `repoPath`

## Near-term sequence

1. **PRIV** seal (no-telemetry + BYOK auth)
2. **M2** continuation + guided-block harden
3. **M3** CodeGraph + hashline default

## Links

- [architecture.md](./architecture.md)
- [models-and-config.md](./models-and-config.md)
- [backlog-m1-m3.md](./backlog-m1-m3.md)
- [prompt-system.md](./prompt-system.md)
- [workspace.md](./workspace.md)
- [progressive-skills.md](./progressive-skills.md)
- [../FORK.md](../FORK.md)
- [grok-build/README.md](./grok-build/README.md)
- [future-plan.md](./future-plan.md)
- [CHANGELOGS.md](../CHANGELOGS.md)
