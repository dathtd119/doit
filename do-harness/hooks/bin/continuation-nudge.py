#!/usr/bin/env python3
"""PostToolUse continuation priority engine + anti-thrash nudges.

F-M2-CONT / VAL-M2-CONT-001. Product identity under do-harness/; install onto
project .doit/hooks or ~/.config/doit/hooks for discovery.

Protocol (xai-grok-hooks command runner):
  - stdin: hook envelope JSON (PostToolUse continuum tools)
  - PostToolUse is passive in the runner (stdout may be ignored by UI);
    this engine still records session state and returns compact JSON for
    scripted fixtures and future inject seams.
  - exit 0 always (fail-open; never blocks tools)

Env:
  DO_CONTINUATION_NUDGE=0     disable entirely
  DO_CONTINUATION_STATE_DIR   override state directory
  DO_CONTINUATION_COOLDOWN    seconds (default 45)
  DO_CONTINUATION_MAX_STREAK  no-progress threshold (default 3)
  DO_CONTINUATION_MAX_NUDGES  per state file (default 12)
  DO_CONTINUATION_NOW         override unix time (tests)

Self-test:  continuation-nudge.py --self-test
Fixture:    continuation-nudge.py --fixture <path.json>
"""

from __future__ import annotations

import hashlib
import json
import os
import re
import sys
import time
from pathlib import Path
from typing import Any

LANE_ORDER = ("interrupt", "streak", "goal", "plan", "workflow", "todo")

CONTINUUM_TOOL_RE = re.compile(
    r"^(update_goal|todo_write|TodoWrite|enter_plan_mode|exit_plan_mode|"
    r"task|spawn_subagent|Agent|agent)$",
    re.IGNORECASE,
)

PREFIX = {
    "interrupt": "Continue lane: interrupt",
    "streak": "Continue lane: streak",
    "goal": "Continue lane: goal",
    "plan": "Continue lane: plan",
    "workflow": "Continue lane: workflow",
    "todo": "Continue lane: todo",
}

DEFAULT_COOLDOWN = 45.0
DEFAULT_MAX_STREAK = 3
DEFAULT_MAX_NUDGES = 12


def _now() -> float:
    raw = os.environ.get("DO_CONTINUATION_NOW")
    if raw is not None and raw.strip():
        return float(raw)
    return time.time()


def _cooldown() -> float:
    raw = os.environ.get("DO_CONTINUATION_COOLDOWN", str(DEFAULT_COOLDOWN))
    try:
        return float(raw)
    except ValueError:
        return DEFAULT_COOLDOWN


def _max_streak() -> int:
    raw = os.environ.get("DO_CONTINUATION_MAX_STREAK", str(DEFAULT_MAX_STREAK))
    try:
        return max(1, int(raw))
    except ValueError:
        return DEFAULT_MAX_STREAK


def _max_nudges() -> int:
    raw = os.environ.get("DO_CONTINUATION_MAX_NUDGES", str(DEFAULT_MAX_NUDGES))
    try:
        return max(1, int(raw))
    except ValueError:
        return DEFAULT_MAX_NUDGES


def _disabled() -> bool:
    return os.environ.get("DO_CONTINUATION_NUDGE", "1").strip() in ("0", "false", "off")


def state_dir(envelope: dict[str, Any] | None = None) -> Path:
    override = os.environ.get("DO_CONTINUATION_STATE_DIR")
    if override:
        path = Path(override)
        path.mkdir(parents=True, exist_ok=True)
        return path

    env = envelope or {}
    session = (
        env.get("sessionId")
        or env.get("session_id")
        or os.environ.get("GROK_SESSION_ID")
        or "default"
    )
    cwd = (
        env.get("cwd")
        or env.get("workspaceRoot")
        or os.environ.get("GROK_WORKSPACE_ROOT")
        or os.getcwd()
    )
    root = Path(str(cwd)) / ".doit" / "continuation"
    root.mkdir(parents=True, exist_ok=True)
    # Keep session files under gitignore-friendly path; never dual-write continuum.
    safe = re.sub(r"[^a-zA-Z0-9._-]+", "_", str(session))[:80] or "default"
    path = root / safe
    path.mkdir(parents=True, exist_ok=True)
    return path


def state_path(envelope: dict[str, Any] | None = None) -> Path:
    return state_dir(envelope) / "state.json"


def load_state(path: Path) -> dict[str, Any]:
    if not path.is_file():
        return default_state()
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return default_state()
    if not isinstance(data, dict):
        return default_state()
    base = default_state()
    base.update(data)
    return base


def default_state() -> dict[str, Any]:
    return {
        "version": 1,
        "interrupted": False,
        "no_progress_streak": 0,
        "goal_active": False,
        "goal_focus": "",
        "plan_open": False,
        "plan_focus": "",
        "workflow_open": False,
        "workflow_focus": "",
        "todo_open": False,
        "todo_focus": "",
        "nudge_count": 0,
        "last_nudge_lane": None,
        "last_nudge_fingerprint": None,
        "last_nudge_at": 0.0,
        "last_nudge_text": None,
        "quiet": False,
        "last_tool": None,
        "last_tool_fingerprint": None,
        "history": [],
    }


def save_state(path: Path, state: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(".tmp")
    tmp.write_text(json.dumps(state, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    tmp.replace(path)


def _tool_name(envelope: dict[str, Any]) -> str:
    for key in ("toolName", "tool_name", "name"):
        val = envelope.get(key)
        if isinstance(val, str) and val.strip():
            return val.strip()
    return ""


def _tool_input(envelope: dict[str, Any]) -> dict[str, Any]:
    for key in ("toolInput", "tool_input", "input"):
        val = envelope.get(key)
        if isinstance(val, dict):
            return val
    return {}


def _tool_result(envelope: dict[str, Any]) -> Any:
    for key in ("toolResult", "tool_result", "result", "output"):
        if key in envelope:
            return envelope[key]
    return None


def fingerprint_payload(parts: list[str]) -> str:
    raw = "|".join(parts)
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()[:16]


def parse_bool(value: Any) -> bool | None:
    if isinstance(value, bool):
        return value
    if isinstance(value, (int, float)):
        return bool(value)
    if isinstance(value, str):
        v = value.strip().lower()
        if v in ("1", "true", "yes", "active", "open", "pending", "in_progress"):
            return True
        if v in ("0", "false", "no", "completed", "cancelled", "closed", "done"):
            return False
    return None


def extract_goal_flags(tool_input: dict[str, Any], result: Any) -> tuple[bool | None, str]:
    focus = ""
    for key in ("objective", "goal", "text", "title", "description"):
        val = tool_input.get(key)
        if isinstance(val, str) and val.strip():
            focus = val.strip()[:120]
            break
    status = tool_input.get("status") or tool_input.get("state")
    if isinstance(result, dict):
        status = result.get("status", status)
        for key in ("objective", "goal", "text"):
            if not focus and isinstance(result.get(key), str):
                focus = str(result[key]).strip()[:120]
    if isinstance(status, str):
        s = status.lower()
        if s in ("completed", "complete", "done", "cancelled", "canceled", "closed"):
            return False, focus
        if s in ("active", "in_progress", "open", "blocked"):
            return True, focus
    # Calling update_goal without a terminal status implies an active goal.
    if tool_input:
        return True, focus
    return None, focus


def extract_todo_flags(tool_input: dict[str, Any], result: Any) -> tuple[bool | None, str, bool]:
    """Return (todo_open, focus, made_progress)."""
    todos: list[Any] = []
    for key in ("todos", "items", "list"):
        val = tool_input.get(key)
        if isinstance(val, list):
            todos = val
            break
    if not todos and isinstance(result, dict):
        for key in ("todos", "items"):
            val = result.get(key)
            if isinstance(val, list):
                todos = val
                break

    open_items: list[str] = []
    completed = 0
    in_progress = ""
    for item in todos:
        if isinstance(item, str):
            open_items.append(item[:100])
            continue
        if not isinstance(item, dict):
            continue
        content = str(item.get("content") or item.get("text") or item.get("title") or "").strip()
        status = str(item.get("status") or "pending").lower()
        if status in ("completed", "complete", "done", "cancelled", "canceled"):
            completed += 1
            continue
        if status in ("pending", "in_progress", "in-progress", "active", "open"):
            open_items.append(content or "(untitled)")
            if status in ("in_progress", "in-progress", "active") and not in_progress:
                in_progress = content
    focus = in_progress or (open_items[0] if open_items else "")
    # Progress signal: merge carried previous count externally; here only completed presence.
    made_progress = completed > 0 and bool(open_items or completed)
    if todos:
        return bool(open_items), focus[:120], made_progress
    # todo_write called with empty/unknown shape → leave flags unchanged
    return None, focus[:120], False


def extract_plan_flags(
    tool_name: str, tool_input: dict[str, Any], envelope: dict[str, Any]
) -> tuple[bool | None, str]:
    name = tool_name.lower()
    if name == "enter_plan_mode":
        return True, "plan mode"
    if name == "exit_plan_mode":
        return False, ""
    # Prefer disk presence of .doit/plan.md when cwd known
    cwd = envelope.get("cwd") or envelope.get("workspaceRoot") or os.getcwd()
    plan = Path(str(cwd)) / ".doit" / "plan.md"
    if plan.is_file():
        try:
            text = plan.read_text(encoding="utf-8", errors="replace")
        except OSError:
            return True, "plan.md"
        # Closed markers
        if re.search(r"(?im)^(status:\s*)?(done|completed|closed)\b", text):
            return False, "plan.md"
        # Open if any unchecked markdown tasks or missing status closed
        if re.search(r"(?m)^\s*[-*]\s+\[\s\]\s+", text) or "status: open" in text.lower():
            title = ""
            for line in text.splitlines()[:20]:
                if line.startswith("#"):
                    title = line.lstrip("#").strip()[:100]
                    break
            return True, title or "plan.md"
        # Non-empty plan without closed status counts as open work pointer
        if text.strip():
            return True, "plan.md"
        return False, ""
    return None, ""


def extract_workflow_flags(tool_input: dict[str, Any], result: Any) -> tuple[bool | None, str]:
    for source in (tool_input, result if isinstance(result, dict) else {}):
        if not isinstance(source, dict):
            continue
        wf = source.get("workflow") or source.get("active_workflow") or source.get("method")
        if isinstance(wf, str) and wf.strip():
            return True, wf.strip()[:120]
        if isinstance(wf, dict):
            name = str(wf.get("name") or wf.get("id") or "").strip()
            status = str(wf.get("status") or "active").lower()
            if status in ("completed", "done", "closed", "cancelled"):
                return False, name
            if name:
                return True, name[:120]
    return None, ""


def select_lane(state: dict[str, Any]) -> str | None:
    if state.get("interrupted"):
        return "interrupt"
    if int(state.get("no_progress_streak") or 0) >= _max_streak() and (
        state.get("todo_open") or state.get("plan_open") or state.get("goal_active")
    ):
        return "streak"
    if state.get("goal_active"):
        return "goal"
    if state.get("plan_open"):
        return "plan"
    if state.get("workflow_open"):
        return "workflow"
    if state.get("todo_open"):
        return "todo"
    return None


def focus_for_lane(state: dict[str, Any], lane: str) -> str:
    mapping = {
        "interrupt": "resume after cancel",
        "streak": f"no progress streak={state.get('no_progress_streak', 0)}",
        "goal": state.get("goal_focus") or "active goal",
        "plan": state.get("plan_focus") or ".doit/plan.md",
        "workflow": state.get("workflow_focus") or "active workflow",
        "todo": state.get("todo_focus") or "open todo",
    }
    return str(mapping.get(lane, lane))[:120]


def build_nudge(lane: str, focus: str) -> str:
    base = PREFIX[lane]
    extras = {
        "interrupt": (
            f"{base} — re-orient after cancel; re-read update_goal and .doit/plan.md "
            f"before new edits. Focus: {focus}."
        ),
        "streak": (
            f"{base} — no continuum progress for several turns. Re-plan, mark blocked, "
            f"or ask the human; do not spin the same path. ({focus})"
        ),
        "goal": (
            f"{base} — re-read update_goal; take one step that advances or completes "
            f"the goal. Focus: {focus}."
        ),
        "plan": (
            f"{base} — re-read .doit/plan.md; finish the current phase before expanding "
            f"scope. Focus: {focus}."
        ),
        "workflow": (
            f"{base} — continue the active method/skill phase; update todos when the "
            f"step completes. Focus: {focus}."
        ),
        "todo": (
            f"{base} — work the in_progress item and mark it completed with "
            f"todo_write when done. Focus: {focus}."
        ),
    }
    text = extras[lane]
    # Hard length guard: never dump full continuum
    if len(text) > 320:
        text = text[:317] + "..."
    return text


def should_suppress(state: dict[str, Any], lane: str, fingerprint: str, now: float) -> str | None:
    if state.get("quiet"):
        return "quiet"
    if int(state.get("nudge_count") or 0) >= _max_nudges():
        return "max_nudges"
    last_fp = state.get("last_nudge_fingerprint")
    last_at = float(state.get("last_nudge_at") or 0)
    last_lane = state.get("last_nudge_lane")
    if last_fp == fingerprint and last_lane == lane and (now - last_at) < _cooldown():
        return "cooldown"
    return None


def apply_tool_event(state: dict[str, Any], envelope: dict[str, Any]) -> dict[str, Any]:
    """Mutate state from a continuum tool event. Returns event meta."""
    tool = _tool_name(envelope)
    tool_input = _tool_input(envelope)
    result = _tool_result(envelope)
    event: dict[str, Any] = {"tool": tool, "progress": False}

    # Interrupt flag may be injected by fixtures / future cancel wire.
    if envelope.get("interrupted") is True or tool_input.get("interrupted") is True:
        state["interrupted"] = True
    if tool_input.get("clear_interrupt") is True or envelope.get("clear_interrupt") is True:
        state["interrupted"] = False

    tnorm = tool.lower()
    if tnorm == "update_goal":
        active, focus = extract_goal_flags(tool_input, result)
        if active is not None:
            prev = bool(state.get("goal_active"))
            state["goal_active"] = active
            if focus:
                state["goal_focus"] = focus
            if prev and not active:
                event["progress"] = True
                state["interrupted"] = False
    elif tnorm in ("todo_write", "todowrite"):
        open_flag, focus, progressish = extract_todo_flags(tool_input, result)
        if open_flag is not None:
            prev_focus = state.get("todo_focus")
            state["todo_open"] = open_flag
            if focus:
                state["todo_focus"] = focus
            # Progress: completed items present, or focus advanced while open.
            if progressish or (prev_focus and focus and prev_focus != focus):
                event["progress"] = True
            if not open_flag:
                event["progress"] = True
    elif tnorm in ("enter_plan_mode", "exit_plan_mode"):
        open_flag, focus = extract_plan_flags(tool, tool_input, envelope)
        if open_flag is not None:
            prev = bool(state.get("plan_open"))
            state["plan_open"] = open_flag
            state["plan_focus"] = focus
            if prev and not open_flag:
                event["progress"] = True
    elif tnorm in ("task", "spawn_subagent", "agent"):
        # Support activity: optional workflow marker; does not invent goal.
        wf_open, wf_focus = extract_workflow_flags(tool_input, result)
        if wf_open is not None:
            state["workflow_open"] = wf_open
            if wf_focus:
                state["workflow_focus"] = wf_focus
        # Disk plan may still open independently
        plan_open, plan_focus = extract_plan_flags("plan_probe", tool_input, envelope)
        if plan_open is not None:
            state["plan_open"] = plan_open
            if plan_focus:
                state["plan_focus"] = plan_focus
    else:
        # Non-matched tools can still refresh plan-from-disk if cwd present
        plan_open, plan_focus = extract_plan_flags(tool or "probe", tool_input, envelope)
        if plan_open is not None:
            state["plan_open"] = plan_open
            if plan_focus:
                state["plan_focus"] = plan_focus

    # Explicit flags from fixtures / richer envelopes
    for key, dest in (
        ("goal_active", "goal_active"),
        ("plan_open", "plan_open"),
        ("workflow_open", "workflow_open"),
        ("todo_open", "todo_open"),
    ):
        if key in envelope and isinstance(envelope[key], bool):
            state[dest] = envelope[key]
    for key, dest in (
        ("goal_focus", "goal_focus"),
        ("plan_focus", "plan_focus"),
        ("workflow_focus", "workflow_focus"),
        ("todo_focus", "todo_focus"),
    ):
        if isinstance(envelope.get(key), str) and envelope[key].strip():
            state[dest] = envelope[key].strip()[:120]
    if "no_progress_streak" in envelope:
        try:
            state["no_progress_streak"] = int(envelope["no_progress_streak"])
        except (TypeError, ValueError):
            pass
    if envelope.get("made_progress") is True:
        event["progress"] = True

    tool_fp = fingerprint_payload(
        [tool, json.dumps(tool_input, sort_keys=True, default=str)[:500]]
    )
    event["tool_fingerprint"] = tool_fp
    state["last_tool"] = tool
    state["last_tool_fingerprint"] = tool_fp
    return event


def maybe_nudge(state: dict[str, Any], event: dict[str, Any], now: float | None = None) -> dict[str, Any]:
    """Select lane and apply thrash rules. Updates state in place.

    Streak counts *emitted* continue-without-progress nudges (pi-ness settle
    semantics), not every continuum tool event — otherwise thrash cooldown is
    drowned by a premature streak lane.
    """
    now = _now() if now is None else now
    if event.get("progress"):
        state["no_progress_streak"] = 0
        state["quiet"] = False

    lane = select_lane(state)
    out: dict[str, Any] = {
        "lane": lane,
        "nudge": None,
        "suppressed": None,
        "fingerprint": None,
    }
    if not lane:
        return out

    focus = focus_for_lane(state, lane)
    fp = fingerprint_payload([lane, focus])
    out["fingerprint"] = fp
    reason = should_suppress(state, lane, fp, now)
    if reason:
        out["suppressed"] = reason
        return out

    text = build_nudge(lane, focus)
    state["last_nudge_lane"] = lane
    state["last_nudge_fingerprint"] = fp
    state["last_nudge_at"] = now
    state["last_nudge_text"] = text
    state["nudge_count"] = int(state.get("nudge_count") or 0) + 1
    if state["nudge_count"] >= _max_nudges():
        state["quiet"] = True
    # Consuming interrupt after one nudge so resume path can fall through next turn
    if lane == "interrupt":
        state["interrupted"] = False
    # Increment no-progress streak only when a nudge actually fires without progress
    if not event.get("progress") and lane != "streak":
        if state.get("todo_open") or state.get("plan_open") or state.get("goal_active"):
            state["no_progress_streak"] = int(state.get("no_progress_streak") or 0) + 1
    hist = state.setdefault("history", [])
    if isinstance(hist, list):
        hist.append({"t": now, "lane": lane, "fp": fp, "suppressed": None})
        if len(hist) > 40:
            del hist[:-40]
    out["nudge"] = text
    return out


def process_envelope(envelope: dict[str, Any], *, persist: bool = True) -> dict[str, Any]:
    if _disabled():
        return {"ok": True, "disabled": True, "lane": None, "nudge": None, "suppressed": "disabled"}

    path = state_path(envelope)
    state = load_state(path)
    event = apply_tool_event(state, envelope)
    result = maybe_nudge(state, event)
    if persist:
        save_state(path, state)
    return {
        "ok": True,
        "disabled": False,
        "state_path": str(path),
        "tool": event.get("tool"),
        "progress": bool(event.get("progress")),
        "lane": result.get("lane"),
        "nudge": result.get("nudge"),
        "suppressed": result.get("suppressed"),
        "fingerprint": result.get("fingerprint"),
        "nudge_count": state.get("nudge_count"),
        "no_progress_streak": state.get("no_progress_streak"),
        "quiet": state.get("quiet"),
        "state_snapshot": {
            "interrupted": state.get("interrupted"),
            "goal_active": state.get("goal_active"),
            "plan_open": state.get("plan_open"),
            "workflow_open": state.get("workflow_open"),
            "todo_open": state.get("todo_open"),
            "goal_focus": state.get("goal_focus"),
            "todo_focus": state.get("todo_focus"),
        },
    }


def run_fixture(path: Path) -> int:
    """Multi-step fixture: list of envelopes, assert expected outcomes."""
    data = json.loads(path.read_text(encoding="utf-8"))
    steps = data.get("steps") if isinstance(data, dict) else data
    if not isinstance(steps, list):
        print("fixture must be a list of steps or {steps: [...]}", file=sys.stderr)
        return 1

    # Isolated state for fixture
    import tempfile

    failures: list[str] = []
    with tempfile.TemporaryDirectory(prefix="do-cont-") as tmp:
        os.environ["DO_CONTINUATION_STATE_DIR"] = tmp
        # Deterministic time base
        base_t = 1_700_000_000.0
        for i, step in enumerate(steps):
            if not isinstance(step, dict):
                failures.append(f"step {i}: not an object")
                continue
            env = step.get("envelope") or step.get("input") or {}
            if not isinstance(env, dict):
                failures.append(f"step {i}: envelope must be object")
                continue
            t_off = float(step.get("t", i * 10))
            os.environ["DO_CONTINUATION_NOW"] = str(base_t + t_off)
            if "cooldown" in step:
                os.environ["DO_CONTINUATION_COOLDOWN"] = str(step["cooldown"])
            if "max_streak" in step:
                os.environ["DO_CONTINUATION_MAX_STREAK"] = str(step["max_streak"])
            if "max_nudges" in step:
                os.environ["DO_CONTINUATION_MAX_NUDGES"] = str(step["max_nudges"])
            # Optional wipe
            if step.get("reset_state"):
                for child in Path(tmp).iterdir():
                    if child.is_file():
                        child.unlink()
            out = process_envelope(env, persist=True)
            expect = step.get("expect") or {}
            if "lane" in expect and out.get("lane") != expect["lane"]:
                failures.append(
                    f"step {i}: lane want={expect['lane']!r} got={out.get('lane')!r} full={out}"
                )
            if "suppressed" in expect and out.get("suppressed") != expect["suppressed"]:
                failures.append(
                    f"step {i}: suppressed want={expect['suppressed']!r} got={out.get('suppressed')!r}"
                )
            if expect.get("has_nudge") is True and not out.get("nudge"):
                failures.append(f"step {i}: expected nudge text")
            if expect.get("has_nudge") is False and out.get("nudge"):
                failures.append(f"step {i}: expected no nudge, got {out.get('nudge')!r}")
            if "nudge_contains" in expect:
                needle = expect["nudge_contains"]
                text = out.get("nudge") or ""
                if needle not in text:
                    failures.append(f"step {i}: nudge missing {needle!r}: {text!r}")
            if expect.get("nudge_max_len") is not None:
                text = out.get("nudge") or ""
                if len(text) > int(expect["nudge_max_len"]):
                    failures.append(
                        f"step {i}: nudge too long {len(text)} > {expect['nudge_max_len']}"
                    )
            if "streak" in expect and int(out.get("no_progress_streak") or 0) != int(
                expect["streak"]
            ):
                failures.append(
                    f"step {i}: streak want={expect['streak']} got={out.get('no_progress_streak')}"
                )

    if failures:
        for f in failures:
            print(f"FAIL: {f}", file=sys.stderr)
        print(f"{len(failures)} failure(s) in {path}", file=sys.stderr)
        return 1
    print(f"ok: fixture passed ({path.name}, {len(steps)} steps)")
    return 0


def self_test() -> int:
    import tempfile

    failures: list[str] = []

    def check(cond: bool, msg: str) -> None:
        if not cond:
            failures.append(msg)

    # Unit: priority order without thrash
    st = default_state()
    st.update(
        {
            "interrupted": True,
            "goal_active": True,
            "todo_open": True,
            "plan_open": True,
        }
    )
    check(select_lane(st) == "interrupt", "interrupt wins over goal/plan/todo")
    st["interrupted"] = False
    st["no_progress_streak"] = _max_streak()
    check(select_lane(st) == "streak", "streak before goal")
    st["no_progress_streak"] = 0
    check(select_lane(st) == "goal", "goal before plan")
    st["goal_active"] = False
    check(select_lane(st) == "plan", "plan before todo")
    st["plan_open"] = False
    st["workflow_open"] = True
    check(select_lane(st) == "workflow", "workflow before todo")
    st["workflow_open"] = False
    check(select_lane(st) == "todo", "todo last")
    st["todo_open"] = False
    check(select_lane(st) is None, "idle none")

    # Nudge length bound
    text = build_nudge("goal", "x" * 200)
    check(len(text) <= 320, f"nudge too long: {len(text)}")
    check(text.startswith(PREFIX["goal"]), "goal prefix")

    # Integration thrash path in temp state
    with tempfile.TemporaryDirectory(prefix="do-cont-self-") as tmp:
        os.environ["DO_CONTINUATION_STATE_DIR"] = tmp
        os.environ["DO_CONTINUATION_COOLDOWN"] = "100"
        os.environ["DO_CONTINUATION_MAX_STREAK"] = "3"
        os.environ["DO_CONTINUATION_MAX_NUDGES"] = "12"
        os.environ["DO_CONTINUATION_NOW"] = "1000"
        env1 = {
            "toolName": "update_goal",
            "toolInput": {"objective": "Ship continuation", "status": "active"},
            "sessionId": "self",
            "cwd": tmp,
        }
        r1 = process_envelope(env1)
        check(r1.get("lane") == "goal", f"first lane goal, got {r1}")
        check(bool(r1.get("nudge")), "first nudge emitted")
        os.environ["DO_CONTINUATION_NOW"] = "1010"  # within cooldown
        r2 = process_envelope(env1)
        check(r2.get("suppressed") == "cooldown", f"second suppressed: {r2}")
        check(r2.get("nudge") is None, "no thrash nudge")
        os.environ["DO_CONTINUATION_NOW"] = "1200"  # after cooldown
        r3 = process_envelope(env1)
        check(r3.get("nudge") is not None, "after cooldown may re-emit")

        # Progress event clears streak; goal must beat open todo
        os.environ["DO_CONTINUATION_NOW"] = "2000"
        process_envelope(
            {
                "toolName": "todo_write",
                "toolInput": {
                    "todos": [
                        {"content": "lower priority", "status": "pending"},
                    ]
                },
                "made_progress": True,
                "sessionId": "self",
                "cwd": tmp,
            }
        )
        os.environ["DO_CONTINUATION_NOW"] = "2100"
        r4 = process_envelope(
            {
                "toolName": "update_goal",
                "toolInput": {"objective": "Ship continuation", "status": "active"},
                "made_progress": True,
                "sessionId": "self",
                "cwd": tmp,
            }
        )
        check(r4.get("lane") == "goal", f"goal still beats todo: {r4}")
        check(
            int(r4.get("no_progress_streak") or 0) == 0,
            f"progress must clear streak: {r4}",
        )

        # Complete goal → todo
        os.environ["DO_CONTINUATION_NOW"] = "2200"
        r5 = process_envelope(
            {
                "toolName": "update_goal",
                "toolInput": {"objective": "Ship continuation", "status": "completed"},
                "sessionId": "self",
                "cwd": tmp,
                "todo_open": True,
                "todo_focus": "lower priority",
                "made_progress": True,
            }
        )
        check(r5.get("lane") == "todo", f"after goal done expect todo: {r5}")

    if failures:
        for f in failures:
            print(f"FAIL: {f}", file=sys.stderr)
        print(f"{len(failures)} self-test failure(s)", file=sys.stderr)
        return 1
    print("ok: continuation-nudge self-test passed")
    return 0


def main(argv: list[str] | None = None) -> int:
    argv = list(sys.argv[1:] if argv is None else argv)
    if argv and argv[0] == "--self-test":
        return self_test()
    if argv and argv[0] == "--fixture":
        if len(argv) < 2:
            print("usage: continuation-nudge.py --fixture <path>", file=sys.stderr)
            return 2
        return run_fixture(Path(argv[1]))
    if argv and argv[0] in ("-h", "--help"):
        print(__doc__)
        return 0

    try:
        raw = sys.stdin.read()
        envelope = json.loads(raw) if raw.strip() else {}
        if not isinstance(envelope, dict):
            envelope = {}
    except json.JSONDecodeError:
        # Fail-open
        print(json.dumps({"ok": True, "suppressed": "bad_json"}))
        return 0

    tool = _tool_name(envelope)
    if tool and not CONTINUUM_TOOL_RE.match(tool):
        # Matcher should filter; ignore off-path tools quietly
        print(json.dumps({"ok": True, "ignored": True, "tool": tool}))
        return 0

    out = process_envelope(envelope)
    print(json.dumps(out, sort_keys=True))
    return 0


if __name__ == "__main__":
    sys.exit(main())
