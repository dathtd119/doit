"""Shared guided-block deny shape for do-owned PreToolUse gates.

Product standard (L6 / VAL-M2-GATE-001): never bare "Permission denied".
Always emit:

  [GATE: <id>] <blocked>
  Do this instead:
  1. ...
  Human involvement: ...   (optional)
  Do not: ...              (optional)

Parity target: pi-ness formatGuidedBlock (read-only reference).
"""

from __future__ import annotations


def format_guided_block(
    gate: str,
    blocked: str,
    instead: list[str],
    *,
    human: str | None = None,
    do_not: str | None = None,
) -> str:
    """Build a model-facing guided denial body."""
    steps = [s.strip() for s in instead if s and s.strip()]
    if not steps:
        steps = ["Choose a different tool or approach; do not retry the same call."]
    lines = [
        f"[GATE: {gate}] {blocked.strip()}",
        "",
        "Do this instead:",
        *[f"{i}. {s}" for i, s in enumerate(steps, 1)],
    ]
    if human and human.strip():
        lines.extend(["", f"Human involvement: {human.strip()}"])
    if do_not and do_not.strip():
        lines.extend(["", f"Do not: {do_not.strip()}"])
    return "\n".join(lines)


def is_guided_shape(reason: str) -> bool:
    """True when reason matches the product guided-block minimum shape."""
    if not reason or not isinstance(reason, str):
        return False
    return "[GATE:" in reason and "Do this instead:" in reason
