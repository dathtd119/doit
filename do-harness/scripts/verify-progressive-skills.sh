#!/usr/bin/env bash
# F-M1-SKILL / VAL-M1-SKILL-001: progressive skill policy start + reduced firehose.
#
# Checks:
#   1. Policy doc exists with required sections
#   2. do-harness/config.skills.yaml exists with progressive default + role table
#   3. Product agents apply reduced discoverSkills vs stock default (true)
#      for intake, explorer, oracle
#   4. prompt-system.md points at progressive skills policy
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
section "1. Policy documentation"
# ---------------------------------------------------------------------------

POLICY="$REPO_ROOT/docs/progressive-skills.md"
if [[ -f "$POLICY" ]]; then
  ok "docs/progressive-skills.md exists"
else
  fail "missing $POLICY"
fi

if [[ -f "$POLICY" ]]; then
  for needle in \
    "Progressive skill presentation" \
    "discoverSkills" \
    "firehose" \
    "ignore" \
    "SkillDiscoveryReminder" \
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
  for role in intake explorer oracle; do
    if grep -qE "^[[:space:]]*${role}:[[:space:]]*false" "$CFG"; then
      ok "role_discover_skills.${role}: false (in config)"
    else
      fail "config.skills.yaml must set role_discover_skills.${role}: false"
    fi
  done
fi

# ---------------------------------------------------------------------------
section "3. Reduced firehose on product agents (vs stock discoverSkills: true)"
# ---------------------------------------------------------------------------

# Stock default is discover_skills: true. At least three roster agents must
# suppress discovery — that is the M1 reduced surface.

python3 - "$HARNESS_DIR/agents" <<'PY'
import re, sys, pathlib

agents_dir = pathlib.Path(sys.argv[1])
# Roles that must reduce dump vs stock default
must_false = ("intake", "explorer", "oracle")
# Roles that may keep discovery (curated direction)
may_true = ("orchestrator", "worker")
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

def discover_skills_value(yaml: str) -> str | None:
    # Accept discoverSkills: false / true (camelCase agent frontmatter)
    m = re.search(r"(?m)^discoverSkills:\s*(true|false)\s*$", yaml)
    if m:
        return m.group(1)
    m = re.search(r"(?m)^discover_skills:\s*(true|false)\s*$", yaml)
    if m:
        return m.group(1)
    return None

for role in must_false:
    path = agents_dir / f"{role}.md"
    if not path.is_file():
        failed.append(f"{role}: missing agent file")
        continue
    val = discover_skills_value(frontmatter(path))
    if val == "false":
        reduced += 1
        print(f"  ok  agents/{role}.md discoverSkills: false")
    else:
        failed.append(
            f"{role}: expected discoverSkills: false (got {val!r}) — "
            "reduces firehose vs stock default true"
        )

for role in may_true:
    path = agents_dir / f"{role}.md"
    if not path.is_file():
        failed.append(f"{role}: missing agent file")
        continue
    val = discover_skills_value(frontmatter(path))
    if val is None:
        failed.append(f"{role}: missing discoverSkills field")
    else:
        print(f"  ok  agents/{role}.md discoverSkills: {val} (curated/firehose-capable)")

if reduced < 1:
    failed.append("need at least one agent with discoverSkills: false")

if failed:
    for f in failed:
        print(f"  FAIL {f}", file=sys.stderr)
    sys.exit(1)
sys.exit(0)
PY
# Count ok lines from python for PASS tally (script already printed)
# Re-run lightweight count for shell PASS/FAIL aggregation
for role in intake explorer oracle; do
  if grep -qE '^discoverSkills:\s*false\s*$' "$HARNESS_DIR/agents/${role}.md"; then
    ok "agent ${role} discoverSkills false (shell recheck)"
  else
    fail "agent ${role} missing discoverSkills: false"
  fi
done

# ---------------------------------------------------------------------------
section "4. README enablement pointer"
# ---------------------------------------------------------------------------

README="$HARNESS_DIR/README.md"
if [[ -f "$README" ]] && grep -qE 'progressive-skills|config\.skills\.yaml|Progressive skill' "$README"; then
  ok "do-harness/README.md documents progressive skills"
else
  fail "do-harness/README.md must document progressive skills / config.skills.yaml"
fi

# ---------------------------------------------------------------------------
section "Summary"
# ---------------------------------------------------------------------------

printf '\nPASS=%s FAIL=%s\n' "$PASS" "$FAIL"
if [[ "$FAIL" -gt 0 ]]; then
  printf 'VAL-M1-SKILL-001: FAIL\n' >&2
  exit 1
fi
printf 'VAL-M1-SKILL-001: PASS\n'
exit 0
