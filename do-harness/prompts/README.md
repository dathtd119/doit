# do-harness prompts

Product-owned system stack for **do**. Source of truth is **this directory**
(repo). Do not customize prompts under `~/.config/doit` — home holds runtime
**config** only (`scripts/sync-user-config.sh`).

## Assembly

```text
l0-system.md
  ├── ${l0_general}   ← l0-general.md   (stock general)
  ├── ${l0_kernel}    ← l0-kernel.md    (harness rules + gates, once)
  ├── Identity        ← ${agent} ${role} ${policy}   (no model)
  ├── ${role_body}    ← roles/<stem>.md (mission / workflow / style)
  └── Session         ← ${date} ${cwd} ${os} ${shell}
```

Placeholder names match file stems (`l0_general` ↔ `l0-general.md`). Catalog:
[`placeholders.md`](./placeholders.md).

## Who owns what

| File | Owns | Does not |
|------|------|----------|
| `l0-general.md` | Stock safety, tools, output style | Product gates, role mission |
| `l0-kernel.md` | Harness rules, gates, continuum priority, role-lock | Role-specific workflow |
| Identity (in shell) | Agent / role / policy | Model id |
| `roles/*.md` | Static role: identity, can/cannot, workflow, style, DO/DON'T | Gates catalog, skills dump, model id |
| Session (in shell) | date, cwd, os, shell | — |

**Identity path:** stock general opening + Identity block (agent/role/policy) + role Mission.
Roles **may** open Mission with one line `You are **{Role}** — …` and negative identity
(`You are not …`). Roles do **not** re-list the gate catalog or embed skill firehoses.

**Role body shape (recommended):** Mission (You are / are not) → Can/Cannot → Should/
Should not → Workflow → Output shape / examples → Behavioral checklist → DO/DON'T.
Orchestrator also carries a specialist **routing catalog** (delegate when / don’t / rule of thumb).

**Skills:** not embedded here. Progressive skill inject is a separate system path
(future plan — do not port claudekit/omo skill dumps into role bodies).

## Config (separate)

| Surface | Path |
|---------|------|
| Role tools / model / color / policy | `../config.roles.toml` |
| User merge | `../scripts/sync-user-config.sh --apply` |

```sh
bash do-harness/scripts/apply-role-contracts.sh --apply   # agents bridge
bash do-harness/scripts/sync-user-config.sh --apply       # ~/.config/doit config only
```

## Sync stock general

```sh
bash do-harness/scripts/sync-l0-general.sh
```

## Runtime today

Crate still uses `base_template()` + `agents/*.md` until product L0 expander
lands. Edit prompts **here**; agent bodies come from `prompts/roles/` via
`apply-role-contracts.sh --apply`.
