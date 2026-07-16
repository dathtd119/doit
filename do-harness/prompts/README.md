# do-harness prompts (L0–L1 fragments)

Product prompt fragments for **do**. These are the **named L0/L1 layers** in
[`docs/prompt-system.md`](../../docs/prompt-system.md). Runtime discovery still
loads agent profiles from `do-harness/agents/` (install onto `.grok/agents/`).

## Layout

| Path | Layer | Role |
|------|-------|------|
| `l0-kernel.md` | **L0** | Identity + guided-gate + role-lock rules (session-stable) |
| `gates.md` | L0/L1 ref | Named gate catalog (`[GATE: id]`) |
| `roles/*.md` | **L1** | Per-role contracts (swap target pre-message only) |

## Relationship to agents/

| Surface | Path | Purpose |
|---------|------|---------|
| **Agent profile** | `do-harness/agents/<role>.md` | YAML frontmatter (model, tools, permissionMode) + body; **discovery** |
| **L1 fragment** | `do-harness/prompts/roles/<role>.md` | Canonical role contract text for layer map + freeze policy |

Keep agent body and L1 fragment **aligned**. Prefer editing both when role
mission or gate guidance changes.

## Role lifecycle

Tab/Shift+Tab may swap L1 **only pre-message**. After first user message, L1 is
frozen for the session. See `docs/prompt-system.md` Role lifecycle.

## Gates

All do-owned denials use:

```text
[GATE: <id>] <blocked>
Do this instead:
1. ...
```

Named ids: [`gates.md`](./gates.md). Hook implementation:
`do-harness/hooks/bin/guided-dangerous-shell.py`.

## Install

Fragments are **docs + source of truth** for L0/L1 text. They are not auto-scanned
by stock grok as a separate registry (L2 gap). Product identity for the model
still enters via agent profiles + AGENTS.md + hooks.

Optional: operators may copy/symlink L0 into a custom system overlay when a
future inject path exists; M1 does not require a second discovery root.
