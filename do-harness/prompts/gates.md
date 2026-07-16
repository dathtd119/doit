# Named product gates

**Purpose:** Gate ids that must be **named in L0/L1 prompts** and used in deny
reasons as `[GATE: <id>]` + **Do this instead**. Incomplete denials are a product
bug (see root `AGENTS.md` Guided denials).

**Shape:**

```text
[GATE: <id>] <blocked summary>
Do this instead:
1. <safer alternative>
2. ...
Human involvement: <optional>
Do not: <optional thrash path>
```

## M0 / M1 — dangerous shell family

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

## M2+ (planned — add ids here when hooks ship)

| Gate id | Intent | Status |
|---------|--------|--------|
| *(path policy)* | Deny out-of-workspace writes via shell | Planned M2 |
| *(doom-loop)* | Repeated identical failing tool thrash | Planned M2 |
| *(env-mask)* | Sensitive env exposure in shell | Planned M2 |

## Authoring rules

1. New do-owned denial → pick a stable **kebab-case** id → add a row here →
   mention in L0 and any role that should anticipate the gate.
2. Prefer teaching the model in **Do this instead** over silent block.
3. Stock permission engine may still deny without this shape; **do-owned** hooks
   and product surfaces must use guided shape.
