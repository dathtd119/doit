# Limitations inventory (L1–L13)

**Status:** M0 — L13 sealed with fork evidence under **F-MODEL-001**. L1–L12 rows are architecture-aligned stubs; **F-DOC-001** deepens evidence paths into pi-ness and forked crates.

Product thesis: pi-ness harness control + OpenCode assignment ergonomics on forked Grok Build. Each row: idea → stock grok status → gap → preferred path → evidence.

| ID | Idea | Stock grok-build | Gap / risk | Preferred path | Evidence (seed) |
|----|------|------------------|------------|----------------|-----------------|
| L1 | Role roster as **primary session** control + tool/skill deny floors; **Tab cycle only pre-message, lock after first message** | Agents + personas (subagent-centric); not full intake→orchestrator role machine | Primary-session role cycle weaker than pi-ness; no post-message lock yet | Agents/profiles + config first; M1 implement Tab cycle + post-message lock | `docs/prompt-system.md`; root `AGENTS.md` Role switch lock |
| L2 | L0–L6 layered prompt assembly + fragment registry/maxBytes | System/agent prompts, skills, reminders — different assembly model | No explicit L0–L6 control plane | Prompt templates + plugin injects; crate patch for budget/registry if needed | `docs/prompt-system.md` (stub); pi-ness reference (read-only) |
| L3 | Always-on native harness factories (TS) | Monolithic Rust tool registry + plugins/hooks | No TS factory inject; must use Rust/plugin seams | Plugin + hooks for behavior; new tools under `xai-grok-tools` when native | `docs/grok-build/extension-seams.md` |
| L4 | Progressive skill/MCP catalog (dynamic mode, not dump) | Skills listing + discovery reminders exist | May still be too firehose vs pi-ness dynamic mode | Config/skills ignore + reminder tuning; patch skill prompt builder if needed | `docs/grok-build/native-tools.md` |
| L5 | Continuation coordinator (interrupt→streak→goal→plan→workflow→todo) | Goal classifier + plan mode + todos exist separately | No unified priority coordinator | SessionActor / shell hooks first; coordinator crate if multi-lane races | `docs/workspace.md` (stub) |
| L6 | Guided blocks `[GATE:…]` + “Do this instead” | Permissions + PreToolUse hooks | Denials less “teach the model” | Hooks + tool error shapes; small tools-api patch for standard gate format | `docs/grok-build/extension-seams.md` (hooks) |
| L7 | CodeGraph lean tools | No first-party codegraph package observed | Semantic nav missing | MCP or plugin wrapping local codegraph; optional native tool later | `docs/grok-build/hard-limits.md` |
| L8 | Side-ask dual stream / intake default role | `ask_user_question`, modes | No side dual-stream product | Defer UI polish; intake agent profile first | F-EXT-001 intake agent |
| L9 | Workspace disk state `.piness/` L6 | Session dir + plan.md + goals | Different layout/semantics | Map `.do/` or reuse `.grok/` session layout; document contract | `docs/workspace.md` |
| L10 | Overlay-first without forking Pi | **This is a fork** of grok-build | Must own fork hygiene, rebases, branding | Fork policy + clear “do” identity vs upstream `grok` | `FORK.md` (F-DOC-004) |
| L11 | Node/OpenTUI stack | Rust/ratatui pager | Different contrib model & UI extension cost | Accept Rust; extend via plugins before TUI deep forks | `docs/grok-build/hard-limits.md` |
| L12 | Compat patches to upstream dist | Full source tree available | Easier to patch crates, harder to stay mergeable | Prefer config/plugin; minimize core diffs; document every patch | `docs/patch-matrix.md` |
| **L13** | **OpenCode-like multi-model assignment** (provider catalog + agent.model pins + effort) | **Multi-model registry already exists** (`[model.*]`, default, api_backend; subagent resolution spawn > role > persona > parent; roles/personas pin `model` + `reasoning_effort`) | **Assignment UX and role→model policy** weaker; no product YAML overlay; operators hand-edit TOML + agent files without a single assignment table | do-harness YAML + agent frontmatter / role model fields; keep stock TOML as runtime source of truth; M1 wire | **See L13 detail below** |

## L13 detail (multi-model assignment UX)

### Statement

Grok **already** multi-models. The gap is **controllable assignment** at product quality comparable to OpenCode (one table: role → model [+ effort]), not a second inference runtime.

### Evidence (fork)

| Fact | Path under `/home/datht/code/do` |
|------|----------------------------------|
| Custom models guide | `crates/codegen/xai-grok-pager/docs/user-guide/11-custom-models.md` |
| Subagent model pins / roles | `crates/codegen/xai-grok-pager/docs/user-guide/16-subagents.md` |
| Resolution crate | `crates/codegen/xai-grok-subagent-resolution/src/lib.rs` |
| Precedence: spawn > role > persona > parent | `crates/codegen/xai-grok-subagent-resolution/src/types.rs` (`EffectiveRuntimeConfig`) |
| Role/persona model + reasoning_effort | `crates/codegen/xai-grok-subagent-resolution/src/config.rs` |
| `[model.*]` hot-reload | `crates/codegen/xai-grok-shell/src/config/reloader.rs` |

### OpenCode contrast (read-only)

- Agent frontmatter / config `model:` pins (e.g. user `~/.config/opencode/agent/*.md`, `opencode.jsonc` agent blocks)
- Central agent→model tables in plugin configs (e.g. oh-my-opencode-slim)

### Product response

| Artifact | Role |
|----------|------|
| [models-and-config.md](./models-and-config.md) | Full design, schema, mapping |
| `do-harness/config.models.yaml` | M0 template: `models.registry` + `assignment` |
| M1 | Wire assignment into agents/roles; optional TOML emit/diff |

### Non-goals

- YAML-only runtime that bypasses `~/.grok/config.toml`
- Competing multi-model registry in Rust for M0

## Related

- [architecture.md](./architecture.md) — compact L1–L13 table  
- [models-and-config.md](./models-and-config.md) — L13 design home  
- [patch-matrix.md](./patch-matrix.md) — gap → path / risk / order  
- [grok-build/](./grok-build/) — base inventory  
