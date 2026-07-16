#!/usr/bin/env bash
# Thin wrapper for apply-models.py (VAL-M1-MODEL-001 / F-M1-MODEL-APPLY).
#
# Usage (from do repo root or any cwd):
#   bash do-harness/scripts/apply-models.sh              # dry-run map
#   bash do-harness/scripts/apply-models.sh --validate   # exit 1 on bad names
#   bash do-harness/scripts/apply-models.sh --apply      # write frontmatter
#
# See do-harness/README.md and docs/models-and-config.md.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY="${SCRIPT_DIR}/apply-models.py"

if [[ ! -f "$PY" ]]; then
  printf 'error: missing %s\n' "$PY" >&2
  exit 2
fi

if ! command -v python3 >/dev/null 2>&1; then
  printf 'error: python3 is required\n' >&2
  exit 2
fi

exec python3 "$PY" "$@"
