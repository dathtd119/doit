# Architecture: do

## Purpose

**do** = forked **Grok Build** (native-rich Rust harness) + **pi-ness** harness-control ideas + **OpenCode-style** multi-model and config ergonomics.

Product thesis: *harness control* — roles as the unit of control, prompt + tools co-evolution, progressive catalogs, deliberate safety filters, workspace continuum (todos / plans / goals), continuation discipline, and **explicit model assignment per role**.

## Session / role control (binding product rule)

OpenCode-style **Tab / Shift+Tab** role cycle:

- **Allowed only at session start** — empty transcript / no user messages yet
- **Disabled after the first user message** (or any non-empty conversation content) — no mid-session role hop
- **Why:** keep system/role prompt stack clean; mid-session switches pollute context
- **Model assignment:** re-resolve role→model only while switch is still allowed
- **Milestone:** document in M0; **implement in M1** (full TUI polish may lag; lock policy binds whenever cycle UI exists)

Details: [prompt-system.md](./prompt-system.md) (Role lifecycle), root [AGENTS.md](../AGENTS.md) Hard Constraints + Session / role control.

## Source trees

| Role | Path | Access |
|------|------|--------|
| Base (import source) | `/home/datht/code/grok-build` | **Read-only** — copy into do; never modify in place |
| Ideas (reference) | `/home/datht/code/pi-ness` | **Read-only** — reference only; never modify |
| Config learnings | OpenCode (`~/.config/opencode/`, pi-ness `docs/opencode-harnessing.md`) | Read for patterns; do not copy whole product |
| Target product | `/home/datht/code/do` | **Writable** — forked tree + do-harness + docs |

## System components

1. **Forked grok-build crates** — pager, shell, tools, agent, workspace (Cargo workspace under `crates/`, binary lineage `xai-grok-pager-bin`)
2. **Native multi-model** — `~/.grok/config.toml` with many `[model.<name>]` sections, `[models] default`, api backends; agent/persona/spawn model overrides
3. **do-harness product layer** — agents, hooks, skills, prompts, **YAML model assignment overlay** (`config.models.yaml`)
4. **Docs** — architecture, models-and-config, limitations, patch-matrix, capability-map, backlog

## Config dual surface

```
┌─────────────────────────────────────────────────────────┐
│  do YAML overlay (product UX)                           │
│  do-harness/config.models.yaml                          │
│  registry + assignment: role → model + effort           │
└───────────────────────────┬─────────────────────────────┘
                            │ maps / generates / documents
                            ▼
┌─────────────────────────────────────────────────────────┐
│  Stock grok TOML (native runtime)                       │
│  ~/.grok/config.toml                                    │
│  [models] default · [model.<name>] · agent frontmatter  │
└─────────────────────────────────────────────────────────┘
```

M0: document + template only. M1: wire assignment into do-harness agents. Details: [models-and-config.md](./models-and-config.md).

## Extension strategy order

1. **Config / agents / skills / hooks / plugins / YAML overlays** — no crate fork surface
2. **`register_tool_pack`** for new native tools when behavior must be in-process
3. **Surgical crate patches** — documented in `docs/patch-matrix.md` every time
4. **Deep TUI / pager fork** — last resort only

## Native tools to USE (not reinvent)

| Surface | Tools / APIs |
|---------|----------------|
| Filesystem | `read_file`, `search_replace`, hashline namespace, `list_dir`, `grep` |
| Shell | `run_terminal_cmd` / bash equivalent |
| Continuum | `todo_write` / todo tools, `enter_plan_mode` / `exit_plan_mode`, `update_goal` |
| Agents | `task` (subagents), agent profiles, personas |
| Models | multi `[model.*]`, default, role/persona/spawn model override |
| Extension | plugins, hooks, skills |
| MCP | `search_tool` / `use_tool` |
| Language | `lsp` |

## Limitation IDs L1–L13

| # | Idea | Stock grok-build | Gap / risk | Preferred patch path |
|---|------|------------------|------------|----------------------|
| L1 | Role roster as **primary session** control + tool/skill deny floors; **Tab cycle only pre-message, lock after first message** | Agents + personas (subagent-centric); not full intake→orchestrator role machine | Primary-session role cycle weaker than pi-ness; no post-message lock yet | Agents/profiles + config first; M1 implement Tab cycle + post-message lock; Rust role resolver only if insufficient |
| L2 | L0–L6 layered prompt assembly + fragment registry/maxBytes | System/agent prompts, skills, reminders — different assembly model | No explicit L0–L6 control plane | Prompt templates + plugin injects; crate patch for budget/registry if needed |
| L3 | Always-on native harness factories (TS) | Monolithic Rust tool registry + plugins/hooks | No TS factory inject; must use Rust/plugin seams | Plugin + hooks for behavior; new tools under `xai-grok-tools` when native |
| L4 | Progressive skill/MCP catalog (dynamic mode, not dump) | Skills listing + discovery reminders exist | May still be too firehose vs pi-ness dynamic mode | Config/skills ignore + reminder tuning; patch skill prompt builder if needed |
| L5 | Continuation coordinator (interrupt→streak→goal→plan→workflow→todo) | Goal classifier + plan mode + todos exist separately | No unified priority coordinator | SessionActor / shell hooks first; coordinator crate if multi-lane races |
| L6 | Guided blocks `[GATE:…]` + “Do this instead” | Permissions + PreToolUse hooks | Denials less “teach the model” | Hooks + tool error shapes; small tools-api patch for standard gate format |
| L7 | CodeGraph lean tools | No first-party codegraph package observed | Semantic nav missing | MCP or plugin wrapping local codegraph; optional native tool later |
| L8 | Side-ask dual stream / intake default role | `ask_user_question`, modes | No side dual-stream product | Defer UI polish; intake agent profile first |
| L9 | Workspace disk state `.piness/` L6 | Session dir + plan.md + goals | Different layout/semantics | Map `.do/` or reuse `.grok/` session layout; document contract |
| L10 | Overlay-first without forking Pi | **This is a fork** of grok-build (upstream: no external contrib) | Must own fork hygiene, rebases, branding | Fork policy + clear “do” identity vs upstream `grok` |
| L11 | Node/OpenTUI stack | Rust/ratatui pager | Different contrib model & UI extension cost | Accept Rust; extend via plugins before TUI deep forks |
| L12 | Compat patches to upstream dist | Full source tree available | Easier to patch crates, harder to stay mergeable | Prefer config/plugin; minimize core diffs; document every patch |
| **L13** | **OpenCode-like multi-model assignment** (provider catalog + agent.model pins + effort) | **Multi-model registry already exists** (`[model.*]`, default, role/persona/spawn overrides) | **Assignment UX and role→model policy** weaker; no product YAML overlay; ergonomics lag OpenCode | do-harness YAML + agent frontmatter mapping; keep stock TOML as runtime source of truth |

Evidence detail for L1–L12: `docs/limitations.md` (F-DOC-001). L13 design: [models-and-config.md](./models-and-config.md).

## M0 target layout

```
/home/datht/code/do/
  crates/...                 # forked grok-build
  do-harness/
    agents/
    hooks/
    skills/
    prompts/
    config.models.yaml       # product model registry + role assignment (template M0)
  docs/
    index.md
    architecture.md
    models-and-config.md
    grok-build/             # base inventory (extend vs hard-limit vs patterns)
    limitations.md
    patch-matrix.md
    capability-map.md
    ...
  AGENTS.md
  CHANGELOGS.md
  README.md
  FORK.md
```

## Data flow

```
User
  → do binary (forked pager / xai-grok-pager-bin lineage)
    → shell / agent runtime
      → model resolution
          (spawn override > role > persona > parent;
           registry from config.toml; assignment policy from do YAML → agents)
      → tools registry (native + tool packs)
      → do-harness agents / hooks / skills / prompts
      → session continuum (goal / plan / todo via native tools)
```

## Boundaries

- **No OpenTUI port** in M0–M1 unless reopened
- **Keep stock auth** for M0
- Prefer **`~/.grok` internals** for config discovery; brand as **do** in docs/CLI later
- **Do not replace** native multi-model TOML — overlay and map
- **Do not kill unrelated processes**
- Reference **pi-ness / OpenCode** only; do **not** modify `/home/datht/code/pi-ness` or `/home/datht/code/grok-build`
- External upstream PRs are **not** the path — do is a private/local fork
- Every crate patch must appear in `docs/patch-matrix.md`

## Milestone sketch

| Milestone | Focus |
|-----------|--------|
| M0 | Import, build smoke, L1–L13 docs, control plane, proof agent + guided hook, model YAML template |
| M1 | Roles + prompt layers; **wire role→model assignment** from do YAML into agents; **Tab/Shift+Tab role cycle with post-first-message lock** |
| M2 | Continuation coordinator + guided-block safety |
| M3 | Native power tools (CodeGraph, hashline default policy) |
