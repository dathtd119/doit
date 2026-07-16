#!/usr/bin/env bash
# F-M1-ROSTER / VAL-M1-ROSTER-001: five product agents on discovery path.
#
# Confirms roster agents exist under do-harness/agents/ and are discoverable
# via project .do/agents/ (symlink or copy). Tool floors may be stubs; each
# file must exist, have loadable frontmatter (name + description + model), and
# a non-empty body.
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

resolve() {
  local p="$1"
  if [[ -L "$p" ]]; then
    readlink -f "$p" 2>/dev/null || readlink "$p"
  elif [[ -e "$p" ]]; then
    printf '%s\n' "$(cd "$(dirname "$p")" && pwd)/$(basename "$p")"
  else
    printf ''
  fi
}

# ---------------------------------------------------------------------------
section "1. Source of truth (do-harness/agents/)"
# ---------------------------------------------------------------------------

for role in "${ROLES[@]}"; do
  src="$HARNESS_DIR/agents/${role}.md"
  if [[ -f "$src" ]]; then
    ok "do-harness/agents/${role}.md exists"
  else
    fail "missing $src"
  fi
done

# ---------------------------------------------------------------------------
section "2. Project discovery path (.do/agents/)"
# ---------------------------------------------------------------------------
# Evidence: crates/codegen/xai-grok-agent/src/discovery.rs PROJECT_AGENT_SUBDIRS

for role in "${ROLES[@]}"; do
  disc="$REPO_ROOT/.do/agents/${role}.md"
  src="$HARNESS_DIR/agents/${role}.md"
  if [[ -e "$disc" ]]; then
    ok "discovery: .do/agents/${role}.md"
    if [[ -L "$disc" ]]; then
      target="$(resolve "$disc")"
      expected="$(resolve "$src")"
      if [[ -n "$target" && -n "$expected" && "$target" == "$expected" ]]; then
        ok "symlink ${role} → do-harness source"
      else
        fail "symlink ${role} target mismatch: got='$target' expected='$expected'"
      fi
    else
      warn "${role} discovery path is not a symlink (prefer ln -s to do-harness)"
    fi
  else
    fail "agent not on discovery path: $disc"
  fi
done

# ---------------------------------------------------------------------------
section "3. Frontmatter loadable (name / description / model + body)"
# ---------------------------------------------------------------------------

python3 - "$HARNESS_DIR/agents" "${ROLES[@]}" <<'PY'
import re, sys, pathlib

agents_dir = pathlib.Path(sys.argv[1])
roles = sys.argv[2:]
failed = []
for role in roles:
    path = agents_dir / f"{role}.md"
    if not path.is_file():
        failed.append(f"{role}: missing file")
        continue
    text = path.read_text(encoding="utf-8")
    if not text.lstrip().startswith("---"):
        failed.append(f"{role}: missing YAML frontmatter")
        continue
    parts = re.split(r"^---\s*$", text, maxsplit=2, flags=re.M)
    if len(parts) < 3:
        failed.append(f"{role}: frontmatter not closed")
        continue
    yaml, body = parts[1], parts[2].strip()
    checks = [
        (rf"(?m)^name:\s*{re.escape(role)}\s*$", f"name: {role}"),
        (r"(?m)^description:\s*", "description"),
        (r"(?m)^model:\s*", "model"),
    ]
    missing = [label for pat, label in checks if not re.search(pat, yaml)]
    if not body:
        missing.append("non-empty body")
    if missing:
        failed.append(f"{role}: " + ", ".join(missing))
    else:
        print(f"  ok  frontmatter loadable: {role}")

if failed:
    for f in failed:
        print(f"  FAIL {f}", file=sys.stderr)
    sys.exit(1)
sys.exit(0)
PY
ok "all five agents frontmatter parse checks passed"

# ---------------------------------------------------------------------------
section "4. Assignment table covers roster (config.models.yaml)"
# ---------------------------------------------------------------------------

ASSIGN_YAML="$HARNESS_DIR/config.models.yaml"
if [[ -f "$ASSIGN_YAML" ]]; then
  for role in "${ROLES[@]}"; do
    if grep -qE "^[[:space:]]*${role}:" "$ASSIGN_YAML"; then
      ok "assignment.${role} present in config.models.yaml"
    else
      fail "assignment.${role} missing in config.models.yaml"
    fi
  done
else
  fail "missing $ASSIGN_YAML"
fi

# ---------------------------------------------------------------------------
section "5. Fork discovery evidence"
# ---------------------------------------------------------------------------

AGENT_DISC_RS="$REPO_ROOT/crates/codegen/xai-grok-agent/src/discovery.rs"
if [[ -f "$AGENT_DISC_RS" ]] && grep -q '\.do/agents' "$AGENT_DISC_RS"; then
  ok "evidence: agent discovery uses .do/agents ($AGENT_DISC_RS)"
else
  fail "cannot find .do/agents in forked agent discovery.rs"
fi

# ---------------------------------------------------------------------------
section "Summary"
# ---------------------------------------------------------------------------

printf '\npassed=%s failed=%s warnings=%s\n' "$PASS" "$FAIL" "$WARN"
printf 'repo_root=%s\n' "$REPO_ROOT"
printf 'roles=%s\n' "${ROLES[*]}"

if [[ "$FAIL" -gt 0 ]]; then
  printf '\nVAL-M1-ROSTER-001: FAIL\n' >&2
  exit 1
fi

printf '\nVAL-M1-ROSTER-001: PASS (five product agents discoverable)\n'
exit 0
