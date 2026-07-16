#!/usr/bin/env bash
# Detect oversized *new or product* source files.
# Full vendor crate tree is baseline-ignored via allowlist; new do-harness /
# scripts / docs / .github paths must stay under thresholds.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

MAX_LINES="${MAX_LINES:-1500}"
MAX_BYTES="${MAX_BYTES:-500000}"
# Vendor/import tree keeps historical large files; product surfaces are gated.
SCOPE_REGEX="${SCOPE_REGEX:-^(do-harness/|scripts/|docs/|\.github/|\.devcontainer/|README\.md|FORK\.md|CHANGELOGS\.md|\.pre-commit|clippy\.toml)}"

EXIT=0
REPORT_DIR="${REPORT_DIR:-.quality}"
mkdir -p "$REPORT_DIR"
REPORT="$REPORT_DIR/large-files.txt"
: >"$REPORT"

mapfile -t FILES < <(
  git ls-files \
    | grep -E '\.(rs|py|ts|tsx|js|jsx|toml|md|yml|yaml|sh|json)$' \
    | grep -E "$SCOPE_REGEX" \
    || true
)

for f in "${FILES[@]}"; do
  [[ -f "$f" ]] || continue
  bytes=$(wc -c <"$f" | tr -d ' ')
  lines=$(wc -l <"$f" | tr -d ' ')
  if (( bytes > MAX_BYTES )); then
    echo "LARGE FILE (bytes): $f ($bytes > $MAX_BYTES)" | tee -a "$REPORT"
    EXIT=1
  fi
  if (( lines > MAX_LINES )); then
    echo "LARGE FILE (lines): $f ($lines > $MAX_LINES)" | tee -a "$REPORT"
    EXIT=1
  fi
done

# Also report (non-failing) inventory of huge vendor files for awareness.
{
  echo "# Vendor large-file inventory (informational, not gated)"
  git ls-files 'crates/**/*.rs' \
    | while read -r f; do
        [[ -f "$f" ]] || continue
        lines=$(wc -l <"$f" | tr -d ' ')
        if (( lines > 3000 )); then
          echo "$lines $f"
        fi
      done \
    | sort -nr \
    | head -40
} >"$REPORT_DIR/vendor-large-files.txt" || true

if (( EXIT != 0 )); then
  echo "Large file check failed on product paths. Split modules or justify threshold."
  exit 1
fi

echo "Large file check passed (product scope max ${MAX_LINES} lines / ${MAX_BYTES} bytes)."
echo "Vendor inventory: $REPORT_DIR/vendor-large-files.txt"
