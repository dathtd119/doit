#!/usr/bin/env bash
# F-M3-HASH / VAL-M3-HASH-001: hashline opt-in / standard default policy.
#
# Checks:
#   1. Policy doc (docs/hashline.md) — standard default + hashline opt-in + rollback
#   2. Product toolset fragment defaults to standard; hashline knobs remain for opt-in
#   3. Worker prefers standard tools; orchestrator denies bulk edit
#   4. Media tools denied on all product roles (config.roles.toml)
#   5. Native GrokBuildHashline citations (opt-in path exists; no second grammar)
#   6. README + index + capability-map enablement language
#
# Exit 0 only when all checks pass.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$HARNESS_DIR/.." && pwd)"
REPO_ROOT="${DO_REPO_ROOT:-$REPO_ROOT}"

PASS=0
FAIL=0

ok() {
  PASS=$((PASS + 1))
  printf '  ok  %s\n' "$1"
}

fail() {
  FAIL=$((FAIL + 1))
  printf '  FAIL %s\n' "$1" >&2
}

section() {
  printf '\n== %s ==\n' "$1"
}

# ---------------------------------------------------------------------------
section "1. Policy documentation (standard default + hashline opt-in)"
# ---------------------------------------------------------------------------

DOC="$REPO_ROOT/docs/hashline.md"
if [[ -f "$DOC" ]]; then
  ok "docs/hashline.md exists"
else
  fail "missing $DOC"
fi

if [[ -f "$DOC" ]]; then
  for needle in \
    "VAL-M3-HASH-001" \
    "F-M3-HASH" \
    "file_toolset" \
    "hashline" \
    "standard" \
    "opt-in" \
    "Rollback" \
    "GrokBuildHashline" \
    "hashline_read" \
    "hashline_edit" \
    "hashline_grep" \
    "worker" \
    "orchestrator" \
    "grammar"
  do
    if grep -qiF "$needle" "$DOC"; then
      ok "policy mentions: $needle"
    else
      fail "policy missing mention: $needle"
    fi
  done
  if grep -qiE 'product default.*(is |=\s*")?standard|file_toolset\s*=\s*"standard"' "$DOC"; then
    ok "policy states standard as product default"
  else
    fail "policy must state product default is standard / file_toolset = \"standard\""
  fi
  # Must not claim hashline is still the product default.
  if grep -qiE 'product default.*hashline|hashline is (the )?product default|file_toolset = "hashline".*product default' "$DOC" \
    && ! grep -qiE 'opt-in|product default is \*\*standard\*\*|product default.*standard' "$DOC"; then
    fail "policy still claims hashline is product default without standard flip"
  else
    ok "policy does not assert hashline as sole product default"
  fi
fi

# ---------------------------------------------------------------------------
section "2. Product toolset fragment (default standard; hashline opt-in knobs)"
# ---------------------------------------------------------------------------

CFG="$HARNESS_DIR/config.toolset.toml"
if [[ -f "$CFG" ]]; then
  ok "do-harness/config.toolset.toml exists"
else
  fail "missing $CFG"
fi

if [[ -f "$CFG" ]]; then
  if grep -qE 'file_toolset\s*=\s*"standard"' "$CFG"; then
    ok 'config.toolset.toml sets file_toolset = "standard"'
  else
    fail 'config.toolset.toml must set file_toolset = "standard" as product default'
  fi
  # Only active (non-comment) assignment under [toolset] may set file_toolset.
  # Comments documenting opt-in may still mention file_toolset = "hashline".
  active_ft=$(awk '
    /^[[:space:]]*#/ { next }
    /^\[toolset\]/ { in_ts=1; next }
    /^\[/ { in_ts=0 }
    in_ts && /^[[:space:]]*file_toolset[[:space:]]*=/ {
      print; exit
    }
  ' "$CFG")
  if printf '%s' "$active_ft" | grep -qE 'file_toolset\s*=\s*"standard"'; then
    ok 'active [toolset] file_toolset is standard (not hashline)'
  elif printf '%s' "$active_ft" | grep -qE 'file_toolset\s*=\s*"hashline"'; then
    fail 'config.toolset.toml must not set active file_toolset = "hashline" as product default'
  else
    fail 'could not find active non-comment file_toolset under [toolset]'
  fi
  for needle in scheme hash_len chunk_size; do
    if grep -qE "${needle}\\s*=" "$CFG"; then
      ok "toolset.hashline opt-in knob present: $needle"
    else
      fail "config.toolset.toml missing hashline opt-in knob: $needle"
    fi
  done
  if grep -qiE 'opt-in|optional|Rollback to hashline|set file_toolset = "hashline"' "$CFG"; then
    ok "toolset fragment documents hashline opt-in path"
  else
    fail "toolset fragment should document hashline opt-in / rollback path"
  fi
  # Must not invent a second tool registry or grammar section name.
  if grep -qiE '^(grammar|dsl|custom_hashline)' "$CFG"; then
    fail "config.toolset.toml must not invent custom hashline grammar keys"
  else
    ok "no invented grammar keys in toolset fragment"
  fi
fi

# ---------------------------------------------------------------------------
section "3. Worker prefers standard tools; orchestrator denies bulk edit"
# ---------------------------------------------------------------------------

WORKER="$HARNESS_DIR/agents/worker.md"
ORCH="$HARNESS_DIR/agents/orchestrator.md"

if [[ -f "$WORKER" ]]; then
  ok "worker agent exists"
  for needle in read_file search_replace write grep; do
    if grep -qE "^[[:space:]]*-[[:space:]]*${needle}[[:space:]]*$" "$WORKER" \
      || grep -A40 '^tools:' "$WORKER" | grep -qE "^[[:space:]]*-[[:space:]]*${needle}[[:space:]]*$"; then
      ok "worker tools include: $needle"
    else
      # tools may be listed under tools: block
      if awk '/^tools:/{p=1;next} /^[a-zA-Z]/{p=0} p' "$WORKER" | grep -qE "^[[:space:]]*-[[:space:]]*${needle}[[:space:]]*$"; then
        ok "worker tools include: $needle"
      else
        fail "worker missing standard tool: $needle"
      fi
    fi
  done
  if grep -qiE 'prefer.*(search_replace|write)|standard file toolset|search_replace.*/.*write' "$WORKER"; then
    ok "worker states standard edit preference"
  else
    fail "worker body must prefer search_replace/write (standard toolset)"
  fi
  # Hashline must not be primary preference language.
  if grep -qiE 'prefer.*hashline|hashline.*(default|primary)|primary.*hashline' "$WORKER"; then
    fail "worker must not prefer hashline as primary (standard is default)"
  else
    ok "worker does not prefer hashline as primary"
  fi
else
  fail "missing $WORKER"
fi

if [[ -f "$ORCH" ]]; then
  ok "orchestrator agent exists"
  if grep -A40 'disallowedTools:' "$ORCH" | grep -qE '^[[:space:]]*-[[:space:]]*write[[:space:]]*$'; then
    ok "orchestrator disallows write"
  else
    fail "orchestrator must deny write (bulk edit floor)"
  fi
  if grep -A40 'disallowedTools:' "$ORCH" | grep -qE '^[[:space:]]*-[[:space:]]*search_replace[[:space:]]*$'; then
    ok "orchestrator disallows search_replace"
  else
    fail "orchestrator must deny search_replace (bulk edit floor)"
  fi
  # hashline_edit: if mentioned in deny list, fine; if absent, also fine under standard default
  # (hashline tools not in session when file_toolset=standard). Prefer explicit deny if present.
  if grep -A40 'disallowedTools:' "$ORCH" | grep -q 'hashline_edit'; then
    ok "orchestrator disallows hashline_edit (defense in depth)"
  else
    ok "orchestrator bulk-edit deny covers write/search_replace (hashline_edit N/A under standard default)"
  fi
else
  fail "missing $ORCH"
fi

# Non-worker roles: deny bulk edit (write / search_replace)
for role in intake explorer oracle; do
  f="$HARNESS_DIR/agents/${role}.md"
  if [[ ! -f "$f" ]]; then
    fail "missing $f"
    continue
  fi
  if grep -A40 'disallowedTools:' "$f" | grep -qE '^[[:space:]]*-[[:space:]]*write[[:space:]]*$' \
    && grep -A40 'disallowedTools:' "$f" | grep -qE '^[[:space:]]*-[[:space:]]*search_replace[[:space:]]*$'; then
    ok "$role disallows write + search_replace"
  else
    fail "$role must disallow write and search_replace"
  fi
done

# ---------------------------------------------------------------------------
section "4. Media tools denied on all product roles"
# ---------------------------------------------------------------------------

ROLES_CFG="$HARNESS_DIR/config.roles.toml"
if [[ -f "$ROLES_CFG" ]]; then
  ok "do-harness/config.roles.toml exists"
else
  fail "missing $ROLES_CFG"
fi

MEDIA_TOOLS=(image_gen image_edit image_to_video reference_to_video)
PRODUCT_ROLES=(intake orchestrator explorer worker oracle)

if [[ -f "$ROLES_CFG" ]]; then
  for role in "${PRODUCT_ROLES[@]}"; do
    # Extract disallowed_tools block for [roles.<role>] until next [roles. or EOF
    block=$(awk -v r="roles.${role}" '
      $0 ~ "^\\[" r "\\]" {p=1; next}
      p && $0 ~ /^\[roles\./ {exit}
      p {print}
    ' "$ROLES_CFG")
    if [[ -z "$block" ]]; then
      fail "config.roles.toml missing [roles.${role}]"
      continue
    fi
    for t in "${MEDIA_TOOLS[@]}"; do
      if printf '%s\n' "$block" | grep -qE "\"${t}\""; then
        ok "roles.${role} denies $t"
      else
        fail "roles.${role} must deny media tool: $t"
      fi
    done
  done
fi

# Agent frontmatter should also deny media (regenerated from roles SoT)
for role in "${PRODUCT_ROLES[@]}"; do
  f="$HARNESS_DIR/agents/${role}.md"
  [[ -f "$f" ]] || continue
  for t in image_gen image_edit; do
    if grep -A30 'disallowedTools:' "$f" | grep -qE "^[[:space:]]*-[[:space:]]*${t}[[:space:]]*$"; then
      ok "agents/${role}.md disallows $t"
    else
      fail "agents/${role}.md must disallow $t"
    fi
  done
done

# ---------------------------------------------------------------------------
section "5. Native namespace (opt-in path exists; no reinvent)"
# ---------------------------------------------------------------------------

NATIVE="$REPO_ROOT/docs/grok-build/native-tools.md"
if [[ -f "$NATIVE" ]] && grep -qF 'GrokBuildHashline' "$NATIVE" && grep -qF 'FileToolset' "$NATIVE"; then
  ok "native-tools.md documents GrokBuildHashline + FileToolset (opt-in path)"
else
  fail "docs/grok-build/native-tools.md should document GrokBuildHashline and FileToolset"
fi

# Prefer citing fork config if present; do not require crate edits for this policy.
CFG_RS="$REPO_ROOT/crates/codegen/xai-grok-shell/src/tools/config.rs"
if [[ -f "$CFG_RS" ]] \
  && grep -qF 'FileToolset' "$CFG_RS" \
  && grep -qF 'GrokBuildHashline' "$CFG_RS"
then
  ok "fork tools/config.rs owns FileToolset / GrokBuildHashline (native path)"
else
  # Extension-only policy: native docs + product overlay are enough if crate path missing in tree.
  if [[ -f "$NATIVE" ]] && grep -qF 'hashline_edit' "$NATIVE"; then
    ok "native docs cite hashline_edit (crate path optional in this check)"
  else
    fail "missing native FileToolset / GrokBuildHashline citations"
  fi
fi

# ---------------------------------------------------------------------------
section "6. README + index + capability-map (standard default language)"
# ---------------------------------------------------------------------------

README="$HARNESS_DIR/README.md"
if [[ -f "$README" ]] && grep -qE 'hashline|F-M3-HASH|VAL-M3-HASH|verify-hashline' "$README"; then
  ok "do-harness/README.md documents hashline / verify-hashline"
else
  fail "do-harness/README.md should document F-M3-HASH / verify-hashline"
fi

if [[ -f "$README" ]]; then
  if grep -qE 'file_toolset\s*=\s*"standard"|standard.*default|default.*standard' "$README"; then
    ok "README states standard file_toolset default"
  else
    fail "README must state file_toolset = \"standard\" as product default"
  fi
  # Stale: product default prefers hashline without flip language
  if grep -qiE 'Product \*\*default\*\* prefers native \*\*GrokBuildHashline\*\*|file_toolset = "hashline".*product default|defaults? to hashline' "$README" \
    && ! grep -qiE 'opt-in|standard.*default|default.*standard' "$README"; then
    fail "README still claims hashline as product default without standard flip"
  else
    ok "README hashline section aligned with standard default / opt-in"
  fi
fi

INDEX="$REPO_ROOT/docs/index.md"
if [[ -f "$INDEX" ]] && grep -qE 'hashline\.md|F-M3-HASH|VAL-M3-HASH' "$INDEX"; then
  ok "docs/index.md links hashline policy"
else
  fail "docs/index.md should link docs/hashline.md / F-M3-HASH"
fi

if [[ -f "$INDEX" ]]; then
  if grep -qiE 'hashline\.md.*standard|standard.*hashline|hashline.*opt-in|file_toolset = "standard"' "$INDEX"; then
    ok "docs/index.md hashline blurb reflects standard default / opt-in"
  else
    fail "docs/index.md hashline blurb must not claim hashline product default only"
  fi
fi

CAP="$REPO_ROOT/docs/capability-map.md"
if [[ -f "$CAP" ]] && grep -qiE 'hashline|FileToolset' "$CAP"; then
  ok "capability-map mentions hashline / FileToolset"
else
  fail "docs/capability-map.md should mention hashline product surface"
fi

if [[ -f "$CAP" ]]; then
  if grep -qiE 'opt-in|standard default|file_toolset = "standard"|Mapped \(opt-in\)|product default.*standard' "$CAP"; then
    ok "capability-map hashline row reflects standard default / opt-in"
  else
    fail "capability-map must not leave hashline as sole product default without flip note"
  fi
fi

# L1 worker fragment: standard preference language
L1="$HARNESS_DIR/prompts/roles/worker.md"
if [[ -f "$L1" ]]; then
  ok "L1 worker fragment exists"
  if grep -qiE 'search_replace|write|standard' "$L1"; then
    ok "L1 worker mentions standard edit tools"
  else
    fail "L1 worker fragment should mention standard edit tools"
  fi
  if grep -qiE 'prefer.*hashline|hashline.*primary' "$L1"; then
    fail "L1 worker must not prefer hashline as primary"
  else
    ok "L1 worker does not prefer hashline as primary"
  fi
else
  fail "missing $L1"
fi

# ---------------------------------------------------------------------------
section "Summary"
# ---------------------------------------------------------------------------

printf '\npassed=%s failed=%s\n' "$PASS" "$FAIL"
if [[ "$FAIL" -eq 0 ]]; then
  printf 'VAL-M3-HASH-001: PASS (standard default / hashline opt-in)\n'
  exit 0
fi
printf 'VAL-M3-HASH-001: FAIL\n' >&2
exit 1
