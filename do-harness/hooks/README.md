# do-harness hooks

Product hooks for **do**. Source of truth lives here; install onto product
discovery paths (`~/.config/do/hooks/` or `<project>/.do/hooks/`) so
`xai-grok-hooks` loads them.

Evidence: hook discovery loads `*.json` from those directories
(`crates/codegen/xai-grok-hooks/src/discovery.rs`, `HookSource::Directory`).

## F-M2-CONT: Continuation priority PostToolUse

| File | Role |
|------|------|
| `continuation-nudge.json` | PostToolUse matcher on continuum tools |
| `bin/continuation-nudge.py` | Priority select (interrupt→streak→goal→plan→workflow→todo) + anti-thrash |

Policy: [`docs/continuation.md`](../../docs/continuation.md).  
Verify: `bash do-harness/scripts/verify-continuation.sh` (VAL-M2-CONT-001).

### Behavior

On `PostToolUse` for `update_goal`, plan enter/exit, `todo_write`, and task/spawn
tools, the engine:

1. Updates session state under `<cwd>/.do/continuation/<session>/state.json`
2. Selects the **highest-priority open lane** only
3. Emits a short `Continue lane: <lane> …` nudge unless cooldown / quiet / max-nudges suppress (no thrash loop)

Never dumps full goal/plan/todo bodies. `DO_CONTINUATION_NUDGE=0` disables.

### Enable (project-scoped)

```sh
mkdir -p .do/hooks/bin
ln -sfn ../../do-harness/hooks/continuation-nudge.json .do/hooks/continuation-nudge.json
ln -sfn ../../../do-harness/hooks/bin/continuation-nudge.py .do/hooks/bin/continuation-nudge.py
chmod +x do-harness/hooks/bin/continuation-nudge.py
```

Project hooks may require `/hooks-trust`.

### Verify (no live session)

```sh
python3 do-harness/hooks/bin/continuation-nudge.py --self-test
python3 do-harness/hooks/bin/continuation-nudge.py \
  --fixture do-harness/fixtures/continuation/multi-step-thrash.json
bash do-harness/scripts/verify-continuation.sh
```

## F-EXT-002: Guided dangerous-shell PreToolUse

| File | Role |
|------|------|
| `guided-dangerous-shell.json` | PreToolUse matcher for shell tools |
| `bin/guided-dangerous-shell.py` | Deny dangerous patterns with guided-block reason |

### Behavior

On `PreToolUse` for shell tools (`Bash`, `run_terminal_cmd`, …), the script:

1. Reads the hook envelope JSON from stdin
2. Extracts `toolInput.command`
3. Matches dangerous patterns (`rm -rf /`, `sudo rm`, `pkill`/`killall`, `mkfs`, `dd … of=/dev/…`, fork bombs, device redirects)
4. **Denies** with exit `2` and a **guided** reason:

```text
[GATE: <id>] <what was blocked>

Do this instead:
1. …
2. …

Human involvement: …   # when needed
Do not: …              # anti-thrash
```

Never a bare “Permission denied”. Matches pi-ness `formatGuidedBlock` shape (L6).

### Enable (project-scoped — recommended for do)

From the **do** repo root:

```sh
mkdir -p .do/hooks/bin
ln -sfn ../../do-harness/hooks/guided-dangerous-shell.json .do/hooks/guided-dangerous-shell.json
ln -sfn ../../../do-harness/hooks/bin/guided-dangerous-shell.py .do/hooks/bin/guided-dangerous-shell.py
chmod +x do-harness/hooks/bin/guided-dangerous-shell.py
```

Project hooks may require `/hooks-trust` in the session (stock grok behavior).

### Enable (user-global)

```sh
mkdir -p ~/.config/do/hooks/bin
cp do-harness/hooks/guided-dangerous-shell.json ~/.config/do/hooks/
cp do-harness/hooks/bin/guided-dangerous-shell.py ~/.config/do/hooks/bin/
chmod +x ~/.config/do/hooks/bin/guided-dangerous-shell.py
```

### Verify script contract (no binary required)

```sh
python3 do-harness/hooks/bin/guided-dangerous-shell.py --self-test
# expect: ok: guided-dangerous-shell self-test passed

echo '{"toolInput":{"command":"pkill -9 node"}}' \
  | python3 do-harness/hooks/bin/guided-dangerous-shell.py
# expect: exit 2 + JSON decision deny with [GATE: …] and Do this instead
echo $?
```

### Disable

Remove the JSON from the discovery directory (project or `~/.config/do/hooks/`).
The hook stops on the next session.

### Notes

- Fail-open on parse errors (stock runner contract: only explicit deny blocks).
- PID-specific `kill <pid>` is **allowed** (not `pkill`/`killall`).
- Scoped `rm -rf ./path` under the workspace is **allowed**; root/home wipes are not.
- Full end-to-end discovery proof is **F-EXT-003** (`do-harness/README.md` + script).
