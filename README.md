# do

**do** is a forked **Grok Build** coding-agent harness that absorbs **pi-ness** harness-control ideas and **OpenCode-style** multi-model / config control ergonomics.

This tree is a **private/local fork** of Grok Build (Rust: pager, shell, tools, agent). Upstream grok-build and pi-ness trees are **read-only references** — we import by **copy**, never modify them in place. External upstream PRs are **not** the product contribution path.

| Surface | Role |
|---------|------|
| `crates/` + codegen | Forked grok-build workspace (binary lineage `xai-grok-pager-bin`) |
| `do-harness/` | Product identity: agents, hooks, skills, prompts, model assignment YAML |
| `docs/` | Durable design, inventories, ship discipline |
| `AGENTS.md` | Operating contract for humans and agents |
| `FORK.md` | Fork hygiene, config root, dual model surface, extension order |
| `CHANGELOGS.md` | What shipped |

## Product intent

- **Harness control** on a native-rich base: roles, prompt layers, progressive catalogs, guided gates, workspace continuum, continuation
- **Multi-model is required:** register N models; assign intake / orchestrator / explorer / worker / oracle like OpenCode agent model pins
- Prefer **extension** (do-harness, `~/.grok` config, plugins) before crate patches — then tool packs, then surgical patches, deep TUI last
- **Dual config surface:**
  - Stock **`~/.grok/config.toml`** — native multi-model registry (runtime)
  - **`do-harness/config.models.yaml`** — product assignment overlay (M0 template; M1 wire)

Fork policy, config root decision, and contribution rules: **[FORK.md](./FORK.md)**.

## Docs (start here)

| Doc | For |
|-----|-----|
| [AGENTS.md](./AGENTS.md) | Operating contract + living status |
| [FORK.md](./FORK.md) | Fork policy + identity (VAL-DOC-004) |
| [docs/index.md](./docs/index.md) | Doc map |
| [docs/architecture.md](./docs/architecture.md) | System architecture |
| [docs/models-and-config.md](./docs/models-and-config.md) | Multi-model + role assignment design |
| [docs/milestone-ship-discipline.md](./docs/milestone-ship-discipline.md) | Docs + commit every milestone |
| [CHANGELOGS.md](./CHANGELOGS.md) | Ship log |

## Config root (M0)

| Layer | Location | Role |
|-------|----------|------|
| Stock discovery + TOML | **`~/.grok`** (project `.grok/` where applicable) | Agents, hooks, skills, `config.toml` multi-model |
| Product overlay | `do-harness/` in this repo | Source of truth for do identity; link/copy onto discovery paths |
| Brand | **do** in docs and harness | Runtime paths stay `~/.grok` until a later rebrand |

Do **not** invent a second runtime registry the binary ignores. Map YAML → TOML + agent frontmatter.

## Multi-model (accurate facts)

Grok-build **already** supports multiple custom models in `~/.grok/config.toml` (`[model.<name>]` × N, `[models] default`, api backends). Subagents resolve model as: **spawn override > role > persona > parent**.

**do** adds product ergonomics: `do-harness/config.models.yaml` (registry + role assignment) mapping into stock TOML and agent frontmatter. See [docs/models-and-config.md](./docs/models-and-config.md). Gap vs OpenCode assignment UX is limitation **L13**.

## Build (forked binary)

Requirements:

- Rust (see `rust-toolchain.toml`)
- **`dotslash`** on `PATH` so repo `bin/protoc` resolves (`cargo install dotslash`)
- Network for first crates.io fetch (or a warm `~/.cargo` cache)

```sh
cargo install dotslash                       # once; enables bin/protoc
cargo check -p xai-grok-pager-bin            # smoke (VAL-FORK-002)
cargo run -p xai-grok-pager-bin              # build + launch TUI
cargo build -p xai-grok-pager-bin --release  # release binary
```

`bin/protoc` is a [dotslash](https://dotslash-cli.com/) wrapper that fetches protobuf `protoc` v29.3. Without `dotslash`, build scripts fail with `protoc command failed`.

The artifact is named `xai-grok-pager` (upstream installs as `grok`). Config discovery for M0 keeps **`~/.grok`** conventions; product brand is **do** in docs and harness.

## Quality / agent readiness

```sh
bash scripts/validate-agents-md.sh          # README + agent doc smoke
bash scripts/check-large-files.sh           # product-path size gates
bash scripts/check-tech-debt.sh             # linked TODO/FIXME policy
bash scripts/generate-docs.sh               # docs/generated/*
# optional: pip install pre-commit && pre-commit install
```

CI (`.github/workflows/ci.yml`): fmt, clippy complexity, tests + timing, coverage floor, jscpd, CodeQL, PR review comments.  
Runbooks: [docs/runbooks/](./docs/runbooks/). Dependency wait policy: [docs/dependency-policy.md](./docs/dependency-policy.md).  
Dev container: [.devcontainer/](./.devcontainer/). Env template: [.env.example](./.env.example).

## Constraints (short)

- Never modify `~/code/pi-ness` or `~/code/grok-build` — copy into do only
- Extension-before-deep-fork ([FORK.md](./FORK.md) §3)
- No external upstream PRs as the product path
- English only; conventional commits; commit every milestone
- Preserve Apache-2.0 + `THIRD-PARTY-NOTICES` / LICENSE from import
- Local agent state (`AGENTS.md`, `plans/`, `.opencode/`, `.grok/`) is **gitignored** — do not `git clean -fdx` or hard-reset without checking untracked work

Full rules: [AGENTS.md](./AGENTS.md) (local). Fork policy: [FORK.md](./FORK.md).

## License

Apache-2.0 and third-party notices from the grok-build import — see `LICENSE` / `THIRD-PARTY-NOTICES` when present in tree.

---

### Upstream Grok Build notes

The imported tree remains a Grok Build coding agent (TUI, headless, ACP). Official upstream docs live at [docs.x.ai/build](https://docs.x.ai/build/overview). Local user guide may ship under `crates/codegen/xai-grok-pager/docs/user-guide/`.

This README’s **product framing** is for **do**; crate-level upstream README content may still appear in subtrees.
