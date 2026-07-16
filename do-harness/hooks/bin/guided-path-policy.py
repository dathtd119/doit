#!/usr/bin/env python3
"""PreToolUse guard: deny writes outside the session workspace with guided blocks.

F-M2-GATES / VAL-M2-GATE-001 — path-policy pack (beyond dangerous-shell).

Protocol (xai-grok-hooks command runner):
  - stdin: PreToolUse envelope JSON
  - allow:  {"decision":"allow"} + exit 0
  - deny:   {"decision":"deny","reason":"..."} + exit 2
  - other exit codes: fail-open (allow)

Self-test:  guided-path-policy.py --self-test
"""

from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path

# Same-dir import of shared guided_block (discovery runs from hooks/ as source_dir).
sys.path.insert(0, str(Path(__file__).resolve().parent))
from guided_block import format_guided_block, is_guided_shape  # noqa: E402

# Write / edit tools that carry a path in toolInput
WRITE_TOOL_RE = re.compile(
    r"^(write|Write|search_replace|SearchReplace|str_replace|StrReplace|"
    r"edit|Edit|create|Create|apply_patch|ApplyPatch|MultiEdit|"
    r"hashline_edit|hashline_write)$",
    re.IGNORECASE,
)

SHELL_TOOL_RE = re.compile(
    r"^(Bash|bash|run_terminal_command|run_terminal_cmd|Shell|shell)$",
    re.IGNORECASE,
)

# Shell redirections / tee that write a file
SHELL_WRITE_RE = re.compile(
    r"(?:(?:^|[\s;|&])(?:tee|sponge)\s+(?:-[a-zA-Z]+\s+)*"
    r"(?P<tee_path>(?:['\"][^'\"]+['\"]|\S+))"
    r"|(?:>>?)\s*(?P<redir_path>(?:['\"][^'\"]+['\"]|\S+)))",
    re.IGNORECASE,
)

# Commands that always mutate the filesystem at an explicit path argument
SHELL_MUTATE_RE = re.compile(
    r"(?:^|[\s;|&])(?P<cmd>cp|mv|install|truncate|touch|mkdir|rmdir|chmod|chown)\b"
    r"(?P<args>[^;|&]*)",
    re.IGNORECASE,
)

# Skip path tokens that are flags or shell meta
SKIP_TOKENS = re.compile(r"^(-|\$|\||&|;|<|>)")


def _tool_name(envelope: dict) -> str:
    for key in ("toolName", "tool_name", "name"):
        val = envelope.get(key)
        if isinstance(val, str) and val.strip():
            return val.strip()
    return ""


def _tool_input(envelope: dict) -> dict:
    tool_input = envelope.get("toolInput") or envelope.get("tool_input") or {}
    if isinstance(tool_input, str):
        try:
            tool_input = json.loads(tool_input)
        except json.JSONDecodeError:
            return {}
    return tool_input if isinstance(tool_input, dict) else {}


def _cwd(envelope: dict) -> str:
    for key in ("cwd", "workingDirectory", "working_directory"):
        val = envelope.get(key)
        if isinstance(val, str) and val.strip():
            return os.path.abspath(os.path.expanduser(val.strip()))
    env_cwd = os.environ.get("DO_PATH_POLICY_CWD") or os.environ.get("PWD")
    if env_cwd:
        return os.path.abspath(os.path.expanduser(env_cwd))
    return os.path.abspath(os.getcwd())


def _strip_quotes(token: str) -> str:
    t = token.strip()
    if len(t) >= 2 and t[0] == t[-1] and t[0] in ("'", '"'):
        return t[1:-1]
    return t


def extract_write_path(tool_input: dict) -> str | None:
    for key in (
        "path",
        "filePath",
        "file_path",
        "target",
        "target_path",
        "targetPath",
        "filename",
        "file",
    ):
        val = tool_input.get(key)
        if isinstance(val, str) and val.strip():
            return val.strip()
    # apply_patch style optional
    for key in ("new_path", "newPath", "to"):
        val = tool_input.get(key)
        if isinstance(val, str) and val.strip():
            return val.strip()
    return None


def resolve_path(file_path: str, cwd: str) -> str:
    expanded = os.path.expanduser(file_path.strip())
    if os.path.isabs(expanded):
        return os.path.normpath(expanded)
    return os.path.normpath(os.path.join(cwd, expanded))


def is_under_root(resolved: str, root: str) -> bool:
    root_n = os.path.normpath(root)
    target = os.path.normpath(resolved)
    if target == root_n:
        return True
    prefix = root_n if root_n.endswith(os.sep) else root_n + os.sep
    return target.startswith(prefix)


def is_write_allowed(file_path: str, cwd: str) -> tuple[bool, str]:
    """Return (allowed, resolved_or_reason)."""
    if not file_path or not file_path.strip():
        return False, "empty path"
    # Disallow parent-escape attempts that normalize outside after resolve
    resolved = resolve_path(file_path, cwd)
    if is_under_root(resolved, cwd):
        return True, resolved
    return False, resolved


def shell_write_paths(command: str) -> list[str]:
    """Best-effort paths that shell is about to write."""
    if not command or not command.strip():
        return []
    found: list[str] = []
    for m in SHELL_WRITE_RE.finditer(command):
        raw = m.group("tee_path") or m.group("redir_path")
        if not raw:
            continue
        path = _strip_quotes(raw)
        # skip device / fd redirects
        if path.startswith("/dev/") or path in ("&1", "&2", "1", "2"):
            continue
        if SKIP_TOKENS.match(path):
            continue
        found.append(path)
    for m in SHELL_MUTATE_RE.finditer(command):
        args = m.group("args") or ""
        # Last non-flag arg is the destination for cp/mv/install etc.
        tokens = [t for t in re.split(r"\s+", args.strip()) if t]
        candidates = [
            _strip_quotes(t)
            for t in tokens
            if not t.startswith("-") and not SKIP_TOKENS.match(t)
        ]
        if candidates:
            found.append(candidates[-1])
    return found


def path_policy_deny(resolved: str, cwd: str) -> str:
    return format_guided_block(
        "path-policy-write-outside",
        f"Write outside the session workspace was blocked (target: {resolved}).",
        [
            f"Write only under the workspace root: {cwd}",
            "Use relative paths inside the active project, or open the intended project as cwd.",
            "If the path is intentional and outside the workspace, stop and ask the human to approve or re-open that directory.",
        ],
        human="Approve out-of-workspace writes yourself if they are truly required.",
        do_not="Retry the same absolute path outside the workspace or shell-bypass the path policy.",
    )


def decide(envelope: dict) -> tuple[str, int]:
    name = _tool_name(envelope)
    tool_input = _tool_input(envelope)
    cwd = _cwd(envelope)

    if WRITE_TOOL_RE.match(name):
        path = extract_write_path(tool_input)
        if not path:
            return json.dumps({"decision": "allow"}), 0
        ok, resolved = is_write_allowed(path, cwd)
        if ok:
            return json.dumps({"decision": "allow"}), 0
        reason = path_policy_deny(resolved, cwd)
        return json.dumps({"decision": "deny", "reason": reason}), 2

    if SHELL_TOOL_RE.match(name) or not name:
        command = ""
        for key in ("command", "cmd", "script", "input"):
            val = tool_input.get(key)
            if isinstance(val, str) and val.strip():
                command = val
                break
        if not command.strip():
            # No tool name and no command: allow (unknown surface)
            if not name:
                return json.dumps({"decision": "allow"}), 0
            return json.dumps({"decision": "allow"}), 0
        for path in shell_write_paths(command):
            ok, resolved = is_write_allowed(path, cwd)
            if not ok:
                reason = path_policy_deny(resolved, cwd)
                return json.dumps({"decision": "deny", "reason": reason}), 2
        return json.dumps({"decision": "allow"}), 0

    return json.dumps({"decision": "allow"}), 0


def self_test() -> int:
    failures: list[str] = []
    cwd = "/tmp/do-path-policy-workspace"
    Path(cwd).mkdir(parents=True, exist_ok=True)

    def expect_deny(envelope: dict, gate: str = "path-policy-write-outside") -> None:
        out, code = decide(envelope)
        payload = json.loads(out)
        if code != 2 or payload.get("decision") != "deny":
            failures.append(f"expected deny for {envelope!r}, got {out!r} code={code}")
            return
        reason = payload.get("reason", "")
        if not is_guided_shape(reason):
            failures.append(f"missing guided shape: {reason!r}")
        if gate not in reason:
            failures.append(f"expected gate {gate!r} in {reason!r}")
        if "Permission denied" in reason and "[GATE:" not in reason:
            failures.append(f"bare permission denied: {reason!r}")

    def expect_allow(envelope: dict) -> None:
        out, code = decide(envelope)
        payload = json.loads(out)
        if code != 0 or payload.get("decision") != "allow":
            failures.append(f"expected allow for {envelope!r}, got {out!r} code={code}")

    # Write tools outside workspace
    expect_deny(
        {
            "toolName": "write",
            "cwd": cwd,
            "toolInput": {"path": "/etc/passwd", "contents": "x"},
        }
    )
    expect_deny(
        {
            "toolName": "search_replace",
            "cwd": cwd,
            "toolInput": {"file_path": "/home/other/secret.txt", "old_string": "a", "new_string": "b"},
        }
    )
    expect_deny(
        {
            "toolName": "hashline_edit",
            "cwd": cwd,
            "toolInput": {"path": os.path.join(cwd, "..", "escape.txt")},
        }
    )

    # Write tools inside workspace
    expect_allow(
        {
            "toolName": "write",
            "cwd": cwd,
            "toolInput": {"path": "src/main.rs", "contents": "fn main() {}"},
        }
    )
    expect_allow(
        {
            "toolName": "Write",
            "cwd": cwd,
            "toolInput": {"filePath": os.path.join(cwd, "ok.txt"), "contents": "ok"},
        }
    )

    # Shell redirects outside / inside
    expect_deny(
        {
            "toolName": "run_terminal_cmd",
            "cwd": cwd,
            "toolInput": {"command": "echo secret > /tmp/outside-path-policy.dat"},
        }
    )
    expect_deny(
        {
            "toolName": "Bash",
            "cwd": cwd,
            "toolInput": {"command": "cp README.md /etc/do-path-policy-nope"},
        }
    )
    expect_allow(
        {
            "toolName": "Bash",
            "cwd": cwd,
            "toolInput": {"command": "echo ok > ./build/out.txt"},
        }
    )
    expect_allow(
        {
            "toolName": "run_terminal_cmd",
            "cwd": cwd,
            "toolInput": {"command": "git status"},
        }
    )

    # Read-only tools (no path policy)
    expect_allow(
        {
            "toolName": "read_file",
            "cwd": cwd,
            "toolInput": {"path": "/etc/passwd"},
        }
    )

    sample = format_guided_block(
        "path-policy-write-outside",
        "blocked",
        ["step"],
        do_not="retry",
    )
    if not is_guided_shape(sample):
        failures.append("format_guided_block failed shape check")

    if failures:
        for f in failures:
            print(f"FAIL: {f}", file=sys.stderr)
        print(f"{len(failures)} failure(s)", file=sys.stderr)
        return 1
    print("ok: guided-path-policy self-test passed")
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
        print(json.dumps({"decision": "allow"}))
        return 0
    out, code = decide(envelope)
    print(out)
    return code


if __name__ == "__main__":
    sys.exit(main())
