#!/usr/bin/env bash
# VAL-M1-LOCK-001 — role switch lock implementation evidence.
#
# Runs pure unit tests for `role_switch_allowed` + cycle gate, and checks
# that shell/pager call sites still reference the flag policy.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

# Integration target only: avoids compiling unrelated lib unit tests that
# currently fail on pre-existing cfg(test) seams (EnvVarGuard, WorkspaceOps::for_test).
echo "==> cargo test -p xai-grok-shell --test role_switch_policy"
cargo test -p xai-grok-shell --test role_switch_policy -- --nocapture

echo "==> source markers (policy + gates)"
fail=0
for path in \
  "crates/codegen/xai-grok-shell/src/session/role_switch.rs" \
  "crates/codegen/xai-grok-shell/src/session/acp_session_impl/session_mode.rs" \
  "crates/codegen/xai-grok-pager/src/app/dispatch/modes.rs" \
  "crates/codegen/xai-grok-pager/src/app/agent_view/prompt.rs"
do
  if [[ ! -f "$path" ]]; then
    echo "MISSING: $path"
    fail=1
  fi
done

if ! rg -q "fn role_switch_allowed" \
  crates/codegen/xai-grok-shell/src/session/role_switch.rs; then
  echo "FAIL: role_switch_allowed not defined"
  fail=1
fi

if ! rg -q "role_switch_allowed" \
  crates/codegen/xai-grok-shell/src/session/acp_session_impl/session_mode.rs; then
  echo "FAIL: shell session_mode missing role_switch_allowed gate"
  fail=1
fi

if ! rg -q "dispatch_cycle_product_role" \
  crates/codegen/xai-grok-pager/src/app/dispatch/modes.rs; then
  echo "FAIL: pager missing product role cycle dispatch"
  fail=1
fi

if ! rg -q "CycleProductRole" \
  crates/codegen/xai-grok-pager/src/app/agent_view/prompt.rs; then
  echo "FAIL: prompt keybind missing CycleProductRole"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo "VAL-M1-LOCK-001: FAIL"
  exit 1
fi

echo "VAL-M1-LOCK-001: PASS"
exit 0
