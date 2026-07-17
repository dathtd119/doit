# Code Analyses

## Overview

Runtime and harness analyses for **do** (forked grok-build). Prefer evidence paths under `crates/codegen/` over product docs when they disagree.

## Prompt / agent assembly

| Analysis | Scope | File |
|----------|--------|------|
| **System prompt assembly** | Stock core `prompt.md` + Extend body; what is / is not system | [system-prompt-assembly.md](./system-prompt-assembly.md) |

## Architecture at a glance

```text
LIVE:     templates/prompt.md → base_template() → system head
          + agent prompt_body (Extend)

PRODUCT SoT (edit / customize):
  l0-general.md   ← ${l0_general}
  l0-system.md    ← shell (${l0_general} + ${l0_kernel} + Identity + ${role_body} + Session)
  l0-kernel.md    ← ${l0_kernel}
  roles/*.md      ← ${role_body}
  placeholders.md ← catalog

WIRE:     phase 02 — expand product stack; do not drop general
```

Full detail: [system-prompt-assembly.md](./system-prompt-assembly.md).
