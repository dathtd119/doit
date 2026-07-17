#!/usr/bin/env bash
# Thin wrapper for apply-role-contracts.py (role contracts TOML → agent frontmatter).
#
# Usage:
#   bash do-harness/scripts/apply-role-contracts.sh              # dry-run
#   bash do-harness/scripts/apply-role-contracts.sh --validate
#   bash do-harness/scripts/apply-role-contracts.sh --apply
#
# See do-harness/config.roles.toml and docs/models-and-config.md.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY="${SCRIPT_DIR}/apply-role-contracts.py"

if [[ ! -f "$PY" ]]; then
  printf 'error: missing %s\n' "$PY" >&2
  exit 2
fi

if ! command -v python3 >/dev/null 2>&1; then
  printf 'error: python3 is required\n' >&2
  exit 2
fi

exec python3 "$PY" "$@"
