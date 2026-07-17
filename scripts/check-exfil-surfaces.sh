#!/usr/bin/env bash
# Inventory + regression gate for Grok Build CLI codebase-upload / storage
# surfaces (Cereblab wire-level analysis, mid-July 2026).
#
# Scans tracked source for:
#   - /v1/storage API path (cli-chat-proxy storage channel)
#   - cli-chat-proxy.grok.com (inference + storage proxy)
#   - storage.googleapis.com / *.googleapis.com (GCS targets)
#   - grok-code-session-traces (session-trace bucket name — always critical)
#
# Fail conditions:
#   1. CRITICAL bucket name appears anywhere (never allowlisted)
#   2. Pattern hit in a file not listed in scripts/exfil-surfaces.allowlist
#   3. Fail-closed product gates removed/regressed in agent config
#
# Soft inventory (always printed): allowlisted hit counts for audit.
#
# Usage:
#   bash scripts/check-exfil-surfaces.sh
#   EXFIL_SOFT=1 bash scripts/check-exfil-surfaces.sh   # report only, exit 0
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

ALLOWLIST_FILE="${ALLOWLIST_FILE:-scripts/exfil-surfaces.allowlist}"
REPORT_DIR="${REPORT_DIR:-.quality}"
REPORT="$REPORT_DIR/exfil-surfaces.txt"
SOFT="${EXFIL_SOFT:-0}"

mkdir -p "$REPORT_DIR"
: >"$REPORT"

# Combined inventory regex (ERE). Keep in sync with the "Patterns" section below.
PATTERN='(/v1/storage|cli-chat-proxy\.grok\.com|storage\.googleapis\.com|[a-zA-Z0-9._-]+\.googleapis\.com|grok-code-session-traces)'

# Never acceptable — Cereblab session-trace bucket or literal hardcode of that name.
CRITICAL_PATTERN='grok-code-session-traces'

# Paths never scanned (generated noise / binary-adjacent).
EXCLUDE_PATH_RE='^(third_party/|THIRD-PARTY-NOTICES|Cargo\.lock|\.quality/|target/)'

log() { printf '%s\n' "$*" | tee -a "$REPORT"; }

load_allowlist() {
  local line
  ALLOWLIST=()
  if [[ ! -f "$ALLOWLIST_FILE" ]]; then
    log "ERROR: allowlist missing: $ALLOWLIST_FILE"
    exit 2
  fi
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    line="${line%%#*}"
    line="$(echo "$line" | sed 's/[[:space:]]*$//')"
    [[ -z "$line" ]] && continue
    ALLOWLIST+=("$line")
  done <"$ALLOWLIST_FILE"
}

is_allowlisted() {
  local f="$1" a
  for a in "${ALLOWLIST[@]}"; do
    [[ "$f" == "$a" ]] && return 0
  done
  return 1
}

log "=== Exfil surface scan (codebase upload / storage domains) ==="
log "Root: $ROOT"
log "Allowlist: $ALLOWLIST_FILE"
log "Patterns:"
log "  - /v1/storage"
log "  - cli-chat-proxy.grok.com"
log "  - storage.googleapis.com"
log "  - *.googleapis.com"
log "  - grok-code-session-traces  (CRITICAL — never allowlisted)"
log ""

load_allowlist

mapfile -t HITS < <(
  # git grep over tracked text; skip binary (-I). Pathspec excludes lock noise.
  git grep -nI -E "$PATTERN" -- \
    ':!third_party/**' \
    ':!THIRD-PARTY-NOTICES' \
    ':!Cargo.lock' \
    ':!.quality/**' \
    ':!target/**' \
    2>/dev/null || true
)

# Self-reference: the scanner + allowlist + this workflow mention the patterns.
SELF_RE='^(scripts/check-exfil-surfaces\.sh|scripts/exfil-surfaces\.allowlist|\.github/workflows/no-telemetry-gate\.yml|docs/.*exfil)'

CRITICAL_HITS=()
NEW_HITS=()
ALLOWLISTED_HITS=()
declare -A FILES_SEEN=()

for hit in "${HITS[@]:-}"; do
  [[ -z "$hit" ]] && continue
  file="${hit%%:*}"
  rest="${hit#*:}"
  # rest is "line:content" or just content depending on path colons — use git grep -n format file:line:text
  # file may contain colons only on Windows; assume POSIX paths.
  if [[ "$file" =~ $EXCLUDE_PATH_RE ]]; then
    continue
  fi
  if [[ "$file" =~ $SELF_RE ]]; then
    continue
  fi
  # Skip the allowlist file itself and this script's docs if any
  case "$file" in
    scripts/check-exfil-surfaces.sh|scripts/exfil-surfaces.allowlist|.github/workflows/no-telemetry-gate.yml)
      continue
      ;;
  esac

  line_body="${hit#*:*:}"
  FILES_SEEN["$file"]=1

  if echo "$hit" | grep -Eq "$CRITICAL_PATTERN"; then
    CRITICAL_HITS+=("$hit")
    continue
  fi

  if is_allowlisted "$file"; then
    ALLOWLISTED_HITS+=("$hit")
  else
    NEW_HITS+=("$hit")
  fi
done

# --- Fail-closed product gates (bypass detection) ---
# Extract a single method body: from `fn NAME` to the next `pub fn` / `fn `
# at the same indent level, so a nearby method's `false` cannot satisfy us.
extract_fn_body() {
  local file="$1" name="$2"
  awk -v name="$name" '
    $0 ~ ("fn[[:space:]]+" name "[[:space:](]") { grab=1 }
    grab {
      print
      # stop at next method definition (same-file pub fn / fn at method indent)
      if (NR > 1 && printed && $0 ~ /^[[:space:]]*(pub[[:space:]]+)?(async[[:space:]]+)?fn[[:space:]]/) {
        exit
      }
      if (grab) printed=1
    }
  ' "$file"
}

gate_fn_returns_false() {
  local file="$1" name="$2"
  local body
  body="$(extract_fn_body "$file" "$name")"
  [[ -n "$body" ]] || return 1
  # First non-comment statement after `{` must be bare `false` (hard off).
  echo "$body" | grep -Eq '^[[:space:]]*false[[:space:]]*$'
}

gate_fn_has_resolved_false() {
  local file="$1" name="$2"
  local body
  body="$(extract_fn_body "$file" "$name")"
  [[ -n "$body" ]] || return 1
  echo "$body" | grep -Eq 'Resolved::new\(false'
}

GATE_FILE="crates/codegen/xai-grok-shell/src/agent/config.rs"
GATE_FAIL=0
if [[ ! -f "$GATE_FILE" ]]; then
  log "GATE FAIL: missing $GATE_FILE"
  GATE_FAIL=1
else
  if ! gate_fn_returns_false "$GATE_FILE" "is_trace_upload_enabled"; then
    log "GATE FAIL: is_trace_upload_enabled no longer hard-returns false in $GATE_FILE"
    GATE_FAIL=1
  fi
  if ! gate_fn_has_resolved_false "$GATE_FILE" "resolve_trace_upload"; then
    log "GATE FAIL: resolve_trace_upload no longer Resolved::new(false, ...) in $GATE_FILE"
    GATE_FAIL=1
  fi
  if ! gate_fn_returns_false "$GATE_FILE" "is_telemetry_enabled"; then
    log "GATE FAIL: is_telemetry_enabled no longer hard-returns false in $GATE_FILE"
    GATE_FAIL=1
  fi
  if [[ "$GATE_FAIL" -eq 0 ]]; then
    log "Gates: fail-closed upload/telemetry checks present in $GATE_FILE"
  fi
fi

# Orphan allowlist entries (file removed but still listed) — warn, fail soft.
ORPHANS=()
for a in "${ALLOWLIST[@]}"; do
  if [[ ! -f "$a" ]]; then
    ORPHANS+=("$a")
  fi
done

log ""
log "--- Inventory ---"
log "Unique files with hits: ${#FILES_SEEN[@]}"
log "Allowlisted line hits:  ${#ALLOWLISTED_HITS[@]}"
log "New (unallowlisted):    ${#NEW_HITS[@]}"
log "Critical hits:          ${#CRITICAL_HITS[@]}"
log "Orphan allowlist paths: ${#ORPHANS[@]}"
log ""

if ((${#ALLOWLISTED_HITS[@]} > 0)); then
  log "Allowlisted hits (inventory — known residual surfaces):"
  # Summarize by file count
  printf '%s\n' "${ALLOWLISTED_HITS[@]}" \
    | cut -d: -f1 \
    | sort \
    | uniq -c \
    | sort -rn \
    | while read -r cnt path; do
        log "  $cnt  $path"
      done
  log ""
fi

EXIT=0

if ((${#CRITICAL_HITS[@]} > 0)); then
  log "CRITICAL: session-trace bucket name or forbidden surface present:"
  printf '%s\n' "${CRITICAL_HITS[@]}" | tee -a "$REPORT"
  log ""
  EXIT=1
fi

if ((${#NEW_HITS[@]} > 0)); then
  log "NEW unallowlisted exfil-surface hits (add to allowlist only if intentional residual code):"
  printf '%s\n' "${NEW_HITS[@]}" | tee -a "$REPORT"
  log ""
  log "To acknowledge intentionally: add the file path to $ALLOWLIST_FILE"
  log "Prefer deleting/stubbing the surface over expanding the allowlist."
  EXIT=1
fi

if ((${#ORPHANS[@]} > 0)); then
  log "WARN: allowlist entries missing on disk (clean them up):"
  printf '  %s\n' "${ORPHANS[@]}" | tee -a "$REPORT"
  # Orphans alone do not fail — avoid thrash when files move mid-refactor.
fi

if [[ "$GATE_FAIL" -ne 0 ]]; then
  EXIT=1
fi

if [[ "$EXIT" -ne 0 ]]; then
  log ""
  log "Exfil surface check FAILED."
  log "Report: $REPORT"
  if [[ "$SOFT" == "1" ]]; then
    log "EXFIL_SOFT=1 — not failing the job."
    exit 0
  fi
  exit 1
fi

log "Exfil surface check passed (no new hits; gates intact)."
log "Report: $REPORT"
exit 0
