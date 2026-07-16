# do

**do** is a forked **Grok Build** coding-agent harness that absorbs **pi-ness** harness-control ideas and **OpenCode-style** multi-model / config control ergonomics.

This tree is a **private/local fork** of Grok Build (Rust: pager, shell, tools, agent). Upstream grok-build and pi-ness trees are **read-only references** — we import by **copy**, never modify them in place.

| Surface | Role |
|---------|------|
| `crates/` + codegen | Forked grok-build workspace (binary lineage `xai-grok-pager-bin`) |
| `do-harness/` | Product identity: agents, hooks, skills, prompts, model assignment YAML |
| `docs/` | Durable design, inventories, ship discipline |
| `AGENTS.md` | Operating contract for humans and agents |
| `CHANGELOGS.md` | What shipped |

## Product intent

- Harness control on a native-rich base: roles, prompt layers, progressive catalogs, guided gates, workspace continuum, continuation
- **Multi-model is required:** register N models; assign orchestrator / explorer / worker / oracle (and intake) like OpenCode agent model pins
- Prefer **extension** (do-harness, config, plugins) before crate patches
- Dual config: stock `~/.grok/config.toml` for native multi-model; optional do YAML overlay for assignment UX

## Docs (start here)

| Doc | For |
|-----|-----|
| [AGENTS.md](./AGENTS.md) | Operating contract + living status |
| [docs/index.md](./docs/index.md) | Doc map |
| [docs/architecture.md](./docs/architecture.md) | System architecture |
| [docs/models-and-config.md](./docs/models-and-config.md) | Multi-model + role assignment design |
| [docs/milestone-ship-discipline.md](./docs/milestone-ship-discipline.md) | Docs + commit every milestone |
| [CHANGELOGS.md](./CHANGELOGS.md) | Ship log |

## Build (forked binary)

Requirements: Rust (see `rust-toolchain.toml`), protoc (`bin/protoc` or `PATH`).

```sh
cargo check -p xai-grok-pager-bin            # smoke
cargo run -p xai-grok-pager-bin              # build + launch TUI
cargo build -p xai-grok-pager-bin --release  # release binary
```

The artifact is named `xai-grok-pager` (upstream installs as `grok`). Config discovery for M0 keeps **`~/.grok`** conventions; product brand is **do** in docs and harness.

## Multi-model (accurate facts)

Grok-build **already** supports multiple custom models in `~/.grok/config.toml` (`[model.<name>]` × N, `[models] default`, api backends). Subagents resolve model as: spawn override > role > persona > parent.

**do** adds product ergonomics: `do-harness/config.models.yaml` (registry + role assignment) mapping into stock TOML and agent frontmatter. See [docs/models-and-config.md](./docs/models-and-config.md). Gap vs OpenCode assignment UX is limitation **L13**.

## Constraints (short)

- Never modify `~/code/pi-ness` or `~/code/grok-build`
- Extension-before-deep-fork
- English only; conventional commits; commit every milestone
- Preserve Apache-2.0 + `THIRD-PARTY-NOTICES` / LICENSE from import

Full rules: [AGENTS.md](./AGENTS.md). Fork policy expansion: `FORK.md` (M0 deliverable).

## License

Apache-2.0 and third-party notices from the grok-build import — see `LICENSE` / `THIRD-PARTY-NOTICES` when present in tree.

---

### Upstream Grok Build notes

The imported tree remains a Grok Build coding agent (TUI, headless, ACP). Official upstream docs live at [docs.x.ai/build](https://docs.x.ai/build/overview). Local user guide may ship under `crates/codegen/xai-grok-pager/docs/user-guide/`.

This README’s **product framing** is for **do**; crate-level upstream README content may still appear in subtrees.
