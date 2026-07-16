#!/usr/bin/env python3
"""Map do-harness/config.models.yaml assignment into agent frontmatter model pins.

VAL-M1-MODEL-001 / F-M1-MODEL-APPLY

- Reads product YAML (registry + assignment) — not a second runtime registry.
- --dry-run (default): print role → model (+ effort) map; no writes.
- --validate: exit non-zero on missing registry names, broken assignment, or
  missing agent files for assigned roles.
- --apply: write model (and optional effort) into do-harness/agents/<role>.md
  frontmatter. Always validates first.

Stock ~/.config/do/config.toml remains the runtime multi-model source of truth.
This script only pins agent frontmatter model: / effort: from the YAML policy.
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError as exc:  # pragma: no cover
    print(
        "error: PyYAML is required (python3 -c 'import yaml'). "
        f"Import failed: {exc}",
        file=sys.stderr,
    )
    sys.exit(2)

# Product roster roles that receive assignment pins.
DEFAULT_ROLES = ("intake", "orchestrator", "explorer", "worker", "oracle")

FRONTMATTER_RE = re.compile(
    r"\A---\r?\n(.*?)\r?\n---\r?\n?",
    re.DOTALL,
)
MODEL_LINE_RE = re.compile(
    r"^(\s*model\s*:\s*)(.+?)(\s*(?:#.*)?)?$",
    re.MULTILINE,
)
EFFORT_LINE_RE = re.compile(
    r"^(\s*effort\s*:\s*)(.+?)(\s*(?:#.*)?)?$",
    re.MULTILINE,
)


@dataclass(frozen=True)
class Pin:
    """Resolved role → registry model pin (+ optional effort)."""

    role: str
    model: str
    effort: str | None


def script_paths() -> tuple[Path, Path, Path]:
    """Return (scripts_dir, harness_dir, repo_root)."""
    scripts = Path(__file__).resolve().parent
    harness = scripts.parent
    repo = harness.parent
    return scripts, harness, repo


def load_yaml(path: Path) -> dict[str, Any]:
    if not path.is_file():
        raise FileNotFoundError(f"config not found: {path}")
    with path.open(encoding="utf-8") as fh:
        data = yaml.safe_load(fh)
    if data is None:
        return {}
    if not isinstance(data, dict):
        raise ValueError(f"config root must be a mapping: {path}")
    return data


def registry_names(data: dict[str, Any]) -> set[str]:
    models = data.get("models")
    if models is None:
        return set()
    if not isinstance(models, dict):
        raise ValueError("models: must be a mapping")
    registry = models.get("registry")
    if registry is None:
        return set()
    if not isinstance(registry, dict):
        raise ValueError("models.registry: must be a mapping")
    return {str(k) for k in registry.keys()}


def default_model_name(data: dict[str, Any]) -> str | None:
    models = data.get("models")
    if not isinstance(models, dict):
        return None
    default = models.get("default")
    if default is None:
        return None
    return str(default)


def parse_pin(role: str, raw: Any) -> Pin:
    """Parse short-form string or structured {model, effort} assignment."""
    if isinstance(raw, str):
        name = raw.strip()
        if not name:
            raise ValueError(f"assignment.{role}: empty model name")
        return Pin(role=role, model=name, effort=None)
    if isinstance(raw, dict):
        if "model" not in raw:
            raise ValueError(
                f"assignment.{role}: structured pin requires 'model' key"
            )
        model = raw["model"]
        if not isinstance(model, str) or not model.strip():
            raise ValueError(f"assignment.{role}.model: must be a non-empty string")
        effort_raw = raw.get("effort")
        effort: str | None
        if effort_raw is None:
            effort = None
        elif isinstance(effort_raw, str) and effort_raw.strip():
            effort = effort_raw.strip()
        else:
            raise ValueError(
                f"assignment.{role}.effort: must be a non-empty string when set"
            )
        return Pin(role=role, model=model.strip(), effort=effort)
    raise ValueError(
        f"assignment.{role}: expected string registry name or "
        f"{{model, effort}} mapping, got {type(raw).__name__}"
    )


def parse_assignments(data: dict[str, Any]) -> list[Pin]:
    assignment = data.get("assignment")
    if assignment is None:
        raise ValueError("assignment: missing (role → model table required)")
    if not isinstance(assignment, dict):
        raise ValueError("assignment: must be a mapping")
    if not assignment:
        raise ValueError("assignment: empty (need at least one role pin)")
    pins: list[Pin] = []
    for role, raw in assignment.items():
        role_s = str(role).strip()
        if not role_s:
            raise ValueError("assignment: empty role key")
        # Skip pure comment placeholders if a null sneaks in
        if raw is None:
            raise ValueError(f"assignment.{role_s}: null value")
        pins.append(parse_pin(role_s, raw))
    return pins


def validate(
    data: dict[str, Any],
    agents_dir: Path,
    *,
    require_roster: bool = True,
) -> tuple[list[Pin], list[str]]:
    """Validate config and agent paths. Returns (pins, error messages)."""
    errors: list[str] = []
    try:
        names = registry_names(data)
    except ValueError as exc:
        return [], [str(exc)]

    if not names:
        errors.append("models.registry: empty or missing (need ≥1 registry name)")

    default = default_model_name(data)
    if default is not None and names and default not in names:
        errors.append(
            f"models.default: '{default}' is not in models.registry "
            f"(known: {sorted(names)})"
        )

    try:
        pins = parse_assignments(data)
    except ValueError as exc:
        return [], errors + [str(exc)]

    for pin in pins:
        if names and pin.model not in names:
            errors.append(
                f"assignment.{pin.role}: model '{pin.model}' is not in "
                f"models.registry (known: {sorted(names)})"
            )
        agent_path = agents_dir / f"{pin.role}.md"
        if not agent_path.is_file():
            errors.append(
                f"assignment.{pin.role}: agent file missing: {agent_path}"
            )
        elif not read_frontmatter(agent_path)[0]:
            errors.append(
                f"assignment.{pin.role}: no YAML frontmatter in {agent_path}"
            )

    if require_roster:
        assigned = {p.role for p in pins}
        missing = [r for r in DEFAULT_ROLES if r not in assigned]
        if missing:
            errors.append(
                "assignment: product roster roles missing pins: "
                + ", ".join(missing)
            )

    return pins, errors


def read_frontmatter(path: Path) -> tuple[str | None, str]:
    """Return (frontmatter_body_or_None, full_text)."""
    text = path.read_text(encoding="utf-8")
    match = FRONTMATTER_RE.match(text)
    if not match:
        return None, text
    return match.group(1), text


def set_frontmatter_field(fm: str, key: str, value: str) -> str:
    """Set or insert a simple scalar frontmatter field (model / effort)."""
    if key == "model":
        line_re = MODEL_LINE_RE
        # Prefer replace existing model: line (including inherit).
        if line_re.search(fm):
            return line_re.sub(
                lambda m: f"{m.group(1)}{value}{m.group(3) or ''}",
                fm,
                count=1,
            )
        # Insert after name: if present, else at top of frontmatter.
        name_re = re.compile(r"^(name\s*:\s*.+)$", re.MULTILINE)
        if name_re.search(fm):
            return name_re.sub(
                lambda m: f"{m.group(1)}\nmodel: {value}",
                fm,
                count=1,
            )
        return f"model: {value}\n{fm}"

    if key == "effort":
        line_re = EFFORT_LINE_RE
        if line_re.search(fm):
            return line_re.sub(
                lambda m: f"{m.group(1)}{value}{m.group(3) or ''}",
                fm,
                count=1,
            )
        # Place effort immediately after model: when present.
        if MODEL_LINE_RE.search(fm):
            return MODEL_LINE_RE.sub(
                lambda m: f"{m.group(0)}\neffort: {value}",
                fm,
                count=1,
            )
        return f"effort: {value}\n{fm}"

    raise ValueError(f"unsupported frontmatter key: {key}")


def apply_pin_to_agent(path: Path, pin: Pin, *, dry_run: bool) -> str:
    """Update agent frontmatter. Returns a one-line status description."""
    fm, text = read_frontmatter(path)
    if fm is None:
        raise ValueError(f"no frontmatter: {path}")

    new_fm = set_frontmatter_field(fm, "model", pin.model)
    if pin.effort is not None:
        new_fm = set_frontmatter_field(new_fm, "effort", pin.effort)

    if new_fm == fm:
        return f"{pin.role}: unchanged (already model: {pin.model}" + (
            f", effort: {pin.effort})" if pin.effort else ")"
        )

    match = FRONTMATTER_RE.match(text)
    assert match is not None
    # Rebuild with same closing --- style as original (LF).
    new_text = f"---\n{new_fm}\n---\n" + text[match.end() :]
    if not dry_run:
        path.write_text(new_text, encoding="utf-8")
    action = "would write" if dry_run else "wrote"
    effort_bit = f", effort: {pin.effort}" if pin.effort else ""
    return f"{pin.role}: {action} model: {pin.model}{effort_bit} → {path}"


def print_map(
    pins: list[Pin],
    data: dict[str, Any],
    *,
    title: str = "assignment map",
) -> None:
    names = sorted(registry_names(data))
    default = default_model_name(data)
    print(f"== {title} ==")
    print(f"registry: {', '.join(names) if names else '(empty)'}")
    if default is not None:
        print(f"default:  {default}")
    print("assignment:")
    width = max((len(p.role) for p in pins), default=4)
    for pin in pins:
        effort = f"  effort={pin.effort}" if pin.effort else ""
        print(f"  {pin.role:<{width}}  →  {pin.model}{effort}")


def build_parser() -> argparse.ArgumentParser:
    _, harness, _ = script_paths()
    p = argparse.ArgumentParser(
        description=(
            "Map config.models.yaml assignment into agent frontmatter model pins. "
            "Does not create a second runtime multi-model registry."
        )
    )
    p.add_argument(
        "--config",
        type=Path,
        default=harness / "config.models.yaml",
        help="path to config.models.yaml (default: do-harness/config.models.yaml)",
    )
    p.add_argument(
        "--agents-dir",
        type=Path,
        default=harness / "agents",
        help="directory of agent .md profiles (default: do-harness/agents)",
    )
    p.add_argument(
        "--validate",
        action="store_true",
        help="validate registry/assignment; exit 1 on errors (no write)",
    )
    p.add_argument(
        "--apply",
        action="store_true",
        help="write model pins into agent frontmatter (validates first)",
    )
    p.add_argument(
        "--dry-run",
        action="store_true",
        help="print map only (default when neither --validate nor --apply)",
    )
    p.add_argument(
        "--allow-partial-roster",
        action="store_true",
        help="do not require all five product roster roles in assignment",
    )
    return p


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    config_path = args.config.resolve()
    agents_dir = args.agents_dir.resolve()

    # Default mode is dry-run print when no action flags given.
    dry_only = not args.validate and not args.apply
    if dry_only:
        args.dry_run = True

    try:
        data = load_yaml(config_path)
    except (OSError, ValueError, yaml.YAMLError) as exc:
        print(f"error: failed to load config: {exc}", file=sys.stderr)
        return 1

    pins, errors = validate(
        data,
        agents_dir,
        require_roster=not args.allow_partial_roster,
    )

    if args.validate or args.apply:
        if errors:
            print("== validate: FAIL ==", file=sys.stderr)
            for err in errors:
                print(f"  - {err}", file=sys.stderr)
            return 1
        print("== validate: PASS ==")
        print(f"config: {config_path}")
        print(f"agents: {agents_dir}")
        print(f"pins:   {len(pins)}")

    if pins:
        print_map(pins, data)
    elif not errors:
        print("assignment: (none)", file=sys.stderr)

    if args.apply:
        print("== apply ==")
        for pin in pins:
            agent_path = agents_dir / f"{pin.role}.md"
            try:
                status = apply_pin_to_agent(agent_path, pin, dry_run=False)
            except (OSError, ValueError) as exc:
                print(f"error: {exc}", file=sys.stderr)
                return 1
            print(f"  {status}")
        print("apply: done")
        return 0

    if args.dry_run and not args.validate:
        print("(dry-run: no files written; pass --apply to write pins)")
    elif args.validate and not args.apply:
        print("(validate-only: no files written)")

    # Dry-run / validate success with clean map.
    if errors and dry_only:
        # Still print map if we have pins; surface errors for dry-run awareness.
        print("== dry-run notes (would fail --validate) ==", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
