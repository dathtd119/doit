#!/usr/bin/env bash
# VAL-ROLE-TOML-001: role contracts live in config.roles.toml; agents match; prompts body-only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$HARNESS_DIR/.." && pwd)"
REPO_ROOT="${DO_REPO_ROOT:-$REPO_ROOT}"

PASS=0
FAIL=0

ok() { PASS=$((PASS + 1)); printf '  ok  %s\n' "$1"; }
fail() { FAIL=$((FAIL + 1)); printf '  FAIL %s\n' "$1" >&2; }

echo "== role contracts (TOML) =="

ROLES_TOML="$HARNESS_DIR/config.roles.toml"
if [[ -f "$ROLES_TOML" ]]; then
  ok "config.roles.toml exists"
else
  fail "missing $ROLES_TOML"
fi

for needle in 'default = "intake"' '[roles.intake]' '[roles.worker]' 'tools =' 'disallowed_tools' 'color ='; do
  if grep -qF "$needle" "$ROLES_TOML" 2>/dev/null; then
    ok "roles toml has: $needle"
  else
    fail "roles toml missing: $needle"
  fi
done

# Body-only prompts: no YAML --- frontmatter config headers
for role in intake orchestrator explorer worker oracle; do
  p="$HARNESS_DIR/prompts/roles/${role}.md"
  if [[ ! -f "$p" ]]; then
    fail "missing prompt body $p"
    continue
  fi
  # Fail if file starts with --- YAML frontmatter (product config must not live here)
  if head -n1 "$p" | grep -qE '^---[[:space:]]*$'; then
    fail "prompts/roles/${role}.md has YAML frontmatter (must be body-only)"
  else
    ok "prompts/roles/${role}.md body-only"
  fi
done

# Docs mention TOML home
for doc in \
  "$REPO_ROOT/docs/models-and-config.md" \
  "$REPO_ROOT/docs/prompt-system.md" \
  "$HARNESS_DIR/README.md"
do
  if [[ -f "$doc" ]] && grep -qE 'config\.roles\.toml|\[roles\.|roles\.default' "$doc"; then
    ok "$(basename "$doc") documents roles TOML"
  else
    fail "$(basename "$doc") should document config.roles.toml / [roles.*]"
  fi
done

# Bridge: agents match TOML
if bash "$SCRIPT_DIR/apply-role-contracts.sh" --validate; then
  ok "apply-role-contracts --validate"
else
  fail "apply-role-contracts --validate"
fi

echo
echo "pass=$PASS fail=$FAIL"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
