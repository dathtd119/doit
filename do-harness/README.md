# do-harness

Product identity layer for **do** (forked grok-build): agents, hooks, skills,
prompts, and model-assignment YAML. Source of truth lives **here**; install onto
stock grok discovery paths (`~/.grok` conventions for M0, or project `.grok/`).

See root [`AGENTS.md`](../AGENTS.md) Customization Order and
[`docs/grok-build/extension-seams.md`](../docs/grok-build/extension-seams.md).

## Layout

| Path | Role |
|------|------|
| `agents/` | Product roster agent profiles (`.md` with YAML frontmatter) |
| `prompts/` | **L0/L1 fragments** + named gates (`docs/prompt-system.md` map; F-M1-PROMPT) |
| `hooks/` | PreToolUse / other hook JSON + command scripts |
| `config.models.yaml` | Multi-model registry + role→model assignment template (M1 wire) |
| `scripts/verify-discovery.sh` | **F-EXT-003** end-to-end discovery path check (intake + guided hook) |
| `scripts/verify-roster.sh` | **F-M1-ROSTER / VAL-M1-ROSTER-001** five-agent roster discovery |

## Discovery paths (stock grok)

do-harness files are **not** auto-scanned from `do-harness/`. They must land on
paths the forked binary already walks:

| Asset | Runtime discovery path | Evidence in fork |
|-------|------------------------|------------------|
| Agents | `<project>/.grok/agents/*.md` (cwd → git root), then `~/.grok/agents/` | `crates/codegen/xai-grok-agent/src/discovery.rs` (`PROJECT_AGENT_SUBDIRS`) |
| Hooks | `<git-root>/.grok/hooks/*.json`, then `~/.grok/hooks/` | `crates/codegen/xai-grok-shell/src/util/hooks.rs` (`discover_hook_source_paths`); load via `xai-grok-hooks` `HookSource::Directory` |

**M0 install pattern:** symlink from project `.grok/` into `do-harness/` so the
repo is the single source of truth.

## Product roster (M1 — F-M1-ROSTER / VAL-M1-ROSTER-001)

Five primary-session roles under [`agents/`](./agents/). Source of truth is
`do-harness/agents/`; install onto project `.grok/agents/` (symlinks preferred).

| Role | Source | Typical use | Tool floor (M1 stub OK) |
|------|--------|-------------|-------------------------|
| **intake** | [`agents/intake.md`](./agents/intake.md) | Clarify intent; Intent Pack; no implementation | plan; read/list/grep; no edits |
| **orchestrator** | [`agents/orchestrator.md`](./agents/orchestrator.md) | Goal/plan/todo; spawn specialists | continuum + task; no bulk write |
| **explorer** | [`agents/explorer.md`](./agents/explorer.md) | Fast scout / maps / citations | plan; read-only scout |
| **worker** | [`agents/worker.md`](./agents/worker.md) | Implementation + targeted verify | default; full edit surface |
| **oracle** | [`agents/oracle.md`](./agents/oracle.md) | Architecture / hard decisions | plan; analysis; no bulk edit |

Model pins: `config.models.yaml` `assignment.<role>` (apply script lands in
**F-M1-MODEL-APPLY**). Until apply is wired, frontmatter uses `model: inherit`.

Role switch lock (product policy): Tab/Shift+Tab **only pre-message**; locked
after first user message — see root `AGENTS.md` / `docs/prompt-system.md`.

### Prompt fragments (F-M1-PROMPT / VAL-M1-PROMPT-001)

| Path | Layer |
|------|-------|
| [`prompts/l0-kernel.md`](./prompts/l0-kernel.md) | L0 identity + guided-gate + role-lock rules |
| [`prompts/gates.md`](./prompts/gates.md) | Named `[GATE: …]` catalog |
| [`prompts/roles/*.md`](./prompts/roles/) | L1 role contracts (aligned with agents) |

Full inject map and budgets: [`docs/prompt-system.md`](../docs/prompt-system.md).  
Continuum disk contract: [`docs/workspace.md`](../docs/workspace.md).

### Verify roster

```sh
bash do-harness/scripts/verify-roster.sh
# expect: exit 0 and "VAL-M1-ROSTER-001: PASS"
```

## Proof assets (M0)

### Intake agent (F-EXT-001 / VAL-EXT-001)

- Source: [`agents/intake.md`](./agents/intake.md)
- Discovery: `.grok/agents/intake.md` → symlink to source
- Role: clarify-only intake; `permissionMode: plan`; no file edits
- **M1:** intake remains part of the five-role product roster (above)

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
# Full product roster (M1)
mkdir -p .grok/agents
for role in intake orchestrator explorer worker oracle; do
  ln -sfn ../../do-harness/agents/${role}.md .grok/agents/${role}.md
done

# Hook (M0 proof; still recommended)
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
for role in intake orchestrator explorer worker oracle; do
  cp do-harness/agents/${role}.md ~/.grok/agents/
done
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

## Non-goals

- Wiring YAML assignment into the binary runtime (M1 apply script is separate)
- Tab cycle + post-message lock implementation (M1 crate/session; not this roster file set)
- Always-on guided-block productization (M2)
- Deep crate patches for discovery (extension path is enough)
- Role permission floors productization beyond stub floors (M2 F-M2-PERM)
