#!/usr/bin/env python3
"""PreToolUse guard: shell-only denylist for writes to protected system paths.

F-M2-GATES / VAL-M2-GATE-001 — path-policy pack (beyond dangerous-shell).

Policy stance (product):
  - Write/edit tools (write, edit, apply_patch, hashline_*, …) are **not** gated
    here. Stock permission UX (ask / auto-accept / yolo) owns those.
  - Shell tools only: block redirects / mutate destinations that hit a small
    denylist of system roots and home secret trees.
  - Allow-by-default for everything else (workspace, home, /tmp, ~/.config/doit).

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

# Exact paths that must never be shell-written.
DENIED_EXACT_PATHS = frozenset(
    {
        "/",
        "/etc",
        "/usr",
        "/bin",
        "/sbin",
        "/lib",
        "/lib64",
        "/boot",
        "/dev",
        "/proc",
        "/sys",
        "/root",
        "/var/run",
        "/run",
    }
)

# Prefix roots: any path under these is denied for shell writes.
DENIED_PREFIX_ROOTS = (
    "/etc/",
    "/usr/",
    "/bin/",
    "/sbin/",
    "/lib/",
    "/lib64/",
    "/boot/",
    "/dev/",
    "/proc/",
    "/sys/",
    "/root/",
)

# Credential / secret trees under home that stay off-limits via shell.
HOME_SECRET_NAMES = frozenset(
    {
        ".ssh",
        ".gnupg",
        ".aws",
        ".azure",
        ".kube",
        ".netrc",
        ".git-credentials",
    }
)
HOME_SECRET_PATH_SUFFIXES = (
    "/.docker/config.json",
)


def _product_config_home() -> str:
    grok_home = os.environ.get("GROK_HOME")
    if grok_home and grok_home.strip():
        return os.path.abspath(os.path.expanduser(grok_home.strip()))
    return os.path.abspath(os.path.expanduser("~/.config/doit"))


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


def is_denied_path(resolved: str) -> bool:
    """True only for hard-denied system / secret paths (shell targets)."""
    target = os.path.normpath(resolved)
    if target in DENIED_EXACT_PATHS:
        return True
    for prefix in DENIED_PREFIX_ROOTS:
        if target == prefix.rstrip("/") or target.startswith(prefix):
            return True
    home = os.path.normpath(os.path.expanduser("~"))
    if is_under_root(target, home):
        for suf in HOME_SECRET_PATH_SUFFIXES:
            if target == home + suf or target.endswith(suf):
                return True
        parts = target.split(os.sep)
        for name in HOME_SECRET_NAMES:
            if name in parts:
                return True
    return False


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
        # skip device / fd redirects (device writes handled by dangerous-shell)
        if path.startswith("/dev/") or path in ("&1", "&2", "1", "2"):
            continue
        if SKIP_TOKENS.match(path):
            continue
        found.append(path)
    for m in SHELL_MUTATE_RE.finditer(command):
        args = m.group("args") or ""
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
        f"Shell write to a protected system path was blocked (target: {resolved}).",
        [
            "Use dedicated write/edit tools for normal files (stock ask/auto permissions apply).",
            "For shell: write under workspace, home project paths, /tmp, or ~/.config/doit — not system roots or secret trees.",
            f"Session cwd for context: {cwd}",
            "If a protected path is truly required, stop and ask the human to run the shell change.",
        ],
        human="Approve and run protected-path shell writes yourself if they are truly required.",
        do_not="Retry the same shell write into system/secret paths or bypass this denylist.",
    )


def decide(envelope: dict) -> tuple[str, int]:
    name = _tool_name(envelope)
    tool_input = _tool_input(envelope)
    cwd = _cwd(envelope)

    # Write/edit tools: never hard-deny here — stock permission UX owns them.
    if not SHELL_TOOL_RE.match(name):
        # Unknown / empty name with a command may still be shell-shaped
        if name and not SHELL_TOOL_RE.match(name):
            return json.dumps({"decision": "allow"}), 0

    # Shell tools (or empty name + command)
    command = ""
    for key in ("command", "cmd", "script", "input"):
        val = tool_input.get(key)
        if isinstance(val, str) and val.strip():
            command = val
            break

    if not SHELL_TOOL_RE.match(name):
        # No recognized shell tool name: only inspect if a command is present
        if not name and command.strip():
            pass  # fall through
        else:
            return json.dumps({"decision": "allow"}), 0

    if not command.strip():
        return json.dumps({"decision": "allow"}), 0

    for path in shell_write_paths(command):
        resolved = resolve_path(path, cwd)
        if is_denied_path(resolved):
            reason = path_policy_deny(resolved, cwd)
            return json.dumps({"decision": "deny", "reason": reason}), 2
    return json.dumps({"decision": "allow"}), 0


def self_test() -> int:
    failures: list[str] = []
    cwd = os.path.join(os.path.expanduser("~"), "code", "doit")
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

    # Write/edit tools: always allow through path-policy (even /etc)
    expect_allow(
        {
            "toolName": "write",
            "cwd": cwd,
            "toolInput": {"path": "/etc/passwd", "contents": "x"},
        }
    )
    expect_allow(
        {
            "toolName": "search_replace",
            "cwd": cwd,
            "toolInput": {
                "file_path": os.path.expanduser("~/.ssh/authorized_keys"),
                "old_string": "a",
                "new_string": "b",
            },
        }
    )
    expect_allow(
        {
            "toolName": "hashline_edit",
            "cwd": cwd,
            "toolInput": {"path": "/usr/local/bin/evil"},
        }
    )
    expect_allow(
        {
            "toolName": "write",
            "cwd": cwd,
            "toolInput": {
                "path": os.path.join(
                    _product_config_home(),
                    "sessions",
                    "x",
                    "plan.md",
                ),
                "contents": "# plan",
            },
        }
    )

    # Shell: deny protected destinations
    expect_deny(
        {
            "toolName": "Bash",
            "cwd": cwd,
            "toolInput": {"command": "cp README.md /etc/do-path-policy-nope"},
        }
    )
    expect_deny(
        {
            "toolName": "run_terminal_cmd",
            "cwd": cwd,
            "toolInput": {"command": "echo secret > /etc/outside-path-policy.dat"},
        }
    )
    expect_deny(
        {
            "toolName": "run_terminal_command",
            "cwd": cwd,
            "toolInput": {
                "command": f"echo x > {os.path.expanduser('~/.ssh/authorized_keys')}",
            },
        }
    )

    # Shell: allow normal destinations
    expect_allow(
        {
            "toolName": "run_terminal_cmd",
            "cwd": cwd,
            "toolInput": {"command": "echo secret > /tmp/outside-path-policy.dat"},
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
    product_home = _product_config_home()
    expect_allow(
        {
            "toolName": "Bash",
            "cwd": cwd,
            "toolInput": {
                "command": f"echo ok > {product_home}/shell-allow.txt",
            },
        }
    )
    expect_allow(
        {
            "toolName": "run_terminal_cmd",
            "cwd": cwd,
            "toolInput": {
                "command": f"echo ok > {os.path.expanduser('~/.serena.bak-removed-test')}",
            },
        }
    )

    # Read-only tools
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
