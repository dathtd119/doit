# Fork policy: do

**Status:** M0 sealed (F-DOC-004 / VAL-DOC-004)  
**Product:** **do** — private/local fork of Grok Build with pi-ness harness-control ideas and OpenCode-style model assignment UX.

This file is the **fork hygiene and identity** contract. Operating rules for agents live in [AGENTS.md](./AGENTS.md). Multi-model design: [docs/models-and-config.md](./docs/models-and-config.md). Hard limits: [docs/grok-build/hard-limits.md](./docs/grok-build/hard-limits.md).

---

## 1. What do is

| Claim | Truth |
|-------|--------|
| Base | Forked **Grok Build** (Rust: pager, shell, tools, agent) under `/home/datht/code/do` |
| Ideas | **pi-ness** harness control (roles, L0–L6, guided gates, continuum) — reference only |
| Config ergonomics | **OpenCode-style** role→model assignment — product YAML overlay, not a second runtime |
| Binary lineage | `xai-grok-pager-bin` (upstream installs as `grok`; product brand is **do** in docs/harness) |
| Contribution path | **Private/local fork** — not “open external PRs to xAI grok-build” |

**do** is not a pure overlay on Pi, and not a Node/OpenTUI port. It owns a forked Rust tree plus a product layer (`do-harness/`) that prefers extension seams before crate patches.

---

## 2. Source trees (never modify references in place)

| Path | Role | Access |
|------|------|--------|
| `/home/datht/code/grok-build` | Import source for the base | **Read-only** — never edit in place |
| `/home/datht/code/pi-ness` | Ideas / harness thesis reference | **Read-only** — never edit in place |
| `/home/datht/code/do` | Product fork + do-harness + docs | **Writable** — only tree we change |

**Import rule:** copy (rsync/cp) from grok-build into do. Do not symlink live mutation into the sibling trees. Preserve Apache-2.0, `LICENSE`, and `THIRD-PARTY-NOTICES` on every import refresh.

When re-importing or rebasing from the sibling grok-build tree:

1. Copy into do only  
2. Re-run smoke: `cargo check -p xai-grok-pager-bin` (needs `dotslash` for `bin/protoc`)  
3. Diff product surfaces (`do-harness/`, `docs/`, root identity files) so they are not clobbered  
4. Document any new crate patches in [docs/patch-matrix.md](./docs/patch-matrix.md)

---

## 3. Extension-before-deep-fork order

When changing behavior, prefer this order (same as root AGENTS Customization Order):

| Order | Placement | When |
|-------|-----------|------|
| 1 | **do-harness** | Product identity: agents, hooks, skills, prompts, YAML overlays |
| 2 | **`.do` / `~/.config/do` config & plugins** | Product discovery root after CFG; multi-model TOML |
| 3 | **`register_tool_pack`** | New in-process native tools |
| 4 | **Surgical crate patches** | Only when extension seams fail — log in patch-matrix |
| 5 | **Deep pager / TUI fork** | Last resort (M2+ with explicit decision) |

**Before** a new always-on behavior, tool, or deep fork: ask placement (Native vs Extension vs Crate Patch). Default if “you choose”: identity/safety/roles/model-assignment → do-harness; optional → plugin; in-process tool → tool pack; only then crate patch.

Do **not** reinvent native tools grok already has (`plan` / plan mode, `update_goal`, hashline, `task`, `lsp`, multi-`[model.*]`, …). See [docs/grok-build/native-tools.md](./docs/grok-build/native-tools.md) and [docs/capability-map.md](./docs/capability-map.md).

---

## 4. Config root (CFG): `~/.config/do` + project `.do/`

| Decision | Choice | Rationale |
|----------|--------|-----------|
| User config home | **`~/.config/do` only** when `GROK_HOME` unset | P-CFG-HOME; no silent `~/.grok` fallback |
| Project discovery | **`.do/`** (agents, hooks, config, skills, plan, …) | P-CFG-PROJECT; product install targets |
| Product brand | **do** in docs, README, do-harness | Matches runtime paths |
| Compat dirs | Keep **`.claude/`** (and other vendor) project walks | Out of scope to remove |

Link or copy `do-harness/` assets onto discovery paths (`~/.config/do/...` or project `.do/...`) as needed for proof agents/hooks.

Environment override: **`GROK_HOME`** replaces the full user home root (document this one; `DO_HOME` not wired).

---

## 5. Dual config surface (multi-model)

Multi-model is **required product behavior**. Accurate facts (do not mis-document):

| Layer | Format | Owns | Runtime? |
|-------|--------|------|----------|
| **Stock runtime** | TOML `~/.config/do/config.toml` (via `$GROK_HOME`) | Many `[model.<name>]`, `[models] default`, `api_backend`, agent/role/persona model fields | **Yes** — binary reads this |
| **do product overlay** | YAML `do-harness/config.models.yaml` | Registry ergonomics + **role → model + effort** assignment table | **Wired** via apply-models → agent frontmatter |

```
do-harness/config.models.yaml     (product UX: registry + assignment)
        │ maps / generates / documents
        ▼
~/.config/do/config.toml          (native multi-model runtime; GROK_HOME override)
  + agent / role frontmatter model pins under project .do/agents/
```

- Grok **already** supports N custom models via `[model.*]` — gap is **assignment UX** (limitation **L13**), not “add multi-model”
- Subagent resolution: spawn override > role > persona > parent  
- **Do not** replace TOML with a competing runtime registry the binary never loads  
- Full schema, map, and examples: [docs/models-and-config.md](./docs/models-and-config.md)

---

## 6. Upstream PRs are not the product path

| Allowed | Not the product path |
|---------|----------------------|
| Own the fork under `/home/datht/code/do` | Opening external PRs to xAI / public grok-build as the way we ship **do** |
| Re-copy from local sibling `~/code/grok-build` when refreshing the base | Editing `~/code/grok-build` or `~/code/pi-ness` in place |
| Document every crate patch in patch-matrix | Silent deep forks of pager/TUI without decision |

Upstream grok-build is treated as a **private/local** lineage for this product. Official Grok Build docs may still be useful as reference ([docs.x.ai/build](https://docs.x.ai/build/overview)); they are not the contribution workflow for do.

---

## 7. License and notices

- Preserve **Apache-2.0** and third-party notices from the grok-build import  
- Keep `LICENSE` / `THIRD-PARTY-NOTICES` (and any crate-level notices) intact on re-import  
- English only for code, docs, commits, configs, errors, tests

---

## 8. Identity checklist (VAL-DOC-004)

| Requirement | Where |
|-------------|--------|
| Product intent | [README.md](./README.md) + this file §1 |
| Extension-before-deep-fork | §3 + [AGENTS.md](./AGENTS.md) Customization Order |
| Config root `~/.config/do` + project `.do/` | §4 |
| Dual TOML + do YAML model surface | §5 + [docs/models-and-config.md](./docs/models-and-config.md) |
| No external upstream PRs as product path | §6 + Non-Goals in AGENTS |
| Sibling trees read-only | §2 |

---

## 9. Related docs

| Doc | Purpose |
|-----|---------|
| [README.md](./README.md) | Human product overview + build smoke |
| [AGENTS.md](./AGENTS.md) | Operating contract + living status |
| [docs/architecture.md](./docs/architecture.md) | System layout + dual config diagram |
| [docs/models-and-config.md](./docs/models-and-config.md) | Multi-model + L13 |
| [docs/patch-matrix.md](./docs/patch-matrix.md) | Gap → path / risk / order (L10 fork hygiene) |
| [docs/grok-build/hard-limits.md](./docs/grok-build/hard-limits.md) | What not to fight |
| [docs/related-projects.md](./docs/related-projects.md) | pi-ness / grok-build / OpenCode mapping |
| [docs/milestone-ship-discipline.md](./docs/milestone-ship-discipline.md) | Docs + commit every milestone |

---

## 10. Non-goals (fork scope)

- Full OpenTUI / Node port of pi-ness TUI  
- Competing multi-model runtime that bypasses `~/.config/do/config.toml` (or `$GROK_HOME/config.toml`)
- Speculative abstractions before M0 baseline seals  
- Deep pager fork before extension seams are exhausted  
- Public upstream PR workflow as the definition of “done” for do features
