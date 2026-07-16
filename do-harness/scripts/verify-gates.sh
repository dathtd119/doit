#!/usr/bin/env bash
# F-M2-GATES / VAL-M2-GATE-001: guided-block product standard + expanded pack.
#
# Checks:
#   1. Product standard docs (gates.md + README enablement)
#   2. M0 dangerous-shell still passes self-test + guided shape
#   3. ≥2 additional guided denial packs exist (path-policy + env-expose)
#   4. Self-tests for new packs
#   5. Gate ids named in L0 + all five role prompts
#   6. No bare "Permission denied" in do-owned guided deny reasons
#   7. Optional project .doit/hooks install or enablement docs
#
# Exit 0 only when all checks pass.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$HARNESS_DIR/.." && pwd)"
REPO_ROOT="${DO_REPO_ROOT:-$REPO_ROOT}"

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
section "1. Product standard documentation"
# ---------------------------------------------------------------------------

GATES_MD="$HARNESS_DIR/prompts/gates.md"
if [[ -f "$GATES_MD" ]]; then
  ok "do-harness/prompts/gates.md exists"
else
  fail "missing $GATES_MD"
fi

if [[ -f "$GATES_MD" ]]; then
  for needle in \
    "[GATE:" \
    "Do this instead" \
    "path-policy-write-outside" \
    "env-expose-dotenv" \
    "env-expose-printenv" \
    "dangerous-shell"
  do
    if grep -qF "$needle" "$GATES_MD"; then
      ok "gates.md mentions: $needle"
    else
      fail "gates.md missing: $needle"
    fi
  done
fi

README="$HARNESS_DIR/README.md"
if [[ -f "$README" ]] && grep -qE 'path-policy|env-expose|VAL-M2-GATE|F-M2-GATES|verify-gates' "$README"; then
  ok "do-harness/README.md documents guided gates pack / verify"
else
  fail "do-harness/README.md should document F-M2-GATES / verify-gates"
fi

HOOKS_README="$HARNESS_DIR/hooks/README.md"
if [[ -f "$HOOKS_README" ]] && grep -q 'path-policy' "$HOOKS_README" && grep -q 'env-expose' "$HOOKS_README"; then
  ok "hooks/README.md documents path-policy + env-expose"
else
  fail "hooks/README.md should document path-policy and env-expose enablement"
fi

L0="$HARNESS_DIR/prompts/l0-kernel.md"
if [[ -f "$L0" ]] && grep -qE 'path-policy|env-expose' "$L0"; then
  ok "L0 kernel names expanded gate families"
else
  fail "prompts/l0-kernel.md should name path-policy / env-expose gates"
fi

# ---------------------------------------------------------------------------
section "2. Dangerous-shell (M0) still green"
# ---------------------------------------------------------------------------

SHELL_PY="$HARNESS_DIR/hooks/bin/guided-dangerous-shell.py"
if [[ -f "$SHELL_PY" ]]; then
  chmod +x "$SHELL_PY" 2>/dev/null || true
  if python3 "$SHELL_PY" --self-test; then
    ok "guided-dangerous-shell.py --self-test"
  else
    fail "guided-dangerous-shell.py --self-test failed"
  fi
else
  fail "missing $SHELL_PY"
fi

# ---------------------------------------------------------------------------
section "3. Additional guided packs (≥2)"
# ---------------------------------------------------------------------------

PATH_JSON="$HARNESS_DIR/hooks/guided-path-policy.json"
PATH_PY="$HARNESS_DIR/hooks/bin/guided-path-policy.py"
ENV_JSON="$HARNESS_DIR/hooks/guided-env-expose.json"
ENV_PY="$HARNESS_DIR/hooks/bin/guided-env-expose.py"
SHARED="$HARNESS_DIR/hooks/bin/guided_block.py"

if [[ -f "$SHARED" ]]; then
  ok "shared guided_block.py exists"
else
  fail "missing shared guided_block helper: $SHARED"
fi

for f in "$PATH_JSON" "$PATH_PY" "$ENV_JSON" "$ENV_PY"; do
  if [[ -f "$f" ]]; then
    ok "exists: ${f#$HARNESS_DIR/}"
  else
    fail "missing $f"
  fi
done

if [[ -f "$PATH_JSON" ]]; then
  if grep -q 'PreToolUse' "$PATH_JSON" && grep -q 'guided-path-policy.py' "$PATH_JSON"; then
    ok "path-policy JSON is PreToolUse → guided-path-policy.py"
  else
    fail "path-policy JSON must wire PreToolUse to guided-path-policy.py"
  fi
fi

if [[ -f "$ENV_JSON" ]]; then
  if grep -q 'PreToolUse' "$ENV_JSON" && grep -q 'guided-env-expose.py' "$ENV_JSON"; then
    ok "env-expose JSON is PreToolUse → guided-env-expose.py"
  else
    fail "env-expose JSON must wire PreToolUse to guided-env-expose.py"
  fi
fi

# ---------------------------------------------------------------------------
section "4. Self-tests for new packs"
# ---------------------------------------------------------------------------

# PYTHONPATH so scripts can import guided_block from same dir
export PYTHONPATH="$HARNESS_DIR/hooks/bin${PYTHONPATH:+:$PYTHONPATH}"

if [[ -f "$PATH_PY" ]]; then
  chmod +x "$PATH_PY" 2>/dev/null || true
  if python3 "$PATH_PY" --self-test; then
    ok "guided-path-policy.py --self-test"
  else
    fail "guided-path-policy.py --self-test failed"
  fi
fi

if [[ -f "$ENV_PY" ]]; then
  chmod +x "$ENV_PY" 2>/dev/null || true
  if python3 "$ENV_PY" --self-test; then
    ok "guided-env-expose.py --self-test"
  else
    fail "guided-env-expose.py --self-test failed"
  fi
fi

# Live stdin deny must not be bare Permission denied
STDIN_OUT="$(
  printf '%s' '{"toolName":"write","cwd":"/tmp","toolInput":{"path":"/etc/do-gate-verify","contents":"x"}}' \
    | python3 "$PATH_PY" 2>/dev/null || true
)"
STDIN_CODE=0
printf '%s' '{"toolName":"write","cwd":"/tmp","toolInput":{"path":"/etc/do-gate-verify","contents":"x"}}' \
  | python3 "$PATH_PY" >/tmp/do-gate-path-out.json 2>/dev/null || STDIN_CODE=$?
if [[ "$STDIN_CODE" -eq 2 ]] && grep -q '\[GATE: path-policy-write-outside\]' /tmp/do-gate-path-out.json \
  && grep -q 'Do this instead' /tmp/do-gate-path-out.json; then
  ok "path-policy stdin deny is guided (exit 2 + GATE + Do this instead)"
else
  fail "path-policy stdin deny shape bad (code=$STDIN_CODE out=$(cat /tmp/do-gate-path-out.json 2>/dev/null || true))"
fi

ENV_CODE=0
printf '%s' '{"toolName":"Bash","toolInput":{"command":"cat .env"}}' \
  | python3 "$ENV_PY" >/tmp/do-gate-env-out.json 2>/dev/null || ENV_CODE=$?
if [[ "$ENV_CODE" -eq 2 ]] && grep -q '\[GATE: env-expose-dotenv\]' /tmp/do-gate-env-out.json \
  && grep -q 'Do this instead' /tmp/do-gate-env-out.json; then
  ok "env-expose stdin deny is guided (exit 2 + GATE + Do this instead)"
else
  fail "env-expose stdin deny shape bad (code=$ENV_CODE out=$(cat /tmp/do-gate-env-out.json 2>/dev/null || true))"
fi

# Reject bare Permission denied as the whole reason
for f in /tmp/do-gate-path-out.json /tmp/do-gate-env-out.json; do
  if [[ -f "$f" ]] && python3 -c '
import json,sys
p=json.load(open(sys.argv[1]))
r=(p.get("reason") or "").strip()
sys.exit(0 if r and r.lower() != "permission denied" and "[GATE:" in r else 1)
' "$f"; then
    ok "deny reason not bare Permission denied ($(basename "$f"))"
  else
    fail "bare or missing GATE in $f"
  fi
done

# ---------------------------------------------------------------------------
section "5. Gate names in role prompts"
# ---------------------------------------------------------------------------

ROLE_DIR="$HARNESS_DIR/prompts/roles"
for role in intake orchestrator explorer worker oracle; do
  f="$ROLE_DIR/${role}.md"
  if [[ ! -f "$f" ]]; then
    fail "missing role prompt $f"
    continue
  fi
  missing=0
  for family in "dangerous-shell" "path-policy" "env-expose"; do
    if ! grep -qF "$family" "$f"; then
      fail "role $role missing gate family mention: $family"
      missing=1
    fi
  done
  if [[ "$missing" -eq 0 ]]; then
    ok "role $role names dangerous-shell + path-policy + env-expose"
  fi
  if grep -q 'Do this instead' "$f" || grep -q '\[GATE:' "$f"; then
    ok "role $role references guided shape / GATE"
  else
    fail "role $role should mention [GATE: …] or Do this instead"
  fi
done

# ---------------------------------------------------------------------------
section "6. Project discovery install (optional but preferred)"
# ---------------------------------------------------------------------------

need_doc=0
for name in guided-path-policy guided-env-expose; do
  pj="$REPO_ROOT/.doit/hooks/${name}.json"
  pb="$REPO_ROOT/.doit/hooks/bin/${name}.py"
  if [[ -e "$pj" ]]; then
    ok "project .doit/hooks/${name}.json installed"
    if [[ -e "$pb" || -L "$pb" ]]; then
      ok "project .doit/hooks/bin/${name}.py installed"
    else
      fail "project hook JSON for $name present but bin missing"
    fi
  else
    need_doc=1
  fi
done

if [[ "$need_doc" -eq 1 ]]; then
  if grep -q 'guided-path-policy' "$README" && grep -q 'guided-env-expose' "$README"; then
    ok "install not fully present; enablement documented in do-harness/README.md"
  else
    fail "install missing and README lacks enablement for both new hooks"
  fi
fi

# Shared helper on discovery bin path when project install exists
if [[ -e "$REPO_ROOT/.doit/hooks/bin/guided-path-policy.py" ]]; then
  if [[ -e "$REPO_ROOT/.doit/hooks/bin/guided_block.py" || -L "$REPO_ROOT/.doit/hooks/bin/guided_block.py" ]]; then
    ok "project .doit/hooks/bin/guided_block.py available for imports"
  else
    fail "project install missing guided_block.py next to gate scripts"
  fi
fi

# ---------------------------------------------------------------------------
printf '\n'
if [[ "$FAIL" -eq 0 ]]; then
  printf 'VAL-M2-GATE-001: PASS (%s checks)\n' "$PASS"
  exit 0
fi
printf 'VAL-M2-GATE-001: FAIL (%s passed, %s failed)\n' "$PASS" "$FAIL" >&2
exit 1
