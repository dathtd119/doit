#!/usr/bin/env bash
# F-M1-ROSTER / VAL-M1-ROSTER-001: product agents from prompts + contracts.
#
# Confirms roster agent bodies exist under do-harness/prompts/agents/ and contracts
# under config.agents.toml (or legacy config.roles.toml). Product does NOT require
# do-harness/agents or install into .doit/agents / ~/.config/doit/agents.
#
# Exit 0 only when all checks pass.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$HARNESS_DIR/.." && pwd)"
REPO_ROOT="${DO_REPO_ROOT:-$REPO_ROOT}"

# Body file stems (alias form under prompts/agents/)
BODY_STEMS=(intake orchestrator explore worker oracle)

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
section "1. Source of truth (do-harness/prompts/agents/)"
# ---------------------------------------------------------------------------

for role in "${BODY_STEMS[@]}"; do
  src="$HARNESS_DIR/prompts/agents/${role}.md"
  if [[ -f "$src" ]]; then
    ok "prompts/agents/${role}.md exists"
  else
    fail "missing $src"
  fi
done

# ---------------------------------------------------------------------------
section "2. Contracts (config.agents.toml)"
# ---------------------------------------------------------------------------

CFG="$HARNESS_DIR/config.agents.toml"
if [[ ! -f "$CFG" ]]; then
  CFG="$HARNESS_DIR/config.roles.toml"
fi
if [[ -f "$CFG" ]]; then
  ok "$(basename "$CFG") exists"
else
  fail "missing config.agents.toml / config.roles.toml"
fi

python3 - "$HARNESS_DIR" "$CFG" "${BODY_STEMS[@]}" <<'PY'
import sys
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:
    import tomli as tomllib  # type: ignore

harness = Path(sys.argv[1])
cfg_path = Path(sys.argv[2])
stems = sys.argv[3:]
data = tomllib.loads(cfg_path.read_text(encoding="utf-8"))
# Prefer [agents]; fall back to [roles]
root = data.get("agents") or data.get("roles") or {}
errors = 0

# Map body stem -> possible contract keys
ALIASES = {
    "intake": ("intake", "grok-build-ask-user"),
    "orchestrator": ("orchestrator", "grok-build-orchestrator"),
    "explore": ("explore", "explorer"),
    "worker": ("worker", "grok-build-worker"),
    "oracle": ("oracle", "grok-build-oracle"),
}

for stem in stems:
    keys = ALIASES.get(stem, (stem,))
    block = None
    used = None
    for k in keys:
        if isinstance(root.get(k), dict):
            block = root[k]
            used = k
            break
    if block is None:
        print(f"  FAIL missing contract for {stem} (tried {keys})", file=sys.stderr)
        errors += 1
        continue
    body_path = harness / "prompts" / "agents" / f"{stem}.md"
    if not body_path.is_file():
        print(f"  FAIL missing body {body_path}", file=sys.stderr)
        errors += 1
        continue
    body = body_path.read_text(encoding="utf-8")
    if "## Mission" not in body:
        print(f"  FAIL {stem}: body missing ## Mission", file=sys.stderr)
        errors += 1
        continue
    if not block.get("model"):
        print(f"  FAIL {used}: model missing", file=sys.stderr)
        errors += 1
        continue
    tools = block.get("tools") or []
    if not tools:
        print(f"  FAIL {used}: tools empty", file=sys.stderr)
        errors += 1
        continue
    print(f"  ok  {stem}: contract [{used}] + body")
sys.exit(1 if errors else 0)
PY
py_rc=$?
if [[ $py_rc -eq 0 ]]; then
  ok "all body stems have contracts + ## Mission"
else
  fail "contract/body python checks"
fi

# ---------------------------------------------------------------------------
section "3. Runtime product_role path"
# ---------------------------------------------------------------------------

if [[ -f "$REPO_ROOT/crates/codegen/xai-grok-shell/src/session/product_role.rs" ]]; then
  ok "product_role.rs present (runtime load from prompts/agents)"
else
  fail "missing product_role.rs"
fi

if grep -q 'prompts/agents' "$REPO_ROOT/crates/codegen/xai-grok-shell/src/session/product_role.rs"; then
  ok "product_role.rs references prompts/agents"
else
  fail "product_role.rs should reference prompts/agents"
fi

echo
echo "pass=$PASS fail=$FAIL warn=$WARN"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
