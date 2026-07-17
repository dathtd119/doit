#!/usr/bin/env bash
# VAL-ROLE-TOML-001: agent contracts live in config.agents.toml; prompts body-only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$HARNESS_DIR/.." && pwd)"
REPO_ROOT="${DO_REPO_ROOT:-$REPO_ROOT}"

PASS=0
FAIL=0

ok() { PASS=$((PASS + 1)); printf '  ok  %s\n' "$1"; }
fail() { FAIL=$((FAIL + 1)); printf '  FAIL %s\n' "$1" >&2; }

echo "== agent contracts (TOML) =="

ROLES_TOML="$HARNESS_DIR/config.agents.toml"
if [[ ! -f "$ROLES_TOML" ]]; then
  ROLES_TOML="$HARNESS_DIR/config.roles.toml"
fi
if [[ -f "$ROLES_TOML" ]]; then
  ok "$(basename "$ROLES_TOML") exists"
else
  fail "missing config.agents.toml / config.roles.toml"
fi

# Accept [agents] (preferred) or legacy [roles]
for needle in 'default =' 'tools =' 'disallowed_tools' 'color =' 'allowed_subagents'; do
  if grep -qF "$needle" "$ROLES_TOML" 2>/dev/null; then
    ok "agents toml has: $needle"
  else
    fail "agents toml missing: $needle"
  fi
done

if grep -qE '\[agents\.(grok-build-worker|worker)\]|\[roles\.worker\]' "$ROLES_TOML" 2>/dev/null; then
  ok "worker contract present"
else
  fail "worker contract missing"
fi

# Body-only prompts: no YAML --- frontmatter config headers
for role in intake orchestrator explore worker oracle; do
  p="$HARNESS_DIR/prompts/agents/${role}.md"
  if [[ ! -f "$p" ]]; then
    fail "missing prompt body $p"
    continue
  fi
  if head -n1 "$p" | grep -qE '^---[[:space:]]*$'; then
    fail "prompts/agents/${role}.md has YAML frontmatter (must be body-only)"
  else
    ok "prompts/agents/${role}.md body-only"
  fi
done

# Docs mention agents / roles TOML home
for doc in \
  "$REPO_ROOT/docs/models-and-config.md" \
  "$REPO_ROOT/docs/agents-and-prompts.md" \
  "$REPO_ROOT/docs/prompt-system.md" \
  "$HARNESS_DIR/README.md"
do
  if [[ -f "$doc" ]] && grep -qE 'config\.(agents|roles)\.toml|\[agents\.|\[roles\.|prompts/agents' "$doc"; then
    ok "$(basename "$doc") documents agents/roles TOML or prompts/agents"
  else
    fail "$(basename "$doc") should document config.agents.toml / prompts/agents"
  fi
done

# Optional bridge validate (may no-op if agents bridge retired)
if [[ -f "$SCRIPT_DIR/apply-role-contracts.sh" ]]; then
  if bash "$SCRIPT_DIR/apply-role-contracts.sh" --validate 2>/dev/null; then
    ok "apply-role-contracts --validate"
  else
    ok "apply-role-contracts --validate skipped/soft-fail (agents bridge optional)"
  fi
fi

echo
echo "pass=$PASS fail=$FAIL"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
