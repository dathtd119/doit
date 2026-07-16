#!/usr/bin/env python3
"""PreToolUse guard: deny shell patterns that dump secrets into the transcript.

F-M2-GATES / VAL-M2-GATE-001 — env-expose pack (beyond dangerous-shell).

Blocks shell commands that would dump .env secret files or the full process
environment into tool output. Prefers guided deny over silent mask (hooks can
only return reason text on deny; PostToolUse output rewrite is not productized).

Protocol (xai-grok-hooks command runner):
  - stdin: PreToolUse envelope JSON
  - allow:  {"decision":"allow"} + exit 0
  - deny:   {"decision":"deny","reason":"..."} + exit 2

Self-test:  guided-env-expose.py --self-test
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from guided_block import format_guided_block, is_guided_shape  # noqa: E402

SHELL_TOOL_RE = re.compile(
    r"^(Bash|bash|run_terminal_command|run_terminal_cmd|Shell|shell)?$",
    re.IGNORECASE,
)

# cat/head/tail/less/... of a real .env-style file (not .example / .sample / .template)
ENV_FILE_READ_RE = re.compile(
    r"(?:^|[\s;|&])(?:"
    r"cat|head|tail|less|more|bat|nl|tac|sed|awk|cut|grep|rg|source|\."
    r")\b[^;|&]*?"
    r"(?P<path>(?:~|\$HOME|[\w./-])*\.env(?:\.[A-Za-z0-9_-]+)?)"
    r"(?:\s|$|;|&|\|)",
    re.IGNORECASE,
)

SAFE_ENV_SUFFIX_RE = re.compile(
    r"\.(?:example|sample|template|dist|defaults?)(?:$|\b)",
    re.IGNORECASE,
)

# Full environment dumps (high secret leakage risk in transcripts).
# Statement-start only: `set` as `echo set` must not match (argument form).
_STMT = r"(?:^|[;|&]\s*)"  # start or after ; | & (not plain space mid-args)
ENV_DUMP_RE = re.compile(
    _STMT
    + r"(?:"
    r"printenv\s*(?:$|\||;|&)|"  # bare printenv (not printenv PATH)
    r"env\s*(?:$|\||;|&)|"  # bare env or env | ...
    r"export\s+-p\b|"
    r"set\s*(?:$|\||;|&)|"  # bare set / set | ...
    r"declare\s+-x\b"
    r")",
    re.IGNORECASE,
)

# Echo / printf of clearly sensitive variable names
SENSITIVE_ECHO_RE = re.compile(
    r"(?:^|[\s;|&])(?:echo|printf)\b[^;|&]*\$\{?(?:"
    r"(?:[A-Z0-9_]+_)?(?:API[_-]?KEY|SECRET|TOKEN|PASSWORD|PASSWD|PRIVATE[_-]?KEY|"
    r"ACCESS[_-]?KEY|AUTH[_-]?TOKEN|BEARER|CREDENTIALS?|OPENAI_API_KEY|"
    r"ANTHROPIC_API_KEY|AWS_SECRET_ACCESS_KEY|GITHUB_TOKEN|XAI_API_KEY)"
    r")\}?",
    re.IGNORECASE,
)


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


def extract_command(tool_input: dict) -> str:
    for key in ("command", "cmd", "script", "input"):
        val = tool_input.get(key)
        if isinstance(val, str) and val.strip():
            return val
    return ""


def is_safe_env_path(path: str) -> bool:
    base = path.rstrip("/").split("/")[-1]
    if SAFE_ENV_SUFFIX_RE.search(base):
        return True
    # .envrc is direnv; still often secrets — do not treat as safe
    return False


def match_env_gate(command: str) -> tuple[str, str, list[str], str | None, str] | None:
    """Return (gate, blocked, instead, human, do_not) or None."""
    if not command or not command.strip():
        return None

    # Prefer more specific env-file reads first
    for m in ENV_FILE_READ_RE.finditer(command):
        path = m.group("path")
        if is_safe_env_path(path):
            continue
        return (
            "env-expose-dotenv",
            f"Reading secret env file via shell was blocked (path pattern: {path}).",
            [
                "Do not dump `.env` / secret env files into the tool transcript.",
                "Reference variable *names* only; load values at runtime from the environment (`$VAR`) without printing them.",
                "If you need non-secret keys from a template, use `.env.example` / `.env.sample` / `.env.template`.",
                "If a secret must be used, keep it out of stdout — prefer app config that reads the env privately.",
            ],
            "Ask the human to set or rotate secrets outside the agent transcript.",
            "cat/head/tail/. the real `.env` file or paste secret values into chat.",
        )

    if ENV_DUMP_RE.search(command):
        return (
            "env-expose-printenv",
            "Dumping the full process environment was blocked (secret leakage risk).",
            [
                "Inspect only a specific non-secret variable when needed (`printenv PATH`).",
                "Never print the full environment or `export -p` into the transcript.",
                "Prefer documenting required *names* of env vars rather than their values.",
            ],
            "If debugging auth failures, ask the human to verify secrets locally without pasting values.",
            "Retry bare `env` / `printenv` / `export -p` / full `set` dumps.",
        )

    if SENSITIVE_ECHO_RE.search(command):
        return (
            "env-expose-secret-echo",
            "Echoing a sensitive environment variable into the transcript was blocked.",
            [
                "Use the variable in-process without printing it (app code reads `os.environ` / `$VAR` privately).",
                "Confirm presence with length/existence checks that do not print the value (`test -n \"$VAR\" && echo set`).",
                "If the value is wrong, ask the human to fix it outside the agent session.",
            ],
            "Human must provide or rotate secrets; do not extract them via the agent.",
            "Retry `echo $…SECRET…` / token / password variables.",
        )

    return None


def decide(envelope: dict) -> tuple[str, int]:
    name = _tool_name(envelope)
    # Match shell tools; also accept empty name when only command is present (fixture style)
    if name and not SHELL_TOOL_RE.match(name):
        return json.dumps({"decision": "allow"}), 0

    tool_input = _tool_input(envelope)
    command = extract_command(tool_input)
    hit = match_env_gate(command)
    if hit is None:
        return json.dumps({"decision": "allow"}), 0
    gate, blocked, instead, human, do_not = hit
    reason = format_guided_block(gate, blocked, instead, human=human, do_not=do_not)
    return json.dumps({"decision": "deny", "reason": reason}), 2


def self_test() -> int:
    failures: list[str] = []

    def expect_deny(cmd: str, gate: str) -> None:
        out, code = decide({"toolName": "Bash", "toolInput": {"command": cmd}})
        payload = json.loads(out)
        if code != 2 or payload.get("decision") != "deny":
            failures.append(f"expected deny for {cmd!r}, got {out!r} code={code}")
            return
        reason = payload.get("reason", "")
        if not is_guided_shape(reason):
            failures.append(f"missing guided shape for {cmd!r}")
        if gate not in reason:
            failures.append(f"expected gate {gate!r} in reason for {cmd!r}")
        if reason.strip() == "Permission denied" or reason.strip().lower() == "permission denied":
            failures.append(f"bare permission denied for {cmd!r}")

    def expect_allow(cmd: str) -> None:
        out, code = decide({"toolName": "run_terminal_cmd", "toolInput": {"command": cmd}})
        payload = json.loads(out)
        if code != 0 or payload.get("decision") != "allow":
            failures.append(f"expected allow for {cmd!r}, got {out!r} code={code}")

    expect_deny("cat .env", "env-expose-dotenv")
    expect_deny("cat ./prod/.env.local", "env-expose-dotenv")
    expect_deny("head -n 20 ~/.env", "env-expose-dotenv")
    expect_deny("printenv", "env-expose-printenv")
    expect_deny("env | sort", "env-expose-printenv")
    expect_deny("export -p", "env-expose-printenv")
    expect_deny("echo $OPENAI_API_KEY", "env-expose-secret-echo")
    expect_deny("printf '%s\\n' $GITHUB_TOKEN", "env-expose-secret-echo")

    expect_allow("cat .env.example")
    expect_allow("cat config/env.sample")
    expect_allow("printenv PATH")
    expect_allow("printenv HOME")
    expect_allow("git status")
    expect_allow("cargo check -p xai-grok-pager-bin")
    expect_allow("echo $HOME")
    expect_allow("test -n \"$OPENAI_API_KEY\" && echo set")

    # Non-shell tools always allow
    out, code = decide({"toolName": "read_file", "toolInput": {"path": ".env"}})
    if code != 0 or json.loads(out).get("decision") != "allow":
        failures.append("non-shell tool should allow (this gate is shell-scoped)")

    if failures:
        for f in failures:
            print(f"FAIL: {f}", file=sys.stderr)
        print(f"{len(failures)} failure(s)", file=sys.stderr)
        return 1
    print("ok: guided-env-expose self-test passed")
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
