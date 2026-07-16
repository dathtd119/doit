#!/usr/bin/env bash
# F-BIN-RENAME / VAL-BIN-*: product install package + binary identity for `doit`.
#
# Baseline gate for packaging identity (BIN). Later milestones extend this
# script for REL matrix, NPM dry-run, and docs asserts.
#
# Exit 0 only when all BIN checks pass.

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

PKG_TOML="$REPO_ROOT/crates/codegen/doit/Cargo.toml"
ROOT_TOML="$REPO_ROOT/Cargo.toml"

# ---------------------------------------------------------------------------
section "1. Product package path (VAL-BIN-003)"
# ---------------------------------------------------------------------------

if [[ -d "$REPO_ROOT/crates/codegen/doit" && -f "$PKG_TOML" ]]; then
  ok "package directory crates/codegen/doit exists"
else
  fail "missing crates/codegen/doit (expected product package path)"
fi

if [[ -e "$REPO_ROOT/crates/codegen/xai-grok-pager-bin" ]]; then
  fail "legacy path crates/codegen/xai-grok-pager-bin still present"
else
  ok "legacy path crates/codegen/xai-grok-pager-bin removed"
fi

# ---------------------------------------------------------------------------
section "2. Cargo package name + binary (VAL-BIN-001, VAL-BIN-002)"
# ---------------------------------------------------------------------------

if [[ -f "$PKG_TOML" ]]; then
  if grep -Eq '^name = "doit"' "$PKG_TOML"; then
    ok 'package name = "doit"'
  else
    fail 'Cargo.toml package name is not doit'
  fi

  if grep -Eq '^default-run = "doit"' "$PKG_TOML"; then
    ok 'default-run = "doit"'
  else
    fail 'default-run is not doit'
  fi

  if grep -Eq '^name = "doit"' "$PKG_TOML" && awk '
    BEGIN { in_bin=0; found=0 }
    /^\[\[bin\]\]/ { in_bin=1; next }
    in_bin && /^name = "doit"/ { found=1 }
    in_bin && /^\[/ && !/^\[\[bin\]\]/ { in_bin=0 }
    END { exit found ? 0 : 1 }
  ' "$PKG_TOML"; then
    ok '[[bin]] name = "doit"'
  else
    # Fallback: bin name line exists next to path
    if grep -A2 '^\[\[bin\]\]' "$PKG_TOML" | grep -Eq 'name = "doit"'; then
      ok '[[bin]] name = "doit"'
    else
      fail '[[bin]] name is not doit'
    fi
  fi

  if grep -Eq '^license = "Apache-2.0"' "$PKG_TOML"; then
    ok 'license Apache-2.0 preserved on package'
  else
    fail 'package license is not Apache-2.0'
  fi
else
  fail "cannot read $PKG_TOML"
fi

# ---------------------------------------------------------------------------
section "3. Workspace member (VAL-BIN-004 membership)"
# ---------------------------------------------------------------------------

if [[ -f "$ROOT_TOML" ]] && grep -Fq '"crates/codegen/doit"' "$ROOT_TOML"; then
  ok 'workspace members include crates/codegen/doit'
else
  fail 'workspace Cargo.toml missing crates/codegen/doit member'
fi

if grep -Fq 'xai-grok-pager-bin' "$ROOT_TOML"; then
  fail 'workspace still lists xai-grok-pager-bin'
else
  ok 'workspace no longer lists xai-grok-pager-bin'
fi

# ---------------------------------------------------------------------------
section "4. Internal crates not mass-renamed (VAL-CROSS-002)"
# ---------------------------------------------------------------------------

internal_sample=(
  "crates/codegen/xai-grok-pager"
  "crates/codegen/xai-grok-shell"
  "crates/codegen/xai-grok-tools"
)
internal_ok=0
for path in "${internal_sample[@]}"; do
  if [[ -d "$REPO_ROOT/$path" ]]; then
    internal_ok=$((internal_ok + 1))
  else
    fail "expected internal crate path missing: $path"
  fi
done
if [[ "$internal_ok" -eq "${#internal_sample[@]}" ]]; then
  ok "sample internal xai-grok-* crates still present ($internal_ok)"
fi

# Cargo metadata should resolve package doit and many xai-grok-* packages
if command -v cargo >/dev/null 2>&1; then
  meta_json="$(
    cd "$REPO_ROOT" && cargo metadata --no-deps --format-version 1 2>/dev/null || true
  )"
  if [[ -n "$meta_json" ]]; then
    if printf '%s' "$meta_json" | grep -Eq '"name"[[:space:]]*:[[:space:]]*"doit"'; then
      ok 'cargo metadata lists package doit'
    else
      fail 'cargo metadata does not list package doit'
    fi
    xai_count="$(
      printf '%s' "$meta_json" | grep -Eo '"name"[[:space:]]*:[[:space:]]*"xai-grok-[^"]+"' | wc -l | tr -d ' '
    )"
    if [[ "${xai_count:-0}" -ge 10 ]]; then
      ok "cargo metadata still has many xai-grok-* packages ($xai_count)"
    else
      fail "too few xai-grok-* packages in metadata ($xai_count); possible mass rename"
    fi
    if printf '%s' "$meta_json" | grep -Eq '"name"[[:space:]]*:[[:space:]]*"xai-grok-pager-bin"'; then
      fail 'cargo metadata still lists xai-grok-pager-bin'
    else
      ok 'cargo metadata does not list xai-grok-pager-bin'
    fi
  else
    fail 'cargo metadata --no-deps failed'
  fi
else
  fail 'cargo not available for metadata check'
fi

# ---------------------------------------------------------------------------
section "5. cargo check -p doit (VAL-BIN-004)"
# ---------------------------------------------------------------------------

if command -v cargo >/dev/null 2>&1; then
  if (cd "$REPO_ROOT" && cargo check -p doit); then
    ok 'cargo check -p doit exits 0'
  else
    fail 'cargo check -p doit failed'
  fi
else
  fail 'cargo not available for check -p doit'
fi

# ---------------------------------------------------------------------------
section "6. Product-facing CI/docs smoke uses -p doit (VAL-PKG-001)"
# ---------------------------------------------------------------------------

# Product install package must not be claimed as xai-grok-pager-bin in CI smoke.
assert_smoke_file() {
  local path="$1"
  local label="$2"
  if [[ ! -f "$path" ]]; then
    fail "missing $label ($path)"
    return
  fi
  if grep -Eq 'cargo (check|build|clippy|run) -p xai-grok-pager-bin' "$path"; then
    fail "$label still smokes xai-grok-pager-bin"
  else
    ok "$label does not smoke xai-grok-pager-bin"
  fi
  if grep -Eq 'cargo (check|build|clippy|run) -p doit' "$path"; then
    ok "$label uses -p doit"
  else
    # Some files only document check; require at least one -p doit cargo line
    if grep -Fq 'cargo check -p doit' "$path" || grep -Fq 'cargo build -p doit' "$path" || grep -Fq 'cargo clippy -p doit' "$path"; then
      ok "$label uses -p doit"
    else
      fail "$label missing cargo … -p doit smoke"
    fi
  fi
}

assert_smoke_file "$REPO_ROOT/.github/workflows/ci.yml" "ci.yml"
assert_smoke_file "$REPO_ROOT/.github/workflows/release.yml" "release.yml"
assert_smoke_file "$REPO_ROOT/.github/pull_request_template.md" "pull_request_template.md"
assert_smoke_file "$REPO_ROOT/README.md" "README.md"

if [[ -f "$REPO_ROOT/scripts/validate-agents-md.sh" ]]; then
  if grep -Fq 'cargo check -p doit' "$REPO_ROOT/scripts/validate-agents-md.sh"; then
    ok 'validate-agents-md.sh expects cargo check -p doit'
  else
    fail 'validate-agents-md.sh does not require cargo check -p doit'
  fi
  if grep -Fq 'xai-grok-pager-bin' "$REPO_ROOT/scripts/validate-agents-md.sh"; then
    fail 'validate-agents-md.sh still requires xai-grok-pager-bin'
  else
    ok 'validate-agents-md.sh no longer requires xai-grok-pager-bin'
  fi
else
  fail 'scripts/validate-agents-md.sh missing'
fi

# ---------------------------------------------------------------------------
printf '\n== summary ==\n'
printf 'pass=%s fail=%s\n' "$PASS" "$FAIL"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
printf 'verify-install: BIN identity + PKG smoke OK\n'
exit 0
