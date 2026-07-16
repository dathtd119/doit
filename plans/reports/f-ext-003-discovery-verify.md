# F-EXT-003 / VAL-EXT-003 — Discovery verification evidence

**Date:** 2026-07-16  
**Repo:** `/home/datht/code/do`  
**Commit (prior ship of script + README):** `ef7771b`  
**Validator:** VAL-EXT-003 (scripted discovery path check — option b)

## Setup (project discovery symlinks)

```sh
mkdir -p .grok/agents .grok/hooks/bin
ln -sfn ../../do-harness/agents/intake.md .grok/agents/intake.md
ln -sfn ../../do-harness/hooks/guided-dangerous-shell.json .grok/hooks/guided-dangerous-shell.json
ln -sfn ../../../do-harness/hooks/bin/guided-dangerous-shell.py .grok/hooks/bin/guided-dangerous-shell.py
chmod +x do-harness/hooks/bin/guided-dangerous-shell.py do-harness/scripts/verify-discovery.sh
```

## Command

```sh
bash do-harness/scripts/verify-discovery.sh
```

## Result

- **Exit code:** 0  
- **Summary line:** `VAL-EXT-003: PASS (scripted discovery path check exit 0)`  
- **Counts:** passed=16 failed=0 warnings=1  

### Checks that passed

1. Source of truth under `do-harness/` (intake agent, hook JSON, hook binary executable)
2. Project discovery paths:
   - `.grok/agents/intake.md` → resolves to `do-harness/agents/intake.md`
   - `.grok/hooks/guided-dangerous-shell.json` → resolves to do-harness source
   - `.grok/hooks/bin/guided-dangerous-shell.py` present for command relative to hook `source_dir`
3. Agent frontmatter: `name: intake`, `permissionMode: plan`, non-empty body
4. Hook JSON: `PreToolUse` + shell matcher + `type: command`
5. Hook behavior: self-test; deny `pkill` with exit 2 + `[GATE: …]`; allow `git status` exit 0
6. Fork evidence citations for `.grok/agents` and `.grok/hooks` discovery in forked crates

### Warning (non-blocking)

- No built `grok` / pager binary in `target/` — VAL-EXT-003(b) path check is the authoritative M0 proof (documented in `do-harness/README.md`).

## Docs

`do-harness/README.md` section **Verify discovery (F-EXT-003 / VAL-EXT-003)** documents the primary script and optional binary inspect path.

## Manifest

`services.yaml` command: `verify_discovery: bash do-harness/scripts/verify-discovery.sh`
