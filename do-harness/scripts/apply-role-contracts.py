#!/usr/bin/env python3
"""Validate product role contracts (config.roles.toml + prompts/roles).

Product roles no longer write do-harness/agents/*.md. Runtime loads:
  - mission body: prompts/roles/<stem>.md (compile-time + optional user prompts override)
  - tools/model/color: [roles.*] in config.toml (seed: config.roles.toml)

Usage:
  python3 apply-role-contracts.py              # dry-run / summary
  python3 apply-role-contracts.py --validate   # exit 1 on missing contract/body
  python3 apply-role-contracts.py --apply      # no-op (kept for script compatibility)
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import Any

try:
    import tomllib  # py311+
except ModuleNotFoundError:  # pragma: no cover
    try:
        import tomli as tomllib  # type: ignore
    except ImportError:
        print(
            "error: need tomllib (Python 3.11+) or tomli to parse config.roles.toml",
            file=sys.stderr,
        )
        sys.exit(2)

PRODUCT_ROLES = ("intake", "orchestrator", "explorer", "worker", "oracle")


def harness_paths() -> tuple[Path, Path]:
    scripts = Path(__file__).resolve().parent
    harness = scripts.parent
    return scripts, harness


def load_roles_toml(path: Path) -> dict[str, Any]:
    raw = path.read_bytes()
    data = tomllib.loads(raw.decode("utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"root must be a table: {path}")
    roles = data.get("roles")
    if not isinstance(roles, dict):
        raise ValueError("missing [roles] table")
    return roles


def role_contract(roles_root: dict[str, Any], name: str) -> dict[str, Any]:
    block = roles_root.get(name)
    if not isinstance(block, dict):
        raise KeyError(f"missing [roles.{name}]")
    return block


def as_str_list(value: Any, field: str) -> list[str]:
    if value is None:
        return []
    if not isinstance(value, list):
        raise ValueError(f"{field} must be an array")
    return [str(x) for x in value]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--apply",
        action="store_true",
        help="no-op (agents bridge removed; kept for CI compatibility)",
    )
    ap.add_argument(
        "--validate",
        action="store_true",
        help="exit 1 if contract or role body is missing",
    )
    ap.add_argument(
        "--roles-toml",
        type=Path,
        default=None,
        help="path to config.roles.toml (default: do-harness/config.roles.toml)",
    )
    args = ap.parse_args()

    _, harness = harness_paths()
    roles_path = args.roles_toml or (harness / "config.roles.toml")
    roles_dir = harness / "prompts" / "roles"

    if not roles_path.is_file():
        print(f"error: missing {roles_path}", file=sys.stderr)
        return 2

    try:
        roles_root = load_roles_toml(roles_path)
    except Exception as exc:  # noqa: BLE001
        print(f"error: parse {roles_path}: {exc}", file=sys.stderr)
        return 2

    default = roles_root.get("default")
    if default is not None and str(default) != "intake":
        print(f"warn: roles.default={default!r} (product expects intake)", file=sys.stderr)

    errors = 0
    for name in PRODUCT_ROLES:
        try:
            c = role_contract(roles_root, name)
        except KeyError as exc:
            print(f"FAIL {exc}", file=sys.stderr)
            errors += 1
            continue

        body_path = roles_dir / f"{name}.md"
        if not body_path.is_file():
            print(f"FAIL missing role body {body_path}", file=sys.stderr)
            errors += 1
            continue

        body = body_path.read_text(encoding="utf-8").strip()
        if not body:
            print(f"FAIL empty role body {body_path}", file=sys.stderr)
            errors += 1
            continue
        if "## Mission" not in body:
            print(f"FAIL {name}: body missing ## Mission", file=sys.stderr)
            errors += 1
            continue

        tools = as_str_list(c.get("tools"), "tools")
        denied = as_str_list(c.get("disallowed_tools"), "disallowed_tools")
        model = str(c.get("model") or "").strip()
        if not model:
            print(f"FAIL {name}: model required", file=sys.stderr)
            errors += 1
            continue
        if not tools:
            print(f"FAIL {name}: tools must be non-empty", file=sys.stderr)
            errors += 1
            continue

        print(
            f"  ok  {name}: model={model} tools={len(tools)} "
            f"deny={len(denied)} body={body_path.name}"
        )

    agents_dir = harness / "agents"
    if agents_dir.is_dir() and any(agents_dir.glob("*.md")):
        print(
            f"  warn agents/ still present under {agents_dir} "
            "(product no longer uses this bridge; safe to remove)",
            file=sys.stderr,
        )

    if errors:
        print(f"\n{errors} error(s)", file=sys.stderr)
        return 1

    if args.apply:
        print("apply: no-op (roles from prompts/roles + config.roles.toml; no agents write)")
    elif not args.validate:
        print("dry-run ok (use --validate to enforce)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
