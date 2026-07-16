# do-harness hooks

Product hooks for **do**. Source of truth lives here; install onto grok discovery
paths (`~/.grok/hooks/` or `<project>/.grok/hooks/`) so `xai-grok-hooks` loads them.

Evidence: hook discovery loads `*.json` from those directories
(`crates/codegen/xai-grok-hooks/src/discovery.rs`, `HookSource::Directory`).

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
mkdir -p .grok/hooks/bin
ln -sfn ../../do-harness/hooks/guided-dangerous-shell.json .grok/hooks/guided-dangerous-shell.json
ln -sfn ../../../do-harness/hooks/bin/guided-dangerous-shell.py .grok/hooks/bin/guided-dangerous-shell.py
chmod +x do-harness/hooks/bin/guided-dangerous-shell.py
```

Project hooks may require `/hooks-trust` in the session (stock grok behavior).

### Enable (user-global)

```sh
mkdir -p ~/.grok/hooks/bin
cp do-harness/hooks/guided-dangerous-shell.json ~/.grok/hooks/
cp do-harness/hooks/bin/guided-dangerous-shell.py ~/.grok/hooks/bin/
chmod +x ~/.grok/hooks/bin/guided-dangerous-shell.py
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

Remove the JSON from the discovery directory (project or `~/.grok/hooks/`). The
hook stops on the next session.

### Notes

- Fail-open on parse errors (stock runner contract: only explicit deny blocks).
- PID-specific `kill <pid>` is **allowed** (not `pkill`/`killall`).
- Scoped `rm -rf ./path` under the workspace is **allowed**; root/home wipes are not.
- Full end-to-end discovery proof is **F-EXT-003** (`do-harness/README.md` + script).
