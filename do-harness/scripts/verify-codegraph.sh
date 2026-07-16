#!/usr/bin/env bash
# F-M3-CG / VAL-M3-CG-001: CodeGraph product surface (MCP wrapping xai-codebase-graph).
#
# Checks:
#   1. Design doc exists with MCP-first vs tool_pack + crate citation
#   2. MCP server + example TOML exist with explore/impact tools
#   3. Fixture sample exists
#   4. code-graph binary available (build if missing)
#   5. Fixture index + definition + references answer without grep thrash
#   6. Agent/docs pointers for explorer/worker
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
section "1. Design documentation (MCP-first + crate cite)"
# ---------------------------------------------------------------------------

DOC="$REPO_ROOT/docs/codegraph.md"
if [[ -f "$DOC" ]]; then
  ok "docs/codegraph.md exists"
else
  fail "missing $DOC"
fi

if [[ -f "$DOC" ]]; then
  for needle in \
    "MCP" \
    "tool_pack" \
    "xai-codebase-graph" \
    "codegraph_explore" \
    "codegraph_impact" \
    "VAL-M3-CG-001" \
    "search_tool" \
    "use_tool"
  do
    if grep -qF "$needle" "$DOC"; then
      ok "design mentions: $needle"
    else
      fail "design missing mention: $needle"
    fi
  done
fi

# ---------------------------------------------------------------------------
section "2. MCP server surface"
# ---------------------------------------------------------------------------

SERVER="$HARNESS_DIR/codegraph/mcp_server.py"
EXAMPLE="$HARNESS_DIR/codegraph/mcp.toml.example"

if [[ -f "$SERVER" ]]; then
  ok "mcp_server.py exists"
else
  fail "missing $SERVER"
fi

if [[ -f "$SERVER" ]]; then
  for needle in codegraph_explore codegraph_impact codegraph_stats code-graph xai-codebase-graph; do
    if grep -qF "$needle" "$SERVER"; then
      ok "server mentions: $needle"
    else
      fail "server missing: $needle"
    fi
  done
fi

if [[ -f "$EXAMPLE" ]] && grep -qF 'mcp_servers.doit-codegraph' "$EXAMPLE"; then
  ok "mcp.toml.example registers doit-codegraph"
else
  fail "mcp.toml.example must register [mcp_servers.doit-codegraph]"
fi

# Syntax-check server (no stdio session)
if python3 -m py_compile "$SERVER" 2>/dev/null; then
  ok "mcp_server.py py_compile"
else
  fail "mcp_server.py failed py_compile"
fi

# ---------------------------------------------------------------------------
section "3. Fixture sample"
# ---------------------------------------------------------------------------

FIXTURE="$HARNESS_DIR/fixtures/codegraph/sample"
if [[ -f "$FIXTURE/src/lib.rs" ]] && grep -qF 'WidgetCore' "$FIXTURE/src/lib.rs"; then
  ok "fixture defines WidgetCore"
else
  fail "fixture sample missing WidgetCore in lib.rs"
fi

if [[ -f "$FIXTURE/src/main.rs" ]] && grep -qF 'WidgetCore' "$FIXTURE/src/main.rs"; then
  ok "fixture main references WidgetCore"
else
  fail "fixture main must reference WidgetCore"
fi

# ---------------------------------------------------------------------------
section "4. code-graph binary (xai-codebase-graph)"
# ---------------------------------------------------------------------------

BIN="${DO_CODEGRAPH_BIN:-}"
if [[ -z "$BIN" ]]; then
  if [[ -x "$REPO_ROOT/target/debug/code-graph" ]]; then
    BIN="$REPO_ROOT/target/debug/code-graph"
  elif [[ -x "$REPO_ROOT/target/release/code-graph" ]]; then
    BIN="$REPO_ROOT/target/release/code-graph"
  elif command -v code-graph >/dev/null 2>&1; then
    BIN="$(command -v code-graph)"
  fi
fi

if [[ -z "${BIN:-}" || ! -x "$BIN" ]]; then
  printf '  … building code-graph (cargo build -p xai-codebase-graph --bin code-graph)\n'
  if (cd "$REPO_ROOT" && cargo build -p xai-codebase-graph --bin code-graph); then
    BIN="$REPO_ROOT/target/debug/code-graph"
    ok "built code-graph binary"
  else
    fail "could not build code-graph"
    BIN=""
  fi
else
  ok "code-graph binary: $BIN"
fi

# ---------------------------------------------------------------------------
section "5. Fixture explore + impact (no full-repo thrash)"
# ---------------------------------------------------------------------------

CACHE="$(mktemp "${TMPDIR:-/tmp}/do-cg-fixture.XXXXXX.bin")"
cleanup() { rm -f "$CACHE"; }
trap cleanup EXIT

if [[ -n "${BIN:-}" && -x "$BIN" ]]; then
  if "$BIN" index "$FIXTURE" --cache "$CACHE" --threads 2 >/tmp/do-cg-index.out 2>&1; then
    ok "indexed fixture sample"
  else
    fail "fixture index failed (see /tmp/do-cg-index.out)"
    cat /tmp/do-cg-index.out >&2 || true
  fi

  DEF_JSON="$("$BIN" definition "$FIXTURE" --cache "$CACHE" --symbol WidgetCore --json 2>/dev/null || true)"
  if printf '%s' "$DEF_JSON" | grep -q 'WidgetCore' \
    && printf '%s' "$DEF_JSON" | grep -qE 'lib\.rs'; then
    ok "explore (definition) finds WidgetCore in lib.rs"
  else
    fail "definition for WidgetCore did not cite lib.rs"
    printf '%s\n' "$DEF_JSON" >&2 || true
  fi

  REF_JSON="$("$BIN" references "$FIXTURE" --cache "$CACHE" --symbol WidgetCore --json 2>/dev/null || true)"
  # Impact: main.rs should reference the symbol
  if printf '%s' "$REF_JSON" | grep -q 'WidgetCore' \
    && printf '%s' "$REF_JSON" | grep -qE 'main\.rs'; then
    ok "impact (references) finds WidgetCore use in main.rs"
  else
    fail "references for WidgetCore did not cite main.rs"
    printf '%s\n' "$REF_JSON" >&2 || true
  fi

  # Server wrappers (import tools without starting stdio session)
  export DO_CODEGRAPH_BIN="$BIN"
  if python3 - "$SERVER" "$FIXTURE" "$CACHE" <<'PY'
import importlib.util
import sys
from pathlib import Path

server_path, fixture, cache = sys.argv[1], sys.argv[2], sys.argv[3]
spec = importlib.util.spec_from_file_location("do_cg_mcp", server_path)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

explore = mod.codegraph_explore(symbol="WidgetCore", repo=fixture, cache=cache)
impact = mod.codegraph_impact(symbol="WidgetCore", repo=fixture, cache=cache)
ok = (
    "WidgetCore" in explore
    and "lib.rs" in explore
    and "WidgetCore" in impact
    and "main.rs" in impact
)
if not ok:
    print("explore:", explore[:500], file=sys.stderr)
    print("impact:", impact[:500], file=sys.stderr)
    sys.exit(1)
print("mcp wrappers explore+impact ok")
PY
  then
    ok "MCP Python wrappers explore+impact on fixture"
  else
    fail "MCP Python wrappers failed on fixture"
  fi
else
  fail "skipped fixture queries — no binary"
fi

# ---------------------------------------------------------------------------
section "6. Agent + inventory pointers"
# ---------------------------------------------------------------------------

EXPLORER="$HARNESS_DIR/agents/explorer.md"
WORKER="$HARNESS_DIR/agents/worker.md"
CAP="$REPO_ROOT/docs/capability-map.md"
MATRIX="$REPO_ROOT/docs/patch-matrix.md"
IDX="$REPO_ROOT/docs/index.md"

if [[ -f "$EXPLORER" ]] && grep -qE 'codegraph|CodeGraph' "$EXPLORER"; then
  ok "agents/explorer.md mentions CodeGraph"
else
  fail "agents/explorer.md must mention CodeGraph / codegraph"
fi

if [[ -f "$WORKER" ]] && grep -qE 'codegraph|CodeGraph' "$WORKER"; then
  ok "agents/worker.md mentions CodeGraph"
else
  fail "agents/worker.md must mention CodeGraph / codegraph"
fi

if [[ -f "$CAP" ]] && grep -qE 'codegraph|CodeGraph|VAL-M3-CG' "$CAP"; then
  ok "docs/capability-map.md CodeGraph row updated"
else
  fail "docs/capability-map.md should cite CodeGraph product surface"
fi

if [[ -f "$MATRIX" ]] && grep -qE 'L7|CodeGraph|codegraph' "$MATRIX"; then
  ok "docs/patch-matrix.md mentions L7/CodeGraph"
else
  fail "docs/patch-matrix.md should mention L7 CodeGraph path"
fi

if [[ -f "$IDX" ]] && grep -qF 'codegraph.md' "$IDX"; then
  ok "docs/index.md links codegraph.md"
else
  fail "docs/index.md should link codegraph.md"
fi

# ---------------------------------------------------------------------------
section "Summary"
# ---------------------------------------------------------------------------

printf '\nResults: %d ok, %d fail\n' "$PASS" "$FAIL"
if [[ "$FAIL" -ne 0 ]]; then
  exit 1
fi
printf 'VAL-M3-CG-001 verify-codegraph: PASS\n'
exit 0
