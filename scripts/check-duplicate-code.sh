#!/usr/bin/env bash
# Run jscpd for DRY/duplication detection on product surfaces (fast path).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

REPORT_DIR="${REPORT_DIR:-.quality/jscpd}"
mkdir -p "$REPORT_DIR"

if ! command -v npx >/dev/null 2>&1; then
  echo "npx not available; install Node.js to run jscpd."
  exit 1
fi

# Default: product + scripts only (vendor crates are huge and time out).
# Full tree: SCAN_PATHS="crates do-harness scripts" bash scripts/check-duplicate-code.sh
SCAN_PATHS=${SCAN_PATHS:-"do-harness scripts docs"}

# shellcheck disable=SC2086
npx --yes jscpd@4.0.5 \
  --config .jscpd.json \
  --output "$REPORT_DIR" \
  --reporters console,json \
  $SCAN_PATHS \
  2>&1 | tee "$REPORT_DIR/console.log"

echo "Duplicate-code report written under $REPORT_DIR"
