#!/usr/bin/env bash
# Flag unlinked TODO/FIXME/HACK markers in *new product code*.
# Scans only do product surfaces + scripts/docs policy paths so the large
# imported grok-build tree is not a false-positive farm.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Product / policy surfaces only (extension of do, not full vendor tree).
PATHS=(
  "do-harness"
  "scripts"
  "docs"
  ".github"
  "README.md"
  "FORK.md"
  "CHANGELOGS.md"
  "CONTRIBUTING.md"
  "SECURITY.md"
  ".pre-commit-config.yaml"
  "clippy.toml"
)

# Match bare markers: TODO / FIXME / HACK / XXX that are comment debt style
# but not TODO(ticket) / FIXME(https://...) / FIXMEish product "TODO list" prose.
MARKER_RE='(^|[^A-Za-z0-9_])((TODO|FIXME|HACK)(\([^)]*\))?|XXX)([^A-Za-z0-9_]|$)'

mapfile -t HITS < <(
  for p in "${PATHS[@]}"; do
    [[ -e "$p" ]] || continue
    git grep -nI -E '(TODO|FIXME|HACK|XXX)' -- "$p" 2>/dev/null || true
  done
)

BAD=()
for hit in "${HITS[@]:-}"; do
  [[ -z "$hit" ]] && continue
  file=${hit%%:*}
  rest=${hit#*:}
  line=${rest#*:}

  # Allow linked forms: TODO(TICKET-1), TODO(#12), FIXME(https://...)
  if echo "$line" | grep -Eq '(TODO|FIXME|HACK)\((#|[A-Za-z][A-Za-z0-9_-]*-?[0-9]+|https?://|TICKET|ISSUE)'; then
    continue
  fi
  if echo "$line" | grep -Eq '(TODO|FIXME).{0,30}https?://'; then
    continue
  fi

  # Product language: "TODO list", "TODO panel", task tracking — not debt markers
  if echo "$line" | grep -Eqi 'todo list|todo panel|todo item|todo/task|## TODO|task list|tracking.*TODO|TODO comments|pattern.*TODO|"TODO"|'"'"'TODO'"'"''; then
    continue
  fi

  # Policy / script self-reference
  if echo "$file" | grep -Eq 'scripts/check-tech-debt|docs/tech-debt|\.pre-commit|clippy\.toml'; then
    continue
  fi

  # Require actual debt-looking marker (not substring of other words)
  if ! echo "$line" | grep -Eq "$MARKER_RE"; then
    continue
  fi

  # Prefer lines that look like comment debt: // TODO, # TODO, <!-- TODO
  if ! echo "$line" | grep -Eq '(//|#|/\*|\*)\s*(TODO|FIXME|HACK)\b'; then
    # still flag bare TODO: in code comments without // if md policy
    if echo "$file" | grep -Eq '\.(md|yml|yaml|sh)$' && echo "$line" | grep -Eq '\b(TODO|FIXME|HACK):\s'; then
      :
    else
      continue
    fi
  fi

  BAD+=("$hit")
done

if ((${#BAD[@]} > 0)); then
  echo "Unlinked tech-debt markers in product paths (use TODO(TICKET-n) or TODO(https://...)):"
  printf '%s\n' "${BAD[@]}"
  echo "Count: ${#BAD[@]}"
  echo "Policy: docs/tech-debt.md"
  exit 1
fi

echo "Tech debt marker check passed (product paths)."
