#!/usr/bin/env bash
# F-M1-ROSTER / VAL-M1-ROSTER-001: five product roles from prompts + contracts.
#
# Confirms roster role bodies exist under do-harness/prompts/roles/ and contracts
# under config.roles.toml. Product does NOT require do-harness/agents or install
# into .doit/agents / ~/.config/doit/agents (user override only).
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
WARN=0

ok() {
  PASS=$((PASS + 1))
  printf '  ok  %s\n' "$1"
}

fail() {
  FAIL=$((FAIL + 1))
  printf '  FAIL %s\n' "$1" >&2
}

warn() {
  WARN=$((WARN + 1))
  printf '  warn %s\n' "$1"
}

section() {
  printf '\n== %s ==\n' "$1"
}

# ---------------------------------------------------------------------------
section "1. Source of truth (do-harness/prompts/roles/)"
# ---------------------------------------------------------------------------

for role in "${ROLES[@]}"; do
  src="$HARNESS_DIR/prompts/roles/${role}.md"
  if [[ -f "$src" ]]; then
    ok "prompts/roles/${role}.md exists"
  else
    fail "missing $src"
  fi
done

# ---------------------------------------------------------------------------
section "2. Contracts (config.roles.toml)"
# ---------------------------------------------------------------------------

if [[ -f "$HARNESS_DIR/config.roles.toml" ]]; then
  ok "config.roles.toml exists"
else
  fail "missing config.roles.toml"
fi

python3 - "$HARNESS_DIR" "${ROLES[@]}" <<'PY'
import sys
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:
    import tomli as tomllib  # type: ignore

harness = Path(sys.argv[1])
roles = sys.argv[2:]
data = tomllib.loads((harness / "config.roles.toml").read_text(encoding="utf-8"))
root = data.get("roles") or {}
errors = 0
for name in roles:
    block = root.get(name)
    if not isinstance(block, dict):
        print(f"  FAIL missing [roles.{name}]", file=sys.stderr)
        errors += 1
        continue
    body = (harness / "prompts" / "roles" / f"{name}.md").read_text(encoding="utf-8")
    if "## Mission" not in body:
        print(f"  FAIL {name}: body missing ## Mission", file=sys.stderr)
        errors += 1
        continue
    if not block.get("model"):
        print(f"  FAIL {name}: model missing", file=sys.stderr)
        errors += 1
        continue
    tools = block.get("tools") or []
    if not tools:
        print(f"  FAIL {name}: tools empty", file=sys.stderr)
        errors += 1
        continue
    print(f"  ok  {name}: contract + body")
sys.exit(1 if errors else 0)
PY
ok "contracts + bodies parse"

# ---------------------------------------------------------------------------
section "3. No stock agents bridge required"
# ---------------------------------------------------------------------------

AGENTS_DIR="$HARNESS_DIR/agents"
if [[ -d "$AGENTS_DIR" ]] && compgen -G "$AGENTS_DIR"/*.md >/dev/null 2>&1; then
  warn "do-harness/agents still has .md files (bridge retired; remove when ready)"
else
  ok "do-harness/agents has no stock role bridge (or absent)"
fi

DISC="$REPO_ROOT/.doit/agents"
if [[ -d "$DISC" ]] && compgen -G "$DISC"/*.md >/dev/null 2>&1; then
  warn ".doit/agents has files (user override OK; product does not require them)"
else
  ok ".doit/agents empty or absent (product default)"
fi

# ---------------------------------------------------------------------------
section "4. Discovery still supports optional user agents"
# ---------------------------------------------------------------------------

AGENT_DISC_RS="$REPO_ROOT/crates/codegen/xai-grok-agent/src/discovery.rs"
if [[ -f "$AGENT_DISC_RS" ]] && grep -q '\.doit/agents' "$AGENT_DISC_RS"; then
  ok "evidence: agent discovery still scans .doit/agents for user overrides ($AGENT_DISC_RS)"
else
  fail "cannot find .doit/agents in agent discovery.rs"
fi

PRODUCT_ROLE_RS="$REPO_ROOT/crates/codegen/xai-grok-shell/src/session/product_role.rs"
if [[ -f "$PRODUCT_ROLE_RS" ]]; then
  ok "product_role.rs present (runtime load from prompts/roles)"
else
  fail "missing $PRODUCT_ROLE_RS"
fi

# ---------------------------------------------------------------------------
section "summary"
# ---------------------------------------------------------------------------

printf '\npass=%s fail=%s warn=%s\n' "$PASS" "$FAIL" "$WARN"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
