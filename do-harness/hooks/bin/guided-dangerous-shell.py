#!/usr/bin/env python3
"""PreToolUse guard: deny dangerous shell patterns with a guided-block reason.

M0 proof hook for do (F-EXT-002 / VAL-EXT-002). Product identity lives under
do-harness/; install onto ~/.grok/hooks or <project>/.grok/hooks for discovery.

Protocol (xai-grok-hooks command runner):
  - stdin: PreToolUse envelope JSON
  - allow:  {"decision":"allow"} + exit 0
  - deny:   {"decision":"deny","reason":"..."} + exit 2
  - other exit codes: fail-open (allow)

Deny reasons use pi-ness guided-block shape:
  [GATE: <id>] <blocked>
  Do this instead:
  1. ...
  Human involvement: ...   (optional)
  Do not: ...              (optional)

Self-test:  guided-dangerous-shell.py --self-test
"""

from __future__ import annotations

import json
import re
import sys
from typing import Callable

# Patterns that match a dangerous shell fragment (case-insensitive on command).
# Each entry: (gate_id, match_fn, blocked_summary, instead_steps, do_not, human?)
PatternRule = tuple[str, Callable[[str], bool], str, list[str], str, str | None]


def _contains(needle: str) -> Callable[[str], bool]:
    n = needle.lower()

    def _fn(cmd: str) -> bool:
        return n in cmd.lower()

    return _fn


def _re(pattern: str) -> Callable[[str], bool]:
    rx = re.compile(pattern, re.IGNORECASE)

    def _fn(cmd: str) -> bool:
        return rx.search(cmd) is not None

    return _fn


RULES: list[PatternRule] = [
    # Order matters: first match wins. Prefer more specific gates first.
    (
        "dangerous-shell-sudo-rm",
        _re(r"\bsudo\s+.*\brm\s+"),
        "Privileged (`sudo`) remove was blocked.",
        [
            "Operate only on workspace files without sudo.",
            "Use the dedicated file-edit tools when possible.",
            "If elevated delete is truly required, stop and ask the human.",
        ],
        "Retry `sudo rm` or escalate privileges from the agent.",
        "Human must run elevated deletes themselves if needed.",
    ),
    (
        "dangerous-shell-rm-root",
        # Only root/home wipe targets — not every absolute path (e.g. /var/tmp/foo).
        _re(
            r"\brm\s+"
            r"(?:-[a-zA-Z]*\s+|--[a-zA-Z0-9-]+\s+)*"
            r"(?:--no-preserve-root\b|(?:/|/\*|~|\$HOME)(?:\s|$|;|&|\|))"
        ),
        "Destructive recursive delete targeting filesystem root or home was blocked.",
        [
            "Scope deletes to a specific project path you own (never `/` or `~` alone).",
            "Prefer `git clean` / explicit file tools over broad `rm -rf`.",
            "If the user requested a wipe, confirm path and get human approval first.",
        ],
        "Retry the same `rm -rf /` (or equivalent) command.",
        "Ask the human before any bulk delete outside the active workspace.",
    ),
    (
        "dangerous-shell-pkill",
        _re(r"\b(pkill|killall)\b"),
        "Process kill-by-name (`pkill` / `killall`) was blocked — can terminate unrelated user sessions.",
        [
            "Kill only a PID you started in this session (`kill <pid>` after you know it is yours).",
            "Use project service stop commands from a declared manifest when available.",
            "If a port or process is foreign, report the conflict; do not force-kill.",
        ],
        "Use `pkill`/`killall` by process name or retry the same pattern.",
        None,
    ),
    (
        "dangerous-shell-mkfs",
        _re(r"\bmkfs(\.|$)|\bmkfs\."),
        "Filesystem format (`mkfs`) was blocked.",
        [
            "Do not format disks from the agent.",
            "If storage setup is required, document steps for the human operator.",
        ],
        "Retry mkfs or device format commands.",
        "Human-only operation.",
    ),
    (
        "dangerous-shell-dd-device",
        _re(r"\bdd\b.*\bof=/dev/"),
        "Raw write to a block device via `dd` was blocked.",
        [
            "Write only to regular files under the workspace.",
            "Never target `/dev/sd*`, `/dev/nvme*`, or similar from the agent.",
        ],
        "Retry `dd` with `of=/dev/...`.",
        "Human-only operation for device imaging.",
    ),
    (
        "dangerous-shell-fork-bomb",
        _re(r":\(\)\s*\{|: \(\)\s*\{|fork\s*bomb"),
        "Fork-bomb pattern was blocked.",
        [
            "Do not run process-fork bombs or infinite spawn loops.",
            "If you need concurrency, use bounded tools (task/subagent limits).",
        ],
        "Retry fork-bomb or unbounded spawn patterns.",
        None,
    ),
    (
        "dangerous-shell-device-redirect",
        _re(r">\s*/dev/(sd|hd|nvme|vd|xvd)"),
        "Shell redirect writing to a block device was blocked.",
        [
            "Redirect output only to workspace files or `/tmp` under your control.",
            "Never write to block device nodes from the agent.",
        ],
        "Retry redirects into `/dev/sd*` / similar.",
        "Human-only operation.",
    ),
]


def format_guided_block(
    gate: str,
    blocked: str,
    instead: list[str],
    *,
    human: str | None = None,
    do_not: str | None = None,
) -> str:
    """pi-ness guided-block shape (formatGuidedBlock parity)."""
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


def extract_command(envelope: dict) -> str:
    """Pull shell command text from a PreToolUse envelope (best-effort)."""
    tool_input = envelope.get("toolInput") or envelope.get("tool_input") or {}
    if isinstance(tool_input, str):
        try:
            tool_input = json.loads(tool_input)
        except json.JSONDecodeError:
            return tool_input
    if not isinstance(tool_input, dict):
        return ""
    for key in ("command", "cmd", "script", "input"):
        val = tool_input.get(key)
        if isinstance(val, str) and val.strip():
            return val
    return ""


def match_rule(command: str) -> PatternRule | None:
    for rule in RULES:
        _gate, match_fn, *_rest = rule
        if match_fn(command):
            return rule
    return None


def decide(envelope: dict) -> tuple[str, int]:
    """Return (stdout_json, exit_code)."""
    command = extract_command(envelope)
    if not command.strip():
        return json.dumps({"decision": "allow"}), 0
    rule = match_rule(command)
    if rule is None:
        return json.dumps({"decision": "allow"}), 0
    gate, _fn, blocked, instead, do_not, human = rule
    reason = format_guided_block(gate, blocked, instead, human=human, do_not=do_not)
    return json.dumps({"decision": "deny", "reason": reason}), 2


def self_test() -> int:
    failures: list[str] = []

    def expect_deny(cmd: str, gate_substr: str) -> None:
        out, code = decide({"toolInput": {"command": cmd}})
        payload = json.loads(out)
        if code != 2 or payload.get("decision") != "deny":
            failures.append(f"expected deny for {cmd!r}, got {out!r} code={code}")
            return
        reason = payload.get("reason", "")
        if "[GATE:" not in reason or "Do this instead:" not in reason:
            failures.append(f"missing guided shape for {cmd!r}: {reason!r}")
        if gate_substr not in reason:
            failures.append(f"expected gate {gate_substr!r} in reason for {cmd!r}")

    def expect_allow(cmd: str) -> None:
        out, code = decide({"toolInput": {"command": cmd}})
        payload = json.loads(out)
        if code != 0 or payload.get("decision") != "allow":
            failures.append(f"expected allow for {cmd!r}, got {out!r} code={code}")

    expect_deny("rm -rf /", "dangerous-shell-rm-root")
    expect_deny("sudo rm -rf /var/tmp/foo", "dangerous-shell-sudo-rm")
    expect_deny("pkill -9 node", "dangerous-shell-pkill")
    expect_deny("killall python3", "dangerous-shell-pkill")
    expect_deny("mkfs.ext4 /dev/sdb1", "dangerous-shell-mkfs")
    expect_deny("dd if=/dev/zero of=/dev/sda", "dangerous-shell-dd-device")
    expect_deny(":(){ :|:& };:", "dangerous-shell-fork-bomb")
    expect_deny("echo x > /dev/sda", "dangerous-shell-device-redirect")

    expect_allow("ls -la")
    expect_allow("git status")
    expect_allow("cargo check -p xai-grok-pager-bin")
    expect_allow("rm -rf ./target/debug/tmp-build")
    expect_allow("kill 12345")  # PID-specific kill is allowed (not pkill/killall)

    # Guided shape unit check
    sample = format_guided_block(
        "test-gate",
        "blocked thing",
        ["step a", "step b"],
        human="ask user",
        do_not="retry same call",
    )
    for needle in (
        "[GATE: test-gate] blocked thing",
        "Do this instead:",
        "1. step a",
        "2. step b",
        "Human involvement: ask user",
        "Do not: retry same call",
    ):
        if needle not in sample:
            failures.append(f"format_guided_block missing {needle!r}")

    if failures:
        for f in failures:
            print(f"FAIL: {f}", file=sys.stderr)
        print(f"{len(failures)} failure(s)", file=sys.stderr)
        return 1
    print("ok: guided-dangerous-shell self-test passed")
    return 0


def main() -> int:
    if len(sys.argv) > 1 and sys.argv[1] == "--self-test":
        return self_test()
    try:
        raw = sys.stdin.read()
        envelope = json.loads(raw) if raw.strip() else {}
        if not isinstance(envelope, dict):
            envelope = {}
    except json.JSONDecodeError:
        # Fail-open on malformed input
        print(json.dumps({"decision": "allow"}))
        return 0
    out, code = decide(envelope)
    print(out)
    return code


if __name__ == "__main__":
    sys.exit(main())
