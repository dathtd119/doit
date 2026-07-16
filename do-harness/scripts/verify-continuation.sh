#!/usr/bin/env bash
# F-M2-CONT / VAL-M2-CONT-001: continuation priority policy + native hooks +
# no-thrash multi-step fixture.
#
# Checks:
#   1. Policy doc docs/continuation.md with lane order + tool map
#   2. Hook JSON + engine exist under do-harness/hooks/
#   3. Engine self-test (priority + cooldown)
#   4. Multi-step thrash fixture (scripted envelopes)
#   5. Optional project .do/hooks install path present or documented enablement
#   6. workspace.md points at continuation policy
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
section "1. Policy documentation"
# ---------------------------------------------------------------------------

POLICY="$REPO_ROOT/docs/continuation.md"
if [[ -f "$POLICY" ]]; then
  ok "docs/continuation.md exists"
else
  fail "missing $POLICY"
fi

if [[ -f "$POLICY" ]]; then
  for needle in \
    "interrupt → streak → goal → plan → workflow → todo" \
    "update_goal" \
    "todo_write" \
    "enter_plan_mode" \
    "Anti-thrash" \
    "VAL-M2-CONT-001" \
    "Continue lane:"
  do
    if grep -qF "$needle" "$POLICY"; then
      ok "policy mentions: $needle"
    else
      fail "policy missing mention: $needle"
    fi
  done
fi

WORKSPACE="$REPO_ROOT/docs/workspace.md"
if [[ -f "$WORKSPACE" ]] && grep -qE 'continuation\.md|Continuation priority' "$WORKSPACE"; then
  ok "docs/workspace.md links continuation policy"
else
  fail "docs/workspace.md should point at docs/continuation.md"
fi

INDEX="$REPO_ROOT/docs/index.md"
if [[ -f "$INDEX" ]] && grep -qE 'continuation\.md|Continuation' "$INDEX"; then
  ok "docs/index.md lists continuation"
else
  fail "docs/index.md should list continuation.md"
fi

# ---------------------------------------------------------------------------
section "2. Hook source files"
# ---------------------------------------------------------------------------

HOOK_JSON="$HARNESS_DIR/hooks/continuation-nudge.json"
HOOK_PY="$HARNESS_DIR/hooks/bin/continuation-nudge.py"

if [[ -f "$HOOK_JSON" ]]; then
  ok "hooks/continuation-nudge.json exists"
else
  fail "missing $HOOK_JSON"
fi

if [[ -f "$HOOK_PY" ]]; then
  ok "hooks/bin/continuation-nudge.py exists"
else
  fail "missing $HOOK_PY"
fi

if [[ -f "$HOOK_JSON" ]]; then
  if grep -q 'PostToolUse' "$HOOK_JSON" && grep -q 'continuation-nudge.py' "$HOOK_JSON"; then
    ok "hook JSON is PostToolUse → continuation-nudge.py"
  else
    fail "hook JSON must wire PostToolUse to continuation-nudge.py"
  fi
  if grep -qE 'update_goal|todo_write|enter_plan_mode' "$HOOK_JSON"; then
    ok "hook matcher includes continuum tools"
  else
    fail "hook matcher missing continuum tools"
  fi
fi

if [[ -f "$HOOK_PY" && ! -x "$HOOK_PY" ]]; then
  chmod +x "$HOOK_PY" || true
fi

# ---------------------------------------------------------------------------
section "3. Engine self-test"
# ---------------------------------------------------------------------------

if [[ -f "$HOOK_PY" ]]; then
  if python3 "$HOOK_PY" --self-test; then
    ok "continuation-nudge.py --self-test"
  else
    fail "continuation-nudge.py --self-test failed"
  fi
fi

# ---------------------------------------------------------------------------
section "4. Multi-step thrash fixture"
# ---------------------------------------------------------------------------

FIXTURE="$HARNESS_DIR/fixtures/continuation/multi-step-thrash.json"
if [[ -f "$FIXTURE" ]]; then
  ok "fixture exists: fixtures/continuation/multi-step-thrash.json"
  if python3 "$HOOK_PY" --fixture "$FIXTURE"; then
    ok "multi-step thrash fixture passed"
  else
    fail "multi-step thrash fixture failed"
  fi
else
  fail "missing fixture $FIXTURE"
fi

# Stdin round-trip (engine accepts envelope and returns JSON)
STDIN_OUT="$(
  printf '%s' '{"toolName":"update_goal","toolInput":{"objective":"probe","status":"active"},"sessionId":"verify","cwd":"'"$REPO_ROOT"'"}' \
    | DO_CONTINUATION_STATE_DIR="$(mktemp -d)" DO_CONTINUATION_NOW=5000 \
      python3 "$HOOK_PY" 2>/dev/null || true
)"
if printf '%s' "$STDIN_OUT" | grep -q '"lane"'; then
  ok "stdin PostToolUse envelope returns lane JSON"
else
  fail "stdin envelope did not return lane JSON: $STDIN_OUT"
fi

# ---------------------------------------------------------------------------
section "5. Project discovery install (optional but preferred)"
# ---------------------------------------------------------------------------

PROJ_HOOK="$REPO_ROOT/.do/hooks/continuation-nudge.json"
PROJ_BIN="$REPO_ROOT/.do/hooks/bin/continuation-nudge.py"
if [[ -e "$PROJ_HOOK" ]]; then
  ok "project .do/hooks/continuation-nudge.json installed"
  if [[ -e "$PROJ_BIN" || -L "$PROJ_BIN" ]]; then
    ok "project .do/hooks/bin/continuation-nudge.py installed"
  else
    fail "project hook JSON present but bin missing"
  fi
else
  # Soft: enablement documented — still fail if README lacks install steps
  if grep -q 'continuation-nudge' "$HARNESS_DIR/README.md" 2>/dev/null; then
    ok "install not present; enablement documented in do-harness/README.md"
  else
    fail "install missing and do-harness/README.md lacks continuation-nudge enablement"
  fi
fi

# ---------------------------------------------------------------------------
section "6. Hooks README enablement"
# ---------------------------------------------------------------------------

HOOKS_README="$HARNESS_DIR/hooks/README.md"
if [[ -f "$HOOKS_README" ]] && grep -q 'continuation-nudge' "$HOOKS_README"; then
  ok "hooks/README.md documents continuation-nudge"
else
  fail "hooks/README.md should document continuation-nudge"
fi

# ---------------------------------------------------------------------------
printf '\n'
if [[ "$FAIL" -eq 0 ]]; then
  printf 'VAL-M2-CONT-001: PASS (%s checks)\n' "$PASS"
  exit 0
fi
printf 'VAL-M2-CONT-001: FAIL (%s passed, %s failed)\n' "$PASS" "$FAIL" >&2
exit 1
