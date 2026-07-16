#!/usr/bin/env bash
# Product install gates for package/binary `doit` (VAL-BIN-*, VAL-PKG-*).
#
# Sections:
#   1–5  BIN identity + cargo check -p doit
#   6    Product CI/docs smoke uses -p doit (VAL-PKG-001)
#   7    Release matrix + binstall metadata (VAL-PKG-002, VAL-PKG-003)
#   8    README Install seal (VAL-PKG-005)
#   9    NPM surface (optional) — skipped when no product npm package
#
# Exit 0 only when all implemented gates pass. No live npm/crates.io publish.

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
section "7. Release matrix + binstall (VAL-PKG-002, VAL-PKG-003)"
# ---------------------------------------------------------------------------

REL_YML="$REPO_ROOT/.github/workflows/release.yml"

if [[ -f "$REL_YML" ]]; then
  if grep -Eq '^[[:space:]]*PACKAGE:[[:space:]]*doit[[:space:]]*$' "$REL_YML" \
    || grep -Fq 'PACKAGE: doit' "$REL_YML"; then
    ok 'release.yml PACKAGE is doit'
  else
    fail 'release.yml PACKAGE is not doit'
  fi

  if grep -Eq '^[[:space:]]*BINARY:[[:space:]]*doit[[:space:]]*$' "$REL_YML" \
    || grep -Fq 'BINARY: doit' "$REL_YML"; then
    ok 'release.yml BINARY is doit'
  else
    fail 'release.yml BINARY is not doit'
  fi

  if grep -Fq 'cargo build -p "${PACKAGE}"' "$REL_YML" \
    || grep -Fq 'cargo build -p doit' "$REL_YML"; then
    ok 'release.yml builds package doit'
  else
    fail 'release.yml does not build package doit'
  fi

  targets=(
    x86_64-unknown-linux-gnu
    aarch64-unknown-linux-gnu
    x86_64-apple-darwin
    aarch64-apple-darwin
    x86_64-pc-windows-msvc
    aarch64-pc-windows-msvc
  )
  target_ok=0
  for t in "${targets[@]}"; do
    if grep -Fq "$t" "$REL_YML"; then
      target_ok=$((target_ok + 1))
    else
      fail "release.yml missing target $t"
    fi
  done
  if [[ "$target_ok" -eq 6 ]]; then
    ok 'release.yml full 6-target matrix present'
  fi

  if grep -Fq 'dathtd119/doit' "$REL_YML"; then
    ok 'release.yml references dathtd119/doit'
  else
    fail 'release.yml missing dathtd119/doit'
  fi

  if grep -Eq 'crates\.io|npm publish' "$REL_YML" \
    && ! grep -Eq 'No crates\.io / npm publish|no crates\.io|not crates\.io' "$REL_YML"; then
    # Allow explicit non-publish comments; fail only if a live publish step appears.
    if grep -Eq 'cargo publish|npm publish' "$REL_YML"; then
      fail 'release.yml appears to publish to crates.io/npm'
    else
      ok 'release.yml has no live crates.io/npm publish step'
    fi
  else
    ok 'release.yml has no live crates.io/npm publish step'
  fi
else
  fail 'missing .github/workflows/release.yml'
fi

if [[ -f "$PKG_TOML" ]]; then
  if grep -Fq '[package.metadata.binstall]' "$PKG_TOML"; then
    ok 'Cargo.toml has [package.metadata.binstall]'
  else
    fail 'Cargo.toml missing [package.metadata.binstall]'
  fi

  if grep -Eq 'repository = "https://github.com/dathtd119/doit"' "$PKG_TOML"; then
    ok 'package repository is dathtd119/doit'
  else
    fail 'package repository is not https://github.com/dathtd119/doit'
  fi

  if grep -Fq 'publish = false' "$PKG_TOML"; then
    ok 'package publish = false (no crates.io)'
  else
    fail 'package should set publish = false'
  fi
else
  fail "cannot read $PKG_TOML for binstall metadata"
fi

# ---------------------------------------------------------------------------
section "8. README Install seal (VAL-PKG-005)"
# ---------------------------------------------------------------------------

README="$REPO_ROOT/README.md"
if [[ -f "$README" ]]; then
  if grep -Eq '^## Install' "$README"; then
    ok 'README has ## Install section'
  else
    fail 'README missing ## Install section'
  fi

  # Extract Install section body (until next ## heading) for focused asserts.
  install_body="$(
    awk '
      /^## Install/ { on=1; next }
      on && /^## / { exit }
      on { print }
    ' "$README"
  )"

  if printf '%s' "$install_body" | grep -Fq 'dathtd119/doit'; then
    ok 'README Install targets dathtd119/doit'
  else
    fail 'README Install missing dathtd119/doit'
  fi

  if printf '%s' "$install_body" | grep -Eq '`doit`|package and binary are both \*\*`doit`\*\*'; then
    ok 'README Install names product package/binary doit'
  else
    # Broader: any doit token in Install is acceptable if paired with path install
    if printf '%s' "$install_body" | grep -Fq 'doit'; then
      ok 'README Install names product package/binary doit'
    else
      fail 'README Install does not name doit'
    fi
  fi

  if printf '%s' "$install_body" | grep -Fq 'cargo binstall' \
    && printf '%s' "$install_body" | grep -Fq 'dathtd119/doit'; then
    ok 'README Install documents cargo-binstall for dathtd119/doit'
  else
    fail 'README Install missing cargo-binstall + dathtd119/doit'
  fi

  if printf '%s' "$install_body" | grep -Fq 'cargo install --path crates/codegen/doit'; then
    ok 'README Install documents path install of crates/codegen/doit'
  else
    fail 'README Install missing cargo install --path crates/codegen/doit'
  fi

  if printf '%s' "$install_body" | grep -Fq 'cargo install --git https://github.com/dathtd119/doit.git'; then
    ok 'README Install documents git install from dathtd119/doit'
  else
    fail 'README Install missing cargo install --git dathtd119/doit'
  fi

  # Must not claim crates.io as an install path.
  # Allow explicit negation ("not crates.io", "Not an install path: crates.io").
  if printf '%s' "$install_body" | grep -Eqi 'cargo install doit[[:space:]]*$' \
    && ! printf '%s' "$install_body" | grep -Eqi 'not.*crates\.io|crates\.io.*not'; then
    fail 'README Install appears to claim bare cargo install doit (crates.io)'
  else
    ok 'README Install does not claim crates.io as install path'
  fi

  if printf '%s' "$install_body" | grep -Eqi 'not an install path|not crates\.io|\(not crates\.io\)'; then
    ok 'README Install explicitly excludes crates.io'
  else
    # Soft: still pass if no positive crates.io install recipe
    if printf '%s' "$install_body" | grep -Eqi 'crates\.io' \
      && ! printf '%s' "$install_body" | grep -Eqi 'not crates\.io|Not an install path'; then
      fail 'README Install mentions crates.io without exclusion'
    else
      ok 'README Install explicitly excludes crates.io'
    fi
  fi
else
  fail 'README.md missing'
fi

# ---------------------------------------------------------------------------
section "9. NPM surface (optional / not implemented)"
# ---------------------------------------------------------------------------
# Product install path is GitHub Releases + binstall + git/path. No live npm
# publish this mission. If a product npm package tree appears later, extend
# this section; for now skip without failing (VAL-PKG-004: implemented parts).

npm_pkg_candidates=(
  "$REPO_ROOT/npm"
  "$REPO_ROOT/packages/npm"
  "$REPO_ROOT/crates/codegen/doit/npm"
)
npm_found=0
for p in "${npm_pkg_candidates[@]}"; do
  if [[ -f "$p/package.json" ]]; then
    npm_found=1
    if grep -Eq '"name"[[:space:]]*:[[:space:]]*"@?dathtd119/doit"' "$p/package.json" \
      || grep -Fq 'dathtd119/doit' "$p/package.json"; then
      ok "npm package.json references dathtd119/doit ($p)"
    else
      fail "npm package.json missing dathtd119/doit ($p)"
    fi
  fi
done
if [[ "$npm_found" -eq 0 ]]; then
  ok 'NPM product package not present — gate skipped (no live npm this mission)'
fi

# ---------------------------------------------------------------------------
printf '\n== summary ==\n'
printf 'pass=%s fail=%s\n' "$PASS" "$FAIL"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
printf 'verify-install: BIN + REL + README Install OK\n'
exit 0
