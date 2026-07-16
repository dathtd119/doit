#!/usr/bin/env bash
# F-EXT-003 / VAL-EXT-003: scripted discovery-path verification for do proof
# agent + guided PreToolUse hook.
#
# Confirms proof assets sit on the **real** paths stock grok discovers:
#   agents: <project>/.do/agents/*.md
#           (crates/codegen/xai-grok-agent/src/discovery.rs — PROJECT_AGENT_SUBDIRS; .do/agents)
#   hooks:  <git-root>/.do/hooks/*.json
#           (crates/codegen/xai-grok-shell/src/util/hooks.rs — discover_hook_source_paths;
#            crates/codegen/xai-grok-hooks/src/discovery.rs — HookSource::Directory)
#
# Exit 0 only when all checks pass. Mocks alone are insufficient — this script
# checks real filesystem placement relative to the do repo root.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$HARNESS_DIR/.." && pwd)"

# Allow override for CI / alternate checkouts
REPO_ROOT="${DO_REPO_ROOT:-$REPO_ROOT}"

PASS=0
FAIL=0
WARN=0

ok() {
  PASS=$((PASS + 1))
  printf '  ok  %s\n' "$1"
}

fail() {
  FAIL=$((FAIL + 1))
  printf '  FAIL %s\n' "$1" >&2
}

warn() {
  WARN=$((WARN + 1))
  printf '  warn %s\n' "$1"
}

section() {
  printf '\n== %s ==\n' "$1"
}

# Resolve path if symlink; empty if missing
resolve() {
  local p="$1"
  if [[ -L "$p" ]]; then
    readlink -f "$p" 2>/dev/null || readlink "$p"
  elif [[ -e "$p" ]]; then
    printf '%s\n' "$(cd "$(dirname "$p")" && pwd)/$(basename "$p")"
  else
    printf ''
  fi
}

# ---------------------------------------------------------------------------
section "1. Source of truth (do-harness/)"
# ---------------------------------------------------------------------------

AGENT_SRC="$HARNESS_DIR/agents/intake.md"
HOOK_JSON_SRC="$HARNESS_DIR/hooks/guided-dangerous-shell.json"
HOOK_BIN_SRC="$HARNESS_DIR/hooks/bin/guided-dangerous-shell.py"

if [[ -f "$AGENT_SRC" ]]; then
  ok "do-harness/agents/intake.md exists"
else
  fail "missing $AGENT_SRC"
fi

if [[ -f "$HOOK_JSON_SRC" ]]; then
  ok "do-harness/hooks/guided-dangerous-shell.json exists"
else
  fail "missing $HOOK_JSON_SRC"
fi

if [[ -f "$HOOK_BIN_SRC" && -x "$HOOK_BIN_SRC" ]]; then
  ok "do-harness/hooks/bin/guided-dangerous-shell.py exists and is executable"
elif [[ -f "$HOOK_BIN_SRC" ]]; then
  warn "hook binary not executable (chmod +x recommended): $HOOK_BIN_SRC"
  ok "do-harness/hooks/bin/guided-dangerous-shell.py exists"
else
  fail "missing $HOOK_BIN_SRC"
fi

# ---------------------------------------------------------------------------
section "2. Project discovery path (product .do/ locations)"
# ---------------------------------------------------------------------------
# Agents: cwd→git-root walk of .do/agents (discovery.rs PROJECT_AGENT_SUBDIRS; .do/agents)
# Hooks:  <git_root>/.do/hooks (util/hooks.rs project.push(...join("hooks")))

AGENT_DISC="$REPO_ROOT/.do/agents/intake.md"
HOOK_JSON_DISC="$REPO_ROOT/.do/hooks/guided-dangerous-shell.json"
HOOK_BIN_DISC="$REPO_ROOT/.do/hooks/bin/guided-dangerous-shell.py"

if [[ -e "$AGENT_DISC" ]]; then
  ok "project agent on discovery path: .do/agents/intake.md"
  if [[ -L "$AGENT_DISC" ]]; then
    target="$(resolve "$AGENT_DISC")"
    expected="$(resolve "$AGENT_SRC")"
    if [[ -n "$target" && -n "$expected" && "$target" == "$expected" ]]; then
      ok "agent symlink resolves to do-harness source ($target)"
    else
      fail "agent symlink target mismatch: got='$target' expected='$expected'"
    fi
  else
    # Still valid if copied; warn so operators know SoT is do-harness
    warn "agent discovery path is not a symlink (prefer ln -s to do-harness)"
  fi
else
  fail "agent not on discovery path: $AGENT_DISC"
fi

if [[ -e "$HOOK_JSON_DISC" ]]; then
  ok "project hook JSON on discovery path: .do/hooks/guided-dangerous-shell.json"
  if [[ -L "$HOOK_JSON_DISC" ]]; then
    target="$(resolve "$HOOK_JSON_DISC")"
    expected="$(resolve "$HOOK_JSON_SRC")"
    if [[ -n "$target" && -n "$expected" && "$target" == "$expected" ]]; then
      ok "hook JSON symlink resolves to do-harness source"
    else
      fail "hook JSON symlink target mismatch: got='$target' expected='$expected'"
    fi
  else
    warn "hook JSON discovery path is not a symlink (prefer ln -s to do-harness)"
  fi
else
  fail "hook JSON not on discovery path: $HOOK_JSON_DISC"
fi

if [[ -e "$HOOK_BIN_DISC" ]]; then
  ok "hook command target on discovery path: .do/hooks/bin/guided-dangerous-shell.py"
else
  fail "hook command target missing: $HOOK_BIN_DISC (command is relative to source_dir)"
fi

# ---------------------------------------------------------------------------
section "3. Agent frontmatter shape (grok AgentDefinition contract)"
# ---------------------------------------------------------------------------

python3 - "$AGENT_SRC" <<'PY'
import re, sys, pathlib

path = pathlib.Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
if not text.lstrip().startswith("---"):
    print("  FAIL agent missing YAML frontmatter delimiters", file=sys.stderr)
    sys.exit(1)
parts = re.split(r"^---\s*$", text, maxsplit=2, flags=re.M)
if len(parts) < 3:
    print("  FAIL agent frontmatter not closed", file=sys.stderr)
    sys.exit(1)
yaml = parts[1]
# Minimal parse without requiring PyYAML: required keys as line patterns
checks = [
    (r"(?m)^name:\s*intake\s*$", "name: intake"),
    (r"(?m)^description:\s*", "description present"),
    (r"(?m)^permissionMode:\s*plan\s*$", "permissionMode: plan"),
    (r"(?m)^model:\s*", "model present"),
]
failed = []
for pat, label in checks:
    if not re.search(pat, yaml):
        failed.append(label)
body = parts[2].strip()
if not body:
    failed.append("non-empty prompt body")
if failed:
    print("  FAIL agent frontmatter:", ", ".join(failed), file=sys.stderr)
    sys.exit(1)
print("  ok  agent frontmatter: name=intake, permissionMode=plan, body non-empty")
sys.exit(0)
PY
ok "agent frontmatter parse checks passed"

# ---------------------------------------------------------------------------
section "4. Hook JSON shape (xai-grok-hooks parse_hook_file contract)"
# ---------------------------------------------------------------------------

python3 - "$HOOK_JSON_SRC" "$HOOK_BIN_DISC" <<'PY'
import json, sys, pathlib, re

path = pathlib.Path(sys.argv[1])
cmd_target = pathlib.Path(sys.argv[2])
data = json.loads(path.read_text(encoding="utf-8"))
if "hooks" not in data:
    print("  FAIL hook JSON missing top-level 'hooks' key", file=sys.stderr)
    sys.exit(1)
hooks = data["hooks"]
if "PreToolUse" not in hooks:
    print("  FAIL hook JSON missing PreToolUse event", file=sys.stderr)
    sys.exit(1)
groups = hooks["PreToolUse"]
if not isinstance(groups, list) or not groups:
    print("  FAIL PreToolUse has no matcher groups", file=sys.stderr)
    sys.exit(1)
found_command = False
matcher_ok = False
for g in groups:
    m = g.get("matcher") or ""
    if m and re.search(r"Bash|run_terminal|Shell|shell", m):
        matcher_ok = True
    for h in g.get("hooks") or []:
        if h.get("type") == "command" and h.get("command"):
            found_command = True
            cmd = h["command"]
            # Relative commands resolve against source_dir (.do/hooks/)
            if not pathlib.Path(cmd).is_absolute():
                # source_dir for project hooks is .do/hooks
                rel = pathlib.Path(cmd)
                # Accept bin/... as installed
                if "guided-dangerous-shell" not in str(cmd):
                    print(f"  FAIL unexpected command path: {cmd}", file=sys.stderr)
                    sys.exit(1)
if not found_command:
    print("  FAIL no type=command handler under PreToolUse", file=sys.stderr)
    sys.exit(1)
if not matcher_ok:
    print("  FAIL PreToolUse matcher does not target shell tools", file=sys.stderr)
    sys.exit(1)
if not cmd_target.exists():
    print(f"  FAIL command target not found at discovery path: {cmd_target}", file=sys.stderr)
    sys.exit(1)
print("  ok  hook JSON: PreToolUse + shell matcher + command handler; target exists")
sys.exit(0)
PY
ok "hook JSON parse checks passed"

# ---------------------------------------------------------------------------
section "5. Hook behavior self-test (guided deny)"
# ---------------------------------------------------------------------------

if python3 "$HOOK_BIN_SRC" --self-test; then
  ok "guided-dangerous-shell.py --self-test"
else
  fail "guided-dangerous-shell.py --self-test failed"
fi

# Deny path smoke (exit 2 = deny)
set +e
OUT="$(echo '{"toolInput":{"command":"pkill -9 node"}}' | python3 "$HOOK_BIN_SRC" 2>&1)"
EC=$?
set -e
if [[ "$EC" -eq 2 ]] && echo "$OUT" | grep -q '\[GATE:'; then
  ok "deny envelope: exit 2 + [GATE: …] for pkill"
else
  fail "deny envelope expected exit 2 + [GATE: …]; got exit=$EC out=$OUT"
fi

# Allow path smoke
set +e
OUT="$(echo '{"toolInput":{"command":"git status"}}' | python3 "$HOOK_BIN_SRC" 2>&1)"
EC=$?
set -e
if [[ "$EC" -eq 0 ]]; then
  ok "allow envelope: exit 0 for git status"
else
  fail "allow envelope expected exit 0; got exit=$EC out=$OUT"
fi

# ---------------------------------------------------------------------------
section "6. Discovery path evidence (forked source citations)"
# ---------------------------------------------------------------------------

AGENT_DISC_RS="$REPO_ROOT/crates/codegen/xai-grok-agent/src/discovery.rs"
HOOKS_UTIL_RS="$REPO_ROOT/crates/codegen/xai-grok-shell/src/util/hooks.rs"
HOOKS_DISC_RS="$REPO_ROOT/crates/codegen/xai-grok-hooks/src/discovery.rs"

if [[ -f "$AGENT_DISC_RS" ]] && grep -q '\.do/agents' "$AGENT_DISC_RS"; then
  ok "evidence: agent discovery uses .do/agents ($AGENT_DISC_RS)"
else
  fail "cannot find .do/agents in forked agent discovery.rs"
fi

if [[ -f "$HOOKS_UTIL_RS" ]] && grep -q 'join("hooks")' "$HOOKS_UTIL_RS"; then
  ok "evidence: project hooks path is <git_root>/.do/hooks ($HOOKS_UTIL_RS)"
else
  fail "cannot find project hooks path in util/hooks.rs"
fi

if [[ -f "$HOOKS_DISC_RS" ]] && grep -q 'HookSource::Directory' "$HOOKS_DISC_RS"; then
  ok "evidence: hooks load *.json from HookSource::Directory ($HOOKS_DISC_RS)"
else
  fail "cannot find HookSource::Directory in hooks discovery.rs"
fi

# ---------------------------------------------------------------------------
section "7. Optional: forked binary inspect (if built)"
# ---------------------------------------------------------------------------

BIN=""
for candidate in \
  "$REPO_ROOT/target/debug/grok" \
  "$REPO_ROOT/target/release/grok" \
  "$REPO_ROOT/target/debug/xai-grok-pager" \
  "$REPO_ROOT/target/release/xai-grok-pager"
do
  if [[ -x "$candidate" ]]; then
    BIN="$candidate"
    break
  fi
done

if [[ -n "$BIN" ]]; then
  # Prefer non-interactive inspect if present
  set +e
  HELP="$("$BIN" --help 2>&1)"
  set -e
  if echo "$HELP" | grep -qi inspect; then
    set +e
    INSPECT_OUT="$(cd "$REPO_ROOT" && "$BIN" inspect --json 2>&1)"
    IEC=$?
    set -e
    if [[ "$IEC" -eq 0 ]]; then
      if echo "$INSPECT_OUT" | grep -q 'intake'; then
        ok "binary inspect lists intake agent"
      else
        warn "binary inspect ran but 'intake' not found in output (trust/gate may hide project assets)"
      fi
      if echo "$INSPECT_OUT" | grep -qi 'guided-dangerous-shell\|PreToolUse'; then
        ok "binary inspect lists guided hook / PreToolUse"
      else
        warn "binary inspect ran but guided hook not obvious in output"
      fi
    else
      warn "binary inspect failed (exit $IEC) — path checks still authoritative for VAL-EXT-003(b)"
    fi
  else
    warn "binary present but no inspect subcommand in --help; skipping binary list"
  fi
else
  warn "no built grok/pager binary found — VAL-EXT-003(b) path check is the proof path"
fi

# ---------------------------------------------------------------------------
section "Summary"
# ---------------------------------------------------------------------------

printf '\npassed=%s failed=%s warnings=%s\n' "$PASS" "$FAIL" "$WARN"
printf 'repo_root=%s\n' "$REPO_ROOT"
printf 'agent_discovery=%s\n' "$AGENT_DISC"
printf 'hook_discovery=%s\n' "$HOOK_JSON_DISC"

if [[ "$FAIL" -gt 0 ]]; then
  printf '\nVAL-EXT-003: FAIL\n' >&2
  exit 1
fi

printf '\nVAL-EXT-003: PASS (scripted discovery path check exit 0)\n'
exit 0
