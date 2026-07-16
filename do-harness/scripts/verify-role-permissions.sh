#!/usr/bin/env bash
# F-M2-PERM / VAL-M2-PERM-001: role tool allow/deny floors on five roster agents.
#
# Checks:
#   1. Policy docs (docs/role-permissions.md + config.permissions.yaml)
#   2. All five agents: permissionMode + tools + disallowedTools frontmatter
#   3. Applied floors match config.permissions.yaml (allow + deny sets)
#   4. Deny-family invariants (edit surface / continuum for non-implementers)
#   5. Guided-gate family alignment in agent bodies + L1 role prompts
#   6. README enablement / verify pointer
#
# Exit 0 only when all checks pass.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$HARNESS_DIR/.." && pwd)"
REPO_ROOT="${DO_REPO_ROOT:-$REPO_ROOT}"

ROLES=(intake orchestrator explorer worker oracle)

PASS=0
FAIL=0

ok() {
  PASS=$((PASS + 1))
  printf '  ok  %s\n' "$1"
}

fail() {
  FAIL=$((FAIL + 1))
  printf '  FAIL %s\n' "$1" >&2
}

section() {
  printf '\n== %s ==\n' "$1"
}

# ---------------------------------------------------------------------------
section "1. Policy documentation"
# ---------------------------------------------------------------------------

POLICY="$REPO_ROOT/docs/role-permissions.md"
if [[ -f "$POLICY" ]]; then
  ok "docs/role-permissions.md exists"
else
  fail "missing $POLICY"
fi

if [[ -f "$POLICY" ]]; then
  for needle in \
    "VAL-M2-PERM-001" \
    "F-M2-PERM" \
    "tools" \
    "disallowedTools" \
    "permissionMode" \
    "dangerous-shell" \
    "path-policy" \
    "env-expose" \
    "intake" \
    "orchestrator" \
    "explorer" \
    "worker" \
    "oracle"
  do
    if grep -qF "$needle" "$POLICY"; then
      ok "policy mentions: $needle"
    else
      fail "policy missing mention: $needle"
    fi
  done
fi

CFG="$HARNESS_DIR/config.permissions.yaml"
if [[ -f "$CFG" ]]; then
  ok "do-harness/config.permissions.yaml exists"
else
  fail "missing $CFG"
fi

README="$HARNESS_DIR/README.md"
if [[ -f "$README" ]] && grep -qE 'role-permission|F-M2-PERM|VAL-M2-PERM|verify-role-permissions' "$README"; then
  ok "do-harness/README.md documents role floors / verify"
else
  fail "do-harness/README.md should document F-M2-PERM / verify-role-permissions"
fi

PROMPT_SYS="$REPO_ROOT/docs/prompt-system.md"
if [[ -f "$PROMPT_SYS" ]] && grep -qE 'role-permissions|F-M2-PERM|VAL-M2-PERM' "$PROMPT_SYS"; then
  ok "docs/prompt-system.md links role permission floors"
else
  fail "docs/prompt-system.md should point at role-permissions / F-M2-PERM"
fi

# ---------------------------------------------------------------------------
section "2–5. Agent floors match config + deny families + gate naming"
# ---------------------------------------------------------------------------

python3 - "$HARNESS_DIR" "$REPO_ROOT" "${ROLES[@]}" <<'PY'
from __future__ import annotations

import re
import sys
from pathlib import Path

try:
    import yaml  # type: ignore
except ImportError:
    yaml = None

harness = Path(sys.argv[1])
repo = Path(sys.argv[2])
roles = sys.argv[3:]
cfg_path = harness / "config.permissions.yaml"
agents_dir = harness / "agents"
roles_dir = harness / "prompts" / "roles"
failed: list[str] = []
passed: list[str] = []


def ok(msg: str) -> None:
    passed.append(msg)
    print(f"  ok  {msg}")


def fail(msg: str) -> None:
    failed.append(msg)
    print(f"  FAIL {msg}", file=sys.stderr)


def parse_frontmatter(text: str) -> tuple[dict, str]:
    if not text.lstrip().startswith("---"):
        raise ValueError("missing YAML frontmatter")
    parts = re.split(r"^---\s*$", text, maxsplit=2, flags=re.M)
    if len(parts) < 3:
        raise ValueError("frontmatter not closed")
    if yaml is None:
        raise ValueError("PyYAML required to parse agent frontmatter")
    data = yaml.safe_load(parts[1])
    if not isinstance(data, dict):
        raise ValueError("frontmatter root must be a mapping")
    return data, parts[2]


def as_str_list(value) -> list[str] | None:
    if value is None:
        return None
    if not isinstance(value, list):
        raise ValueError(f"expected list, got {type(value).__name__}")
    return [str(x) for x in value]


def load_cfg() -> dict:
    text = cfg_path.read_text(encoding="utf-8")
    if yaml is not None:
        data = yaml.safe_load(text)
        if not isinstance(data, dict):
            raise ValueError("config.permissions.yaml root must be a mapping")
        return data
    raise SystemExit(
        "  FAIL PyYAML required to parse config.permissions.yaml "
        "(install pyyaml or use system python with yaml)"
    )


if not cfg_path.is_file():
    fail(f"missing {cfg_path}")
    print(f"python_failed={len(failed)}", file=sys.stderr)
    sys.exit(1)

try:
    cfg = load_cfg()
except Exception as exc:  # noqa: BLE001
    fail(f"config load error: {exc}")
    print(f"python_failed={len(failed)}", file=sys.stderr)
    sys.exit(1)

cfg_roles = cfg.get("roles") or {}
edit_surface = list(cfg.get("edit_surface_tools") or [])
continuum = list(cfg.get("continuum_tools") or [])
gate_families = list(cfg.get("guided_gate_families") or [])

for role in roles:
    if role not in cfg_roles:
        fail(f"config.permissions.yaml missing roles.{role}")
        continue
    expected = cfg_roles[role]
    agent_path = agents_dir / f"{role}.md"
    if not agent_path.is_file():
        fail(f"missing agent {agent_path}")
        continue
    text = agent_path.read_text(encoding="utf-8")
    try:
        fm, body = parse_frontmatter(text)
    except ValueError as exc:
        fail(f"{role}: {exc}")
        continue

    mode = fm.get("permissionMode")
    if mode is not None:
        mode = str(mode).strip()
    try:
        tools = as_str_list(fm.get("tools"))
        denied = as_str_list(fm.get("disallowedTools"))
    except ValueError as exc:
        fail(f"{role}: {exc}")
        continue

    exp_mode = str(expected.get("permissionMode", "")).strip()
    exp_tools = [str(x) for x in (expected.get("tools") or [])]
    exp_denied = [str(x) for x in (expected.get("disallowedTools") or [])]

    if mode != exp_mode:
        fail(f"{role}: permissionMode want={exp_mode!r} got={mode!r}")
    else:
        ok(f"{role}: permissionMode={mode}")

    if tools is None:
        fail(f"{role}: tools allowlist missing (floors must be explicit)")
    elif set(tools) != set(exp_tools):
        fail(
            f"{role}: tools mismatch "
            f"missing={sorted(set(exp_tools) - set(tools))} "
            f"extra={sorted(set(tools) - set(exp_tools))}"
        )
    else:
        ok(f"{role}: tools allowlist matches config")

    if denied is None:
        fail(f"{role}: disallowedTools missing (deny floors must be explicit)")
    elif set(denied) != set(exp_denied):
        fail(
            f"{role}: disallowedTools mismatch "
            f"missing={sorted(set(exp_denied) - set(denied))} "
            f"extra={sorted(set(denied) - set(exp_denied))}"
        )
    else:
        ok(f"{role}: disallowedTools matches config")

    # Deny families
    denied_set = set(denied or [])
    families = list(expected.get("require_deny_families") or [])
    for fam in families:
        needed = edit_surface if fam == "edit_surface" else continuum if fam == "continuum" else []
        missing = [t for t in needed if t not in denied_set]
        if missing:
            fail(f"{role}: require_deny_families.{fam} missing {missing}")
        else:
            ok(f"{role}: deny family {fam} present")

    # Gate family naming in agent body + L1 fragment
    if expected.get("must_name_gate_families", True):
        role_prompt = roles_dir / f"{role}.md"
        surfaces = [("agent", body)]
        if role_prompt.is_file():
            surfaces.append(("role prompt", role_prompt.read_text(encoding="utf-8")))
        else:
            fail(f"{role}: missing L1 role prompt {role_prompt}")
        for label, content in surfaces:
            for fam in gate_families:
                if fam not in content:
                    fail(f"{role} {label}: must name gate family {fam!r}")
                else:
                    ok(f"{role} {label}: names {fam}")
            if "Do this instead" not in content and "[GATE:" not in content:
                # At least one of guided-block markers / GATE mention
                if "GATE" not in content and "gate" not in content.lower():
                    fail(f"{role} {label}: should mention guided GATE denials")

if failed:
    print(f"\npython_passed={len(passed)} python_failed={len(failed)}", file=sys.stderr)
    sys.exit(1)
print(f"\npython_passed={len(passed)} python_failed=0")
sys.exit(0)
PY
ok "agent floors / deny families / gate naming checks passed"

# ---------------------------------------------------------------------------
section "6. Fork schema evidence (tools + disallowedTools)"
# ---------------------------------------------------------------------------

AGENT_README="$REPO_ROOT/crates/codegen/xai-grok-agent/README.md"
if [[ -f "$AGENT_README" ]] && grep -q 'disallowedTools' "$AGENT_README" && grep -qE '`tools`' "$AGENT_README"; then
  ok "evidence: agent frontmatter schema documents tools / disallowedTools"
else
  fail "cannot find tools/disallowedTools schema in xai-grok-agent README"
fi

# ---------------------------------------------------------------------------
section "Summary"
# ---------------------------------------------------------------------------

printf '\npassed=%s failed=%s\n' "$PASS" "$FAIL"
printf 'repo_root=%s\n' "$REPO_ROOT"
printf 'roles=%s\n' "${ROLES[*]}"

if [[ "$FAIL" -gt 0 ]]; then
  printf '\nVAL-M2-PERM-001: FAIL\n' >&2
  exit 1
fi

printf '\nVAL-M2-PERM-001: PASS (role tool floors documented + applied)\n'
exit 0
