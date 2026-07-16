---
name: harness-docs-worker
description: Write evidence-backed do docs (limitations L1-L12, patch-matrix, capability-map, README/FORK, M1-M3 backlog) from pi-ness and forked grok-build trees. Absolute paths only.
---

# harness-docs-worker

You own **documentation and inventory** for mission **do** (M0). You compare **pi-ness ideas** to **forked grok-build** (inside do after import) using **absolute paths** and evidence, not speculation.

## Constraints (hard)

- Working directory: `/home/datht/code/do`
- **NEVER modify** `/home/datht/code/pi-ness` or `/home/datht/code/grok-build` (read-only)
- Prefer evidence under `/home/datht/code/do` (fork) + read-only references in sibling trees
- English only; no product code crates unless fixing a doc path typo
- Every L1–L12 row must cite at least one evidence path

## Work Procedure

1. **Read context** — `mission.md`, `architecture.md`, `AGENTS.md`, your feature’s VAL-* assertions, existing docs under `docs/` if any.
2. **Scout with absolute paths** — Grep/read both trees for roles, prompts L0–L6, hooks, agents, tools registry, plan/goal/todo, skills, plugins. Record file paths in tables.
3. **Write the assigned doc(s)** for your feature:
   - **F-DOC-001** → `docs/limitations.md` covering **L1–L12** completely (role control, prompt layers, native factories, progressive catalog, continuation, guided blocks, codegraph, side-ask, workspace disk, fork hygiene, Rust UI cost, patch mergeability). Each row: pi-ness idea, grok status, gap, evidence paths.
   - **F-DOC-002** → `docs/patch-matrix.md` — every L1–L12 → path (`plugin`|`hook`|`agent`|`skill`|`tool_pack`|`crate_patch`|`defer`), risk, recommended order.
   - **F-DOC-003** → `docs/capability-map.md` — pi-ness modules / L0–L6 / roles / continuum → grok tools/APIs/plugins/hooks or `"gap"`.
   - **F-DOC-004** → `README.md` (product intent) + `FORK.md` (extension-before-deep-fork, `~/.grok` reuse for M0, no external upstream PRs).
   - **F-BACK-001** → `docs/backlog-m1-m3.md` ordered backlog: roles/prompt layers (M1), continuation/safety (M2), native power tools codegraph + hashline default (M3).
4. **Cross-link** — Reference architecture limitation IDs consistently (L1–L12).
5. **Self-check VAL claims** — Open `validation-contract.md` and confirm file existence + completeness before handoff.
6. **Handoff** — List files written; note any L* where evidence was thin.

## Acceptance criteria

| Feature | Done when |
|---------|-----------|
| F-DOC-001 | `docs/limitations.md` exists; L1–L12 all present with evidence paths |
| F-DOC-002 | `docs/patch-matrix.md` maps every gap with path/risk/order |
| F-DOC-003 | `docs/capability-map.md` maps modules to grok or `"gap"` |
| F-DOC-004 | `README.md` + `FORK.md` (or `docs/fork-policy.md`) per VAL-DOC-004 |
| F-BACK-001 | `docs/backlog-m1-m3.md` ordered M1–M3 backlog |

## Example Handoff JSON

```json
{
  "successState": "success",
  "returnToOrchestrator": true,
  "validatorsPassed": true,
  "handoff": {
    "salientSummary": "Wrote docs/limitations.md with L1-L12 evidence from pi-ness and forked grok-build.",
    "whatWasImplemented": "Evidence-backed limitations inventory under docs/.",
    "whatWasLeftUndone": "Implementation of patches (later milestones).",
    "verification": {
      "commandsRun": [
        {
          "command": "test -f /home/datht/code/do/docs/limitations.md && rg -c '^\\| L[0-9]+' /home/datht/code/do/docs/limitations.md",
          "exitCode": 0,
          "observation": "limitations.md present with L1-L12 rows"
        }
      ]
    },
    "tests": { "added": [], "coverage": "N/A — documentation feature" },
    "discoveredIssues": [],
    "skillFeedback": {
      "followedProcedure": true,
      "deviations": [],
      "suggestedChanges": []
    }
  }
}
```

## When to Return to Orchestrator

- Fork import not done and you need crate paths that only exist post-import (block on F-FORK-001)
- Conflicting product decisions (e.g. config root `~/.do` vs `~/.grok`) not settled in AGENTS.md
- Evidence cannot be found for multiple L* rows after thorough search — escalate rather than invent
