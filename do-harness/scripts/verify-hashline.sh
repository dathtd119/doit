#!/usr/bin/env bash
# F-M3-HASH / VAL-M3-HASH-001: hashline default edit policy.
#
# Checks:
#   1. Policy doc (docs/hashline.md) — default + rollback + no reinvent grammar
#   2. Product toolset fragment defaults to hashline + native scheme knobs
#   3. Worker prefers hashline tools; orchestrator keeps edit deny including hashline_edit
#   4. L1 worker fragment references hashline; floors config includes hashline tools
#   5. Native namespace / FileToolset citations (no second grammar)
#   6. README enablement / verify pointer
#   7. docs/index links hashline policy
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
section "1. Policy documentation (default + rollback)"
# ---------------------------------------------------------------------------

DOC="$REPO_ROOT/docs/hashline.md"
if [[ -f "$DOC" ]]; then
  ok "docs/hashline.md exists"
else
  fail "missing $DOC"
fi

if [[ -f "$DOC" ]]; then
  for needle in \
    "VAL-M3-HASH-001" \
    "F-M3-HASH" \
    "file_toolset" \
    "hashline" \
    "standard" \
    "Rollback" \
    "GrokBuildHashline" \
    "hashline_read" \
    "hashline_edit" \
    "hashline_grep" \
    "worker" \
    "orchestrator" \
    "grammar"
  do
    if grep -qiF "$needle" "$DOC"; then
      ok "policy mentions: $needle"
    else
      fail "policy missing mention: $needle"
    fi
  done
fi

# ---------------------------------------------------------------------------
section "2. Product toolset fragment (default hashline)"
# ---------------------------------------------------------------------------

CFG="$HARNESS_DIR/config.toolset.toml"
if [[ -f "$CFG" ]]; then
  ok "do-harness/config.toolset.toml exists"
else
  fail "missing $CFG"
fi

if [[ -f "$CFG" ]]; then
  if grep -qE 'file_toolset\s*=\s*"hashline"' "$CFG"; then
    ok 'config.toolset.toml sets file_toolset = "hashline"'
  else
    fail 'config.toolset.toml must set file_toolset = "hashline" as product default'
  fi
  for needle in scheme hash_len chunk_size; do
    if grep -qE "^${needle}\\s*=" "$CFG" || grep -qE "^${needle}\\s*=" "$CFG"; then
      ok "toolset.hashline has $needle"
    elif grep -qE "${needle}\\s*=" "$CFG"; then
      ok "toolset.hashline has $needle"
    else
      fail "config.toolset.toml missing hashline knob: $needle"
    fi
  done
  # Must not invent a second tool registry or grammar section name.
  if grep -qiE '^(grammar|dsl|custom_hashline)' "$CFG"; then
    fail "config.toolset.toml must not invent custom hashline grammar keys"
  else
    ok "no invented grammar keys in toolset fragment"
  fi
fi

# ---------------------------------------------------------------------------
section "3. Worker + orchestrator agent guidance and floors"
# ---------------------------------------------------------------------------

WORKER="$HARNESS_DIR/agents/worker.md"
ORCH="$HARNESS_DIR/agents/orchestrator.md"

if [[ -f "$WORKER" ]]; then
  ok "worker agent exists"
  for needle in hashline_read hashline_edit hashline_grep hashline; do
    if grep -qiF "$needle" "$WORKER"; then
      ok "worker references: $needle"
    else
      fail "worker missing: $needle"
    fi
  done
  # Prefer hashline language is active (not "until M3").
  if grep -qiE 'prefer.*hashline|hashline.*(default|prefer|primary)|primary.*hashline' "$WORKER"; then
    ok "worker states hashline preference as active policy"
  else
    fail "worker body must state active hashline prefer/primary policy"
  fi
  if grep -qE 'hashline_edit' "$WORKER" && ! grep -A20 'disallowedTools:' "$WORKER" | grep -q 'hashline_edit'; then
    ok "worker allows hashline_edit (not on disallowedTools)"
  else
    fail "worker must not deny hashline_edit (implementer floor)"
  fi
else
  fail "missing $WORKER"
fi

if [[ -f "$ORCH" ]]; then
  ok "orchestrator agent exists"
  if grep -A30 'disallowedTools:' "$ORCH" | grep -q 'hashline_edit'; then
    ok "orchestrator disallows hashline_edit"
  else
    fail "orchestrator must keep hashline_edit on disallowedTools"
  fi
  if grep -qiE 'hashline|worker' "$ORCH"; then
    ok "orchestrator body references hashline or worker edit handoff"
  else
    fail "orchestrator should reference hashline or worker for edits"
  fi
else
  fail "missing $ORCH"
fi

# Non-worker implement deny for hashline_edit on remaining roster
for role in intake explorer oracle; do
  f="$HARNESS_DIR/agents/${role}.md"
  if [[ -f "$f" ]] && grep -A40 'disallowedTools:' "$f" | grep -q 'hashline_edit'; then
    ok "$role disallows hashline_edit"
  else
    fail "$role must disallow hashline_edit"
  fi
done

# ---------------------------------------------------------------------------
section "4. L1 worker fragment + permissions overlay"
# ---------------------------------------------------------------------------

L1="$HARNESS_DIR/prompts/roles/worker.md"
if [[ -f "$L1" ]]; then
  ok "L1 worker fragment exists"
  if grep -qiF 'hashline' "$L1"; then
    ok "L1 worker mentions hashline"
  else
    fail "L1 worker fragment should mention hashline"
  fi
  if grep -qiE 'until then|when product default is active \(M3\)' "$L1"; then
    fail "L1 worker still has provisional 'until M3' language — policy is shipped"
  else
    ok "L1 worker uses shipped hashline policy language"
  fi
else
  fail "missing $L1"
fi

PERM="$HARNESS_DIR/config.permissions.yaml"
if [[ -f "$PERM" ]]; then
  ok "config.permissions.yaml exists"
  for t in hashline_read hashline_edit hashline_grep; do
    if grep -qF "$t" "$PERM"; then
      ok "permissions overlay lists $t"
    else
      fail "config.permissions.yaml missing $t"
    fi
  done
else
  fail "missing $PERM"
fi

# ---------------------------------------------------------------------------
section "5. Native namespace (no reinvent) — fork + docs"
# ---------------------------------------------------------------------------

NATIVE="$REPO_ROOT/docs/grok-build/native-tools.md"
if [[ -f "$NATIVE" ]] && grep -qF 'GrokBuildHashline' "$NATIVE" && grep -qF 'FileToolset' "$NATIVE"; then
  ok "native-tools.md documents GrokBuildHashline + FileToolset"
else
  fail "docs/grok-build/native-tools.md should document GrokBuildHashline and FileToolset"
fi

CFG_RS="$REPO_ROOT/crates/codegen/xai-grok-shell/src/tools/config.rs"
if [[ -f "$CFG_RS" ]] \
  && grep -qF 'FileToolset' "$CFG_RS" \
  && grep -qF 'GrokBuildHashline:hashline_edit' "$CFG_RS"
then
  ok "fork tools/config.rs owns FileToolset::Hashline IDs"
else
  fail "missing stock FileToolset / GrokBuildHashline ids in tools/config.rs"
fi

# ---------------------------------------------------------------------------
section "6. README + index enablement"
# ---------------------------------------------------------------------------

README="$HARNESS_DIR/README.md"
if [[ -f "$README" ]] && grep -qE 'hashline|F-M3-HASH|VAL-M3-HASH|verify-hashline' "$README"; then
  ok "do-harness/README.md documents hashline / verify-hashline"
else
  fail "do-harness/README.md should document F-M3-HASH / verify-hashline"
fi

INDEX="$REPO_ROOT/docs/index.md"
if [[ -f "$INDEX" ]] && grep -qE 'hashline\.md|F-M3-HASH|VAL-M3-HASH' "$INDEX"; then
  ok "docs/index.md links hashline policy"
else
  fail "docs/index.md should link docs/hashline.md / F-M3-HASH"
fi

CAP="$REPO_ROOT/docs/capability-map.md"
if [[ -f "$CAP" ]] && grep -qiE 'hashline|FileToolset' "$CAP"; then
  ok "capability-map mentions hashline / FileToolset"
else
  fail "docs/capability-map.md should mention hashline product surface"
fi

# ---------------------------------------------------------------------------
section "Summary"
# ---------------------------------------------------------------------------

printf '\npassed=%s failed=%s\n' "$PASS" "$FAIL"
if [[ "$FAIL" -eq 0 ]]; then
  printf 'VAL-M3-HASH-001: PASS\n'
  exit 0
fi
printf 'VAL-M3-HASH-001: FAIL\n' >&2
exit 1
