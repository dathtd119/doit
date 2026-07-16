# Named product gates

**Purpose:** Gate ids that must be **named in L0/L1 prompts** and used in deny
reasons as `[GATE: <id>]` + **Do this instead**. Incomplete denials are a product
bug (see root `AGENTS.md` Guided denials).

**Product standard (F-M2-GATES / VAL-M2-GATE-001):** every **do-owned** denial
uses the guided-block shape below. Bare “Permission denied” from do-owned gates
is a bug. Stock permission engine denials may still be terse; product hooks and
product surfaces we ship must not be.

**Shape:**

```text
[GATE: <id>] <blocked summary>
Do this instead:
1. <safer alternative>
2. ...
Human involvement: <optional>
Do not: <optional thrash path>
```

Shared helper: `do-harness/hooks/bin/guided_block.py` (`format_guided_block`).

## M0 — dangerous shell family

Implementation: `do-harness/hooks/bin/guided-dangerous-shell.py`  
Hook JSON: `do-harness/hooks/guided-dangerous-shell.json`

| Gate id | Blocks (summary) |
|---------|------------------|
| `dangerous-shell-sudo-rm` | Privileged `sudo` + `rm` |
| `dangerous-shell-rm-root` | Destructive `rm` targeting `/`, `~`, home wipe patterns |
| `dangerous-shell-pkill` | `pkill` / `killall` by process name |
| `dangerous-shell-mkfs` | Filesystem format (`mkfs*`) |
| `dangerous-shell-dd-device` | `dd` to block devices |
| `dangerous-shell-fork-bomb` | Shell fork-bomb patterns |
| `dangerous-shell-device-redirect` | Redirects writing to `/dev/sd*` devices |

## M2 — path policy family

Implementation: `do-harness/hooks/bin/guided-path-policy.py`  
Hook JSON: `do-harness/hooks/guided-path-policy.json`

| Gate id | Blocks (summary) |
|---------|------------------|
| `path-policy-write-outside` | Write/edit tools or shell redirects that target paths outside the session workspace (`cwd`) |

**Allow:** writes under workspace root (relative or absolute).  
**Deny:** absolute paths outside cwd; `..` escapes that resolve outside.  
**Out of scope for this pack:** pure read tools (read/list/grep) — path floors for
read-only roles live under F-M2-PERM / agent profiles.

## M2 — env expose family

Implementation: `do-harness/hooks/bin/guided-env-expose.py`  
Hook JSON: `do-harness/hooks/guided-env-expose.json`

| Gate id | Blocks (summary) |
|---------|------------------|
| `env-expose-dotenv` | Shell read of real `.env` / `.env.*` secret files (not `.example` / `.sample` / `.template`) |
| `env-expose-printenv` | Full environment dumps (`env`, bare `printenv`, `export -p`, …) |
| `env-expose-secret-echo` | Echo/printf of sensitive env var names (API keys, tokens, passwords, …) |

**Allow:** `.env.example` templates; `printenv PATH` / non-secret singles; existence
checks that do not print values.

## Authoring rules

1. New do-owned denial → pick a stable **kebab-case** id → add a row here →
   mention the **family** in L0 and every role prompt that should anticipate the gate.
2. Prefer teaching the model in **Do this instead** over silent block.
3. Stock permission engine may still deny without this shape; **do-owned** hooks
   and product surfaces must use guided shape.
4. Verify: `bash do-harness/scripts/verify-gates.sh` (VAL-M2-GATE-001).
