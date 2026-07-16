#!/usr/bin/env bash
# Validate agent operating docs: size, required sections, and smoke command presence.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

AGENTS_FILE="${AGENTS_FILE:-AGENTS.md}"
README_FILE="${README_FILE:-README.md}"
EXIT=0

if [[ ! -f "$AGENTS_FILE" ]]; then
  echo "WARN: $AGENTS_FILE not present (may be local-only / gitignored)."
  echo "Validating README smoke commands instead for CI clones."
  TARGET="$README_FILE"
else
  size=$(wc -c <"$AGENTS_FILE" | tr -d ' ')
  if (( size < 100 )); then
    echo "FAIL: $AGENTS_FILE too small ($size bytes)"
    EXIT=1
  fi
  for section in "Hard Constraints" "Smoke" "cargo check" "Customization Order"; do
    if ! grep -q "$section" "$AGENTS_FILE"; then
      echo "FAIL: $AGENTS_FILE missing section/phrase: $section"
      EXIT=1
    fi
  done
  TARGET="$AGENTS_FILE"
fi

if [[ ! -f "$README_FILE" ]]; then
  echo "FAIL: $README_FILE missing"
  exit 1
fi

if ! grep -q 'cargo check -p xai-grok-pager-bin' "$README_FILE"; then
  echo "FAIL: README missing documented smoke command cargo check -p xai-grok-pager-bin"
  EXIT=1
fi

# Link sanity for relative markdown links in README.
# Skip local-only gitignored agent paths (AGENTS.md, plans/, .opencode/, …).
# Normalize "./AGENTS.md" → "AGENTS.md" so CI clones without the gitignored
# file do not fail Quality gates (GHA run 29511371575).
while read -r link; do
  path=${link#*(}
  path=${path%)}
  path=${path%%#*}
  path=${path#./}
  [[ -z "$path" || "$path" == http* || "$path" == mailto:* ]] && continue
  case "$path" in
    AGENTS.md|CONTINUE.md|plans/*|.opencode/*|.grok/*|.claude/*|.pi/*) continue ;;
  esac
  if [[ ! -e "$path" ]]; then
    echo "FAIL: broken README link target: $path"
    EXIT=1
  fi
done < <(grep -oE '\]\([^)]+\)' "$README_FILE" || true)

if (( EXIT != 0 )); then
  echo "AGENTS/README validation failed."
  exit 1
fi

echo "Validated agent docs ($TARGET) and README smoke command."
