#!/usr/bin/env bash
# F-M1-MODEL-RESOLVE — role→model re-pin only while role_switch_allowed.
#
# Evidence:
#   - pure policy tests (gate_role_model_repin / should_repin_model_from_role)
#   - shell handle_session_mode calls re-pin when Apply
#   - subagent spawn path still uses resolve_effective_model_config (unchanged)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

echo "==> cargo test -p xai-grok-shell --test role_switch_policy"
cargo test -p xai-grok-shell --test role_switch_policy -- --nocapture

echo "==> source markers (re-pin policy + session wire + subagent unchanged)"
fail=0

if ! rg -q "fn should_repin_model_from_role" \
  crates/codegen/xai-grok-shell/src/session/role_switch.rs; then
  echo "FAIL: should_repin_model_from_role not defined"
  fail=1
fi

if ! rg -q "fn gate_role_model_repin" \
  crates/codegen/xai-grok-shell/src/session/role_switch.rs; then
  echo "FAIL: gate_role_model_repin not defined"
  fail=1
fi

if ! rg -q "repin_model_from_role_assignment" \
  crates/codegen/xai-grok-shell/src/session/acp_session_impl/session_mode.rs; then
  echo "FAIL: session_mode missing role model re-pin call site"
  fail=1
fi

if ! rg -q "gate_role_model_repin" \
  crates/codegen/xai-grok-shell/src/session/acp_session_impl/session_mode.rs; then
  echo "FAIL: session_mode missing gate_role_model_repin"
  fail=1
fi

# Subagent spawn override path must remain independent of primary lock.
if ! rg -q "fn resolve_effective_model_config" \
  crates/codegen/xai-grok-shell/src/agent/subagent/mod.rs; then
  echo "FAIL: subagent resolve_effective_model_config missing (spawn precedence)"
  fail=1
fi

if ! rg -q "gate_role_model_repin_apply_pre_message" \
  crates/codegen/xai-grok-shell/tests/role_switch_policy.rs; then
  echo "FAIL: integration test for pre-message re-pin missing"
  fail=1
fi

if ! rg -q "gate_role_model_repin_keep_post_lock" \
  crates/codegen/xai-grok-shell/tests/role_switch_policy.rs; then
  echo "FAIL: integration test for post-lock keep missing"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo "F-M1-MODEL-RESOLVE: FAIL"
  exit 1
fi

echo "F-M1-MODEL-RESOLVE: PASS"
exit 0
