#!/usr/bin/env bash
# F-M2-SKILL / VAL-M2-SKILL-001: progressive/curated skill+MCP default (M2 advanced).
# Also covers residual M1 needles (VAL-M1-SKILL-001 policy start still holds).
#
# Checks:
#   1. Policy doc exists with M2 progressive/curated + firehose opt-in + MCP
#   2. do-harness/config.skills.yaml: progressive default, firehose opt-in,
#      all five roles discover false, MCP search_tool/use_tool
#   3. All five product agents: discoverSkills false (no firehose default)
#   4. Explorer/oracle expose MCP progressive tools (search_tool / use_tool)
#   5. prompt-system + README pointers
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
section "1. Policy documentation (M2 advanced)"
# ---------------------------------------------------------------------------

POLICY="$REPO_ROOT/docs/progressive-skills.md"
if [[ -f "$POLICY" ]]; then
  ok "docs/progressive-skills.md exists"
else
  fail "missing $POLICY"
fi

if [[ -f "$POLICY" ]]; then
  for needle in \
    "Progressive skill" \
    "discoverSkills" \
    "firehose" \
    "opt-in" \
    "ignore" \
    "SkillDiscoveryReminder" \
    "search_tool" \
    "use_tool" \
    "curated" \
    "VAL-M2-SKILL-001" \
    "VAL-M1-SKILL-001"
  do
    if grep -qF "$needle" "$POLICY"; then
      ok "policy mentions: $needle"
    else
      fail "policy missing mention: $needle"
    fi
  done
fi

PROMPT_SYS="$REPO_ROOT/docs/prompt-system.md"
if [[ -f "$PROMPT_SYS" ]] && grep -qE 'progressive-skills|Progressive skill' "$PROMPT_SYS"; then
  ok "docs/prompt-system.md links progressive skill policy"
else
  fail "docs/prompt-system.md should point at progressive skill policy"
fi

# ---------------------------------------------------------------------------
section "2. Config surface (do-harness/config.skills.yaml)"
# ---------------------------------------------------------------------------

CFG="$HARNESS_DIR/config.skills.yaml"
if [[ -f "$CFG" ]]; then
  ok "do-harness/config.skills.yaml exists"
else
  fail "missing $CFG"
fi

if [[ -f "$CFG" ]]; then
  if grep -qE 'default_mode:\s*progressive' "$CFG"; then
    ok "default_mode: progressive"
  else
    fail "config.skills.yaml must set presentation.default_mode: progressive"
  fi
  if grep -qE 'firehose_mode:\s*opt_in' "$CFG"; then
    ok "firehose_mode: opt_in"
  else
    fail "config.skills.yaml must set firehose_mode: opt_in"
  fi
  for role in intake explorer oracle orchestrator worker; do
    if grep -qE "^[[:space:]]*${role}:[[:space:]]*false" "$CFG"; then
      ok "role_discover_skills.${role}: false (in config)"
    else
      fail "config.skills.yaml must set role_discover_skills.${role}: false"
    fi
  done
  if grep -qE 'discovery:\s*search_tool' "$CFG" && grep -qE 'invoke:\s*use_tool' "$CFG"; then
    ok "mcp.discovery=search_tool and mcp.invoke=use_tool"
  else
    fail "config.skills.yaml must declare MCP search_tool / use_tool"
  fi
  if grep -qE 'policy:\s*progressive_search_then_use' "$CFG"; then
    ok "mcp.policy: progressive_search_then_use"
  else
    fail "config.skills.yaml must set mcp.policy: progressive_search_then_use"
  fi
fi

# ---------------------------------------------------------------------------
section "3. Product-wide progressive/curated agents (no firehose default)"
# ---------------------------------------------------------------------------

# M2: every roster role suppresses stock discoverSkills: true.
python3 - "$HARNESS_DIR/agents" <<'PY'
import re, sys, pathlib

agents_dir = pathlib.Path(sys.argv[1])
all_roles = ("intake", "explorer", "oracle", "orchestrator", "worker")
failed = []
reduced = 0

def frontmatter(path: pathlib.Path) -> str:
    text = path.read_text(encoding="utf-8")
    if not text.lstrip().startswith("---"):
        return ""
    parts = re.split(r"^---\s*$", text, maxsplit=2, flags=re.M)
    if len(parts) < 3:
        return ""
    return parts[1]

def discover_skills_value(yaml: str):
    m = re.search(r"(?m)^discoverSkills:\s*(true|false)\s*$", yaml)
    if m:
        return m.group(1)
    m = re.search(r"(?m)^discover_skills:\s*(true|false)\s*$", yaml)
    if m:
        return m.group(1)
    return None

for role in all_roles:
    path = agents_dir / f"{role}.md"
    if not path.is_file():
        failed.append(f"{role}: missing agent file")
        continue
    val = discover_skills_value(frontmatter(path))
    if val == "false":
        reduced += 1
        print(f"  ok  agents/{role}.md discoverSkills: false (progressive/curated)")
    else:
        failed.append(
            f"{role}: expected discoverSkills: false (got {val!r}) — "
            "M2 product default is progressive/curated; firehose is opt-in"
        )

if reduced != len(all_roles):
    failed.append(
        f"need all {len(all_roles)} roster agents with discoverSkills: false "
        f"(got {reduced})"
    )

if failed:
    for f in failed:
        print(f"  FAIL {f}", file=sys.stderr)
    sys.exit(1)
sys.exit(0)
PY

for role in intake explorer oracle orchestrator worker; do
  if grep -qE '^discoverSkills:\s*false\s*$' "$HARNESS_DIR/agents/${role}.md"; then
    ok "agent ${role} discoverSkills false (shell recheck)"
  else
    fail "agent ${role} missing discoverSkills: false"
  fi
done

# ---------------------------------------------------------------------------
section "4. MCP progressive tools on scout/analysis floors"
# ---------------------------------------------------------------------------

for role in explorer oracle; do
  path="$HARNESS_DIR/agents/${role}.md"
  if [[ -f "$path" ]] && grep -qE '^\s*-\s*search_tool\s*$' "$path" \
    && grep -qE '^\s*-\s*use_tool\s*$' "$path"; then
    ok "agents/${role}.md exposes search_tool and use_tool"
  else
    fail "agents/${role}.md must list search_tool and use_tool (MCP progressive)"
  fi
done

# ---------------------------------------------------------------------------
section "5. README enablement pointer"
# ---------------------------------------------------------------------------

README="$HARNESS_DIR/README.md"
if [[ -f "$README" ]] && grep -qE 'progressive-skills|config\.skills\.yaml|Progressive skill' "$README"; then
  ok "do-harness/README.md documents progressive skills"
else
  fail "do-harness/README.md must document progressive skills / config.skills.yaml"
fi
if [[ -f "$README" ]] && grep -qE 'search_tool|VAL-M2-SKILL|firehose' "$README"; then
  ok "do-harness/README.md documents M2 firehose opt-in / MCP progressive"
else
  fail "do-harness/README.md must mention M2 progressive/MCP (search_tool or VAL-M2-SKILL)"
fi

# ---------------------------------------------------------------------------
section "Summary"
# ---------------------------------------------------------------------------

printf '\nPASS=%s FAIL=%s\n' "$PASS" "$FAIL"
if [[ "$FAIL" -gt 0 ]]; then
  printf 'VAL-M2-SKILL-001: FAIL\n' >&2
  printf 'VAL-M1-SKILL-001 residual: FAIL\n' >&2
  exit 1
fi
printf 'VAL-M2-SKILL-001: PASS\n'
printf 'VAL-M1-SKILL-001 residual: PASS\n'
exit 0
