# doit

**doit** is a forked **Grok Build** coding-agent harness that absorbs **pi-ness** harness-control ideas and **OpenCode-style** multi-model / config control ergonomics.

This tree is a **private/local fork** of Grok Build (Rust: pager, shell, tools, agent). Upstream grok-build and pi-ness trees are **read-only references** — we import by **copy**, never modify them in place. External upstream PRs are **not** the product contribution path.

| Surface | Role |
|---------|------|
| `crates/` + codegen | Forked grok-build workspace (product package `doit`, binary lineage pager-bin) |
| `do-harness/` | Product identity: agents, hooks, skills, prompts, model assignment YAML |
| `docs/` | Durable design, inventories, ship discipline |
| `AGENTS.md` | Operating contract for humans and agents |
| `FORK.md` | Fork hygiene, config root, dual model surface, extension order |
| `CHANGELOGS.md` | What shipped |

## Product intent

- **Harness control** on a native-rich base: roles, prompt layers, progressive catalogs, guided gates, workspace continuum, continuation
- **Multi-model is required:** register N models; assign intake / orchestrator / explorer / worker / oracle like OpenCode agent model pins
- Prefer **extension** (do-harness, `~/.config/doit` + project `.doit/`, plugins) before crate patches — then tool packs, then surgical patches, deep TUI last
- **Dual config surface:**
  - Stock **`~/.config/doit/config.toml`** (`$GROK_HOME`) — native multi-model registry (runtime)
  - **`do-harness/config.models.yaml`** — product assignment overlay (apply → agent frontmatter)

A small `SOURCE_REV` file at the root records the full monorepo commit SHA for the version of the upstream code last absorbed.

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

## Config root (CFG sealed)

| Layer | Location | Role |
|-------|----------|------|
| User home + TOML | **`~/.config/doit`** only when `GROK_HOME` unset | Multi-model `config.toml`, user agents/hooks/sessions |
| Project discovery | **`.doit/`** (agents, hooks, plan, config, skills, …) | Product install / discovery targets |
| Product overlay | `do-harness/` in this repo | Source of truth for do identity; link/copy onto `.doit/` and home |
| Override | **`GROK_HOME`** | Full user-home root replace (`DO_HOME` not wired) |

Do **not** invent a second runtime registry the binary ignores. Map YAML → TOML + agent frontmatter. No silent default dual-read of `~/.grok`.

## Multi-model (accurate facts)

Grok-build **already** supports multiple custom models in `~/.config/doit/config.toml` (`[model.<name>]` × N, `[models] default`, api backends). Subagents resolve model as: **spawn override > role > persona > parent**.

**do** adds product ergonomics: `do-harness/config.models.yaml` (registry + role assignment) mapping into stock TOML and agent frontmatter. See [docs/models-and-config.md](./docs/models-and-config.md). Gap vs OpenCode assignment UX is limitation **L13**.

## Install

Product package and binary are both **`doit`**. Releases ship from
**[dathtd119/doit](https://github.com/dathtd119/doit)** (not crates.io).

### Prebuilt (preferred)

Once a `v*` GitHub Release exists (six targets: Linux/macOS/Windows × x86_64/aarch64):

```sh
# cargo-binstall reads [package.metadata.binstall] → dathtd119/doit releases
cargo binstall --git https://github.com/dathtd119/doit.git doit

# or download an archive from:
#   https://github.com/dathtd119/doit/releases
# assets: doit-<version>-<target>.tar.gz | .zip
```

### From source (clone or git)

Requires **Rust** (pinned by [`rust-toolchain.toml`](rust-toolchain.toml)) and
**[DotSlash](https://dotslash-cli.com)** so [`bin/protoc`](bin/protoc) can run:

```sh
cargo install dotslash                       # once; enables bin/protoc
# or: prebuilt packages — https://dotslash-cli.com/docs/installation/

# from a clone:
cargo install --path crates/codegen/doit --locked

# or without cloning first:
cargo install --git https://github.com/dathtd119/doit.git \
  --package doit --locked
```

**Not an install path:** crates.io publish (`cargo install doit` from the registry).
This monorepo is path/git only; use Releases / binstall / git install above.

## Build (forked binary)

Requirements:

- **Rust** — `rustup` installs the pinned toolchain on first build.
- **[DotSlash](https://dotslash-cli.com)** on `PATH` before building (see Install).
- **protoc** — via DotSlash `bin/protoc`, or `protoc` / `$PROTOC` on `PATH`.
- Network for first crates.io fetch (or a warm `~/.cargo` cache).
- macOS and Linux are supported build hosts; Windows builds are best-effort
  outside the release matrix.

```sh
cargo install dotslash                       # once; enables bin/protoc
cargo check -p doit                          # smoke (product package)
cargo run -p doit                            # build + launch TUI
cargo build -p doit --release                # release binary
```

`bin/protoc` is a [dotslash](https://dotslash-cli.com/) wrapper that fetches protobuf `protoc` v29.3. Without `dotslash`, build scripts fail with `protoc command failed`.

Product default config home is **`~/.config/doit`**; project discovery is **`.doit/`** (see [FORK.md](./FORK.md) §4).

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
- Local agent state (`AGENTS.md`, `plans/`, `.opencode/`, `.doit/`, legacy `.grok/` if present) is **gitignored** — do not `git clean -fdx` or hard-reset without checking untracked work

Full rules: [AGENTS.md](./AGENTS.md) (local). Fork policy: [FORK.md](./FORK.md).

## License

Apache-2.0 and third-party notices from the grok-build import — see `LICENSE` / `THIRD-PARTY-NOTICES` when present in tree.

---

### Upstream Grok Build notes

The imported tree is a Grok Build coding-agent base (TUI, headless, ACP). **Product brand is Doit** (binary/package `doit`). Official upstream docs live at [docs.x.ai/build](https://docs.x.ai/build/overview). Product user guide ships under `crates/codegen/xai-grok-pager/docs/user-guide/` (Doit-branded).

This README’s **product framing** is for **doit**; crate-level upstream README content may still appear in subtrees.
