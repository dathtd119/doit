# do-harness

Product identity layer for **do** (forked grok-build): agents, hooks, skills,
prompts, and model-assignment YAML. Source of truth lives **here**; install onto
stock grok discovery paths (`~/.grok` conventions for M0, or project `.grok/`).

See root [`AGENTS.md`](../AGENTS.md) Customization Order and
[`docs/grok-build/extension-seams.md`](../docs/grok-build/extension-seams.md).

## Layout

| Path | Role |
|------|------|
| `agents/` | Agent profiles (`.md` with YAML frontmatter) |
| `hooks/` | PreToolUse / other hook JSON + command scripts |
| `config.models.yaml` | Multi-model registry + role→model assignment template (M1 wire) |
| `scripts/verify-discovery.sh` | **F-EXT-003** end-to-end discovery path check |

## Discovery paths (stock grok)

do-harness files are **not** auto-scanned from `do-harness/`. They must land on
paths the forked binary already walks:

| Asset | Runtime discovery path | Evidence in fork |
|-------|------------------------|------------------|
| Agents | `<project>/.grok/agents/*.md` (cwd → git root), then `~/.grok/agents/` | `crates/codegen/xai-grok-agent/src/discovery.rs` (`PROJECT_AGENT_SUBDIRS`) |
| Hooks | `<git-root>/.grok/hooks/*.json`, then `~/.grok/hooks/` | `crates/codegen/xai-grok-shell/src/util/hooks.rs` (`discover_hook_source_paths`); load via `xai-grok-hooks` `HookSource::Directory` |

**M0 install pattern:** symlink from project `.grok/` into `do-harness/` so the
repo is the single source of truth.

## Proof assets (M0)

### Intake agent (F-EXT-001 / VAL-EXT-001)

- Source: [`agents/intake.md`](./agents/intake.md)
- Discovery: `.grok/agents/intake.md` → symlink to source
- Role: clarify-only intake; `permissionMode: plan`; no file edits

### Guided dangerous-shell hook (F-EXT-002 / VAL-EXT-002)

- Source: [`hooks/guided-dangerous-shell.json`](./hooks/guided-dangerous-shell.json)
  + [`hooks/bin/guided-dangerous-shell.py`](./hooks/bin/guided-dangerous-shell.py)
- Discovery: `.grok/hooks/*` → symlinks to source
- Behavior: PreToolUse on shell tools; deny dangerous patterns with
  `[GATE: …]` + **Do this instead** (never bare “Permission denied”)
- Enablement detail: [`hooks/README.md`](./hooks/README.md)

## Enable (project-scoped — recommended)

From the **do** repo root:

```sh
# Agent
mkdir -p .grok/agents
ln -sfn ../../do-harness/agents/intake.md .grok/agents/intake.md

# Hook
mkdir -p .grok/hooks/bin
ln -sfn ../../do-harness/hooks/guided-dangerous-shell.json \
  .grok/hooks/guided-dangerous-shell.json
ln -sfn ../../../do-harness/hooks/bin/guided-dangerous-shell.py \
  .grok/hooks/bin/guided-dangerous-shell.py
chmod +x do-harness/hooks/bin/guided-dangerous-shell.py
```

Project hooks may require `/hooks-trust` in a live session (stock grok).

### Enable (user-global)

```sh
mkdir -p ~/.grok/agents ~/.grok/hooks/bin
cp do-harness/agents/intake.md ~/.grok/agents/
cp do-harness/hooks/guided-dangerous-shell.json ~/.grok/hooks/
cp do-harness/hooks/bin/guided-dangerous-shell.py ~/.grok/hooks/bin/
chmod +x ~/.grok/hooks/bin/guided-dangerous-shell.py
```

## Verify discovery (F-EXT-003 / VAL-EXT-003)

VAL-EXT-003 accepts either (a) headless/CLI listing on the forked binary, or
(b) a **scripted** check that exits 0 confirming assets sit on the real
discovery path. Mocks alone are insufficient.

### Primary: scripted discovery path check (b)

```sh
# From do repo root (or any cwd — script resolves paths)
bash do-harness/scripts/verify-discovery.sh
# expect: exit 0 and "VAL-EXT-003: PASS"
```

What the script proves:

1. Source files exist under `do-harness/`
2. Project `.grok/agents/intake.md` and `.grok/hooks/…` exist and resolve to source
3. Agent frontmatter matches grok agent conventions (`name: intake`, …)
4. Hook JSON has `PreToolUse` + shell matcher + `type: command` handler
5. Hook command target exists under the hook `source_dir`
6. Guided deny/allow self-test passes (`[GATE: …]` shape)
7. Forked source still documents `.grok/agents` and `.grok/hooks` as discovery paths

Optional override:

```sh
DO_REPO_ROOT=/path/to/do bash do-harness/scripts/verify-discovery.sh
```

### Optional: forked binary inspect (a)

If you have a built pager/agent binary with `inspect`:

```sh
cargo build -p xai-grok-pager-bin   # when you need a binary
# then, from do root (exact CLI flag may vary by build):
#   target/debug/<binary> inspect --json
# Expect agents[] to include name "intake" and hooks to include PreToolUse /
# guided-dangerous-shell when project trust allows project hooks.
```

The verify script runs this automatically when a built binary is found; path
checks remain the authoritative M0 proof when no binary is present.

### Hook contract only (no discovery)

```sh
python3 do-harness/hooks/bin/guided-dangerous-shell.py --self-test
```

## Model assignment template

[`config.models.yaml`](./config.models.yaml) — registry + role→model table.
Maps to stock `~/.grok/config.toml` `[model.*]` and agent frontmatter `model`
in M1. See [`docs/models-and-config.md`](../docs/models-and-config.md).

## Non-goals (M0)

- Wiring YAML assignment into the binary (M1)
- Full role roster + Tab cycle (M1)
- Always-on guided-block productization (M2)
- Deep crate patches for discovery (extension path is enough)
