# Milestone ship discipline

Every substantive milestone for **do** follows the same exit criteria. Working-tree-only “done” without commit is **incomplete**.

## Required sequence

1. **Verify**
   - Code milestones: `cargo check -p xai-grok-pager-bin` (or agreed package); targeted tests when applicable
   - Docs-only milestones: file existence + link consistency + VAL coverage from the mission contract
2. **Document**
   - Update durable docs under `/home/datht/code/do/docs/`
   - Append [CHANGELOGS.md](../CHANGELOGS.md) (what shipped — not a second Status essay)
   - Update root [AGENTS.md](../AGENTS.md) **Current Status** / **Next steps** only if compact true-now would be wrong
   - Park long backlog in [future-plan.md](./future-plan.md) — never dump it into root AGENTS
3. **Commit**
   - Conventional commits: `type(scope): subject` (imperative, ≤50 char subject)
   - Atomic commits preferred; **every milestone gets a commit**
   - English only; no secrets in tree
4. **Handoff**
   - Include `commitId` + `repoPath` (`/home/datht/code/do`)
   - Missing commitId on a code/docs ship = fail / incomplete

## Git

- Repository root: `/home/datht/code/do`
- If git is not initialized, **initialize** as part of import / first ship (F-FORK-001)
- Do not force-push, amend others’ commits, or skip hooks unless the human explicitly requests it

## Docs every milestone

At minimum after a milestone that changes product truth:

| Artifact | Action |
|----------|--------|
| Relevant `docs/*.md` | Update or create |
| `CHANGELOGS.md` | Append entry with date + scope |
| Root `AGENTS.md` living section | Touch only if needed |
| Mission `validation-state.json` | Mark fulfilled VALs when evidence exists |

Control-plane required set (VAL-CTRL-002):

- `docs/index.md`
- `docs/architecture.md`
- `docs/future-plan.md`
- `docs/current-status.md`
- `docs/milestone-ship-discipline.md`
- `docs/related-projects.md`
- `docs/models-and-config.md`

## Skip rules

- Skip commit only if the human says so **or** there are no file changes
- Docs-only milestones do not require full workspace `cargo check`
- Never skip documentation for “small” harness behavior changes that alter operator contracts

## Anti-patterns

- Marking a feature complete without VAL evidence
- Putting multi-page future essays in root AGENTS
- Shipping model/config behavior without updating `docs/models-and-config.md`
- Bare “Permission denied” without guided blocks when gates exist
