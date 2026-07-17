#!/usr/bin/env python3
"""Sync product config types into ~/.config/doit/config.toml (config only).

What this does
  - Merge [roles] from do-harness/config.agents.toml (tools, model, color, policy)
  - Merge [toolset] from do-harness/config.toolset.toml
  - Merge product [features]/[telemetry] privacy defaults
  - Ensure [model.<name>] exists for every role model pin (clone from default
    or first existing custom model if missing)
  - Optionally set [ui] yolo / product permission defaults when --ui-product
  - With --apply: ensure [agent] name = roles.default (intake) when unset

What this does NOT do
  - Never copies do-harness/prompts/ into ~/.config/doit
  - Never overwrites api_key / base_url on existing [model.*] entries
  - Never touches sessions, skills, marketplace-cache

Prompts SoT remains the repo: do-harness/prompts/agents/ (native, not customized
from ~/.config/doit). Product does NOT install agents into ~/.config/doit/agents
or .doit/agents — those dirs are user override only (empty by default).

Usage:
  python3 sync-user-config.py              # dry-run
  python3 sync-user-config.py --apply      # write ~/.config/doit/config.toml
  python3 sync-user-config.py --apply --ui-product
  python3 sync-user-config.py --target /path/to/config.toml --apply
"""

from __future__ import annotations

import argparse
import os
import shutil
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover
    try:
        import tomli as tomllib  # type: ignore
    except ImportError:
        print("error: need Python 3.11+ tomllib or tomli", file=sys.stderr)
        sys.exit(2)


def harness_dir() -> Path:
    return Path(__file__).resolve().parent.parent


def default_user_config() -> Path:
    xdg = os.environ.get("XDG_CONFIG_HOME")
    if xdg:
        return Path(xdg) / "doit" / "config.toml"
    return Path.home() / ".config" / "doit" / "config.toml"


def load_toml(path: Path) -> dict[str, Any]:
    if not path.is_file():
        return {}
    data = tomllib.loads(path.read_text(encoding="utf-8"))
    return data if isinstance(data, dict) else {}


def toml_escape(s: str) -> str:
    return (
        s.replace("\\", "\\\\")
        .replace('"', '\\"')
        .replace("\n", "\\n")
        .replace("\t", "\\t")
    )


def fmt_value(v: Any, indent: int = 0) -> str:
    pad = " " * indent
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, int) and not isinstance(v, bool):
        return str(v)
    if isinstance(v, float):
        return str(v)
    if isinstance(v, str):
        return f'"{toml_escape(v)}"'
    if isinstance(v, list):
        if not v:
            return "[]"
        if all(isinstance(x, str) for x in v):
            # multi-line string arrays read cleaner for tools lists
            if len(v) > 3 or any(len(x) > 24 for x in v):
                inner = ",\n".join(f'{pad}    "{toml_escape(x)}"' for x in v)
                return f"[\n{inner},\n{pad}]"
            return "[" + ", ".join(f'"{toml_escape(x)}"' for x in v) + "]"
        return "[" + ", ".join(fmt_value(x, indent) for x in v) + "]"
    if isinstance(v, dict):
        # inline only for empty
        if not v:
            return "{}"
        raise TypeError("nested dicts must be tables, not inline")
    raise TypeError(f"unsupported type: {type(v)}")


def write_table(lines: list[str], header: str, table: dict[str, Any], order: list[str] | None = None) -> None:
    lines.append(f"[{header}]")
    keys = order or list(table.keys())
    seen: set[str] = set()
    for k in keys:
        if k not in table:
            continue
        seen.add(k)
        v = table[k]
        if isinstance(v, dict):
            continue  # nested tables handled separately
        lines.append(f"{k} = {fmt_value(v)}")
    for k, v in table.items():
        if k in seen or isinstance(v, dict):
            continue
        lines.append(f"{k} = {fmt_value(v)}")
    lines.append("")


def dump_config(cfg: dict[str, Any]) -> str:
    """Serialize a subset-friendly config.toml. Order is product-oriented."""
    lines: list[str] = [
        "# Generated/merged by do-harness/scripts/sync-user-config.py",
        f"# at {datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')}",
        "# Prompts are NOT synced here — SoT is do-harness/prompts/ in the repo.",
        "",
    ]

    # Top-level simple tables we know about, in a stable order
    simple_order = [
        "cli",
        "auth",
        "models",
        "features",
        "telemetry",
        "ui",
        "plugins",
        "toolset",
        "agent",
        "skills",
        "sandbox",
        "paths",
        "harness",
        "compat",
        "feedback",
        "relay",
        "remote",
        "hub",
        "worktree_pool",
        "repo_changes_dedup",
    ]

    # models first-ish after cli/auth is nicer for operators — keep order above

    emitted: set[str] = set()

    def emit_simple(name: str) -> None:
        if name not in cfg or name in emitted:
            return
        block = cfg[name]
        if not isinstance(block, dict):
            return
        # skip if only nested and no scalars? still write nested via specialized
        has_scalar = any(not isinstance(v, dict) for v in block.values())
        has_nested = any(isinstance(v, dict) for v in block.values())
        if has_scalar:
            write_table(lines, name, {k: v for k, v in block.items() if not isinstance(v, dict)})
            emitted.add(name)
        elif not has_nested:
            write_table(lines, name, block)
            emitted.add(name)
        # nested children for known parents
        if name == "toolset":
            for nk, nv in block.items():
                if isinstance(nv, dict):
                    write_table(lines, f"{name}.{nk}", nv)
            emitted.add(name)
        elif name == "plugins":
            # already wrote scalars (enabled/disabled)
            for nk, nv in block.items():
                if isinstance(nv, dict):
                    write_table(lines, f"{name}.{nk}", nv)
            emitted.add(name)

    for name in simple_order:
        emit_simple(name)

    # [model.<name>] — preserve all custom models
    models = cfg.get("model")
    if isinstance(models, dict):
        for mname in sorted(models.keys()):
            mblock = models[mname]
            if isinstance(mblock, dict):
                write_table(lines, f"model.{mname}", mblock)
        emitted.add("model")

    # [roles] + [roles.<stem>]
    roles = cfg.get("roles")
    if isinstance(roles, dict):
        meta = {k: v for k, v in roles.items() if not isinstance(v, dict)}
        if meta:
            write_table(lines, "roles", meta)
        # product roster order then extras
        roster = ["intake", "orchestrator", "explorer", "worker", "oracle"]
        stems = [s for s in roster if s in roles and isinstance(roles[s], dict)]
        stems += sorted(
            s for s, v in roles.items() if isinstance(v, dict) and s not in stems
        )
        field_order = [
            "description",
            "model",
            "color",
            "permission_mode",
            "discover_skills",
            "effort",
            "tools",
            "disallowed_tools",
        ]
        for stem in stems:
            write_table(lines, f"roles.{stem}", roles[stem], order=field_order)
        emitted.add("roles")

    # mcp_servers
    mcp = cfg.get("mcp_servers")
    if isinstance(mcp, dict):
        for sname in sorted(mcp.keys()):
            sblock = mcp[sname]
            if isinstance(sblock, dict):
                write_table(lines, f"mcp_servers.{sname}", sblock)
        emitted.add("mcp_servers")

    # any remaining top-level tables
    for name, block in cfg.items():
        if name in emitted:
            continue
        if not isinstance(block, dict):
            lines.append(f"{name} = {fmt_value(block)}")
            lines.append("")
            continue
        # nested map of tables
        scalars = {k: v for k, v in block.items() if not isinstance(v, dict)}
        nested = {k: v for k, v in block.items() if isinstance(v, dict)}
        if scalars:
            write_table(lines, name, scalars)
        for nk, nv in nested.items():
            write_table(lines, f"{name}.{nk}", nv)

    return "\n".join(lines).rstrip() + "\n"


def deep_merge_roles(dst: dict[str, Any], seed: dict[str, Any]) -> dict[str, Any]:
    """Replace roles with seed contracts; keep unknown extra role stems from dst."""
    out: dict[str, Any] = {}
    # seed is the [roles] root from config.agents.toml (includes default + stems)
    for k, v in seed.items():
        out[k] = v
    if isinstance(dst.get("roles"), dict):
        for k, v in dst["roles"].items():
            if k not in out and isinstance(v, dict):
                out[k] = v  # preserve user-only custom roles
    return out


PRODUCT_ROLES = ("intake", "orchestrator", "explorer", "worker", "oracle")


def ensure_agent_name_from_roles(cfg: dict[str, Any], roles: dict[str, Any]) -> list[str]:
    """Ensure [agent] name defaults to roles.default (product: intake)."""
    notes: list[str] = []
    default_role = roles.get("default") if isinstance(roles, dict) else None
    if not isinstance(default_role, str) or not default_role.strip():
        default_role = "intake"
    agent = cfg.setdefault("agent", {})
    if not isinstance(agent, dict):
        cfg["agent"] = {"name": default_role}
        notes.append(f"agent: replaced non-table with name={default_role!r}")
        return notes
    name = agent.get("name")
    if not isinstance(name, str) or not name.strip():
        agent["name"] = default_role
        notes.append(f"agent.name: set to roles.default={default_role!r}")
    return notes


def install_user_agents(harness: Path, config_home: Path) -> list[str]:
    """No-op: product does not install roster agents.

    `.doit/agents/` and `~/.config/doit/agents/` are user-override only.
    Role bodies: do-harness/prompts/agents/; contracts: config.agents.toml / [roles].
    """
    _ = (harness, config_home)
    return ["agents: skip install (product roles from prompts/agents + [roles])"]

    dst_dir.mkdir(parents=True, exist_ok=True)
    for role in PRODUCT_ROLES:
        src = src_dir / f"{role}.md"
        dst = dst_dir / f"{role}.md"
        if not src.is_file():
            notes.append(f"agents: missing source {src.name}")
            continue
        try:
            if dst.is_symlink() or dst.exists():
                # Refresh symlink when it points elsewhere or is a stale file.
                if dst.is_symlink() and dst.resolve() == src.resolve():
                    continue
                dst.unlink()
            os.symlink(src, dst)
            notes.append(f"agents: linked {role}.md → {src}")
        except OSError as exc:
            notes.append(f"agents: failed {role}.md: {exc}")
    return notes


def ensure_models_for_roles(cfg: dict[str, Any], roles: dict[str, Any]) -> list[str]:
    """Ensure every role.model key exists under [model.*]. Returns notes."""
    notes: list[str] = []
    model_map = cfg.setdefault("model", {})
    if not isinstance(model_map, dict):
        model_map = {}
        cfg["model"] = model_map

    # pick a template model to clone (prefer models.default, else first entry)
    models_cfg = cfg.get("models") if isinstance(cfg.get("models"), dict) else {}
    default_name = None
    if isinstance(models_cfg, dict):
        default_name = models_cfg.get("default")
    template: dict[str, Any] | None = None
    template_name = None
    if isinstance(default_name, str) and default_name in model_map:
        template = dict(model_map[default_name])
        template_name = default_name
    elif model_map:
        template_name = next(iter(model_map.keys()))
        template = dict(model_map[template_name])

    needed: set[str] = set()
    for k, v in roles.items():
        if k == "default" or not isinstance(v, dict):
            continue
        m = v.get("model")
        if isinstance(m, str) and m.strip():
            needed.add(m.strip())

    for name in sorted(needed):
        if name in model_map:
            notes.append(f"model.{name}: keep existing")
            continue
        if not template:
            notes.append(f"model.{name}: MISSING (no template to clone — add [model.{name}] manually)")
            continue
        # clone without overwriting later user edits (new only)
        clone = dict(template)
        # Registry key == API model id for product combo/* / model-* pins
        # (same base_url/api_key as template; distinct model string per name).
        clone["model"] = name
        clone["name"] = name
        model_map[name] = clone
        notes.append(f"model.{name}: created (cloned from {template_name})")

    # keep models.default if set; if missing and we have models, leave as-is
    return notes


def merge_config(
    user: dict[str, Any],
    roles_seed: dict[str, Any],
    toolset_seed: dict[str, Any],
    defaults_seed: dict[str, Any],
    ui_product: bool,
) -> tuple[dict[str, Any], list[str]]:
    notes: list[str] = []
    out = dict(user)

    # roles
    roles_root = roles_seed.get("roles", roles_seed)
    if not isinstance(roles_root, dict):
        raise ValueError("config.agents.toml missing [roles]")
    out["roles"] = deep_merge_roles(user, roles_root)
    notes.append(f"roles: merged {sum(1 for k,v in out['roles'].items() if isinstance(v, dict))} contracts")

    # toolset
    if "toolset" in toolset_seed and isinstance(toolset_seed["toolset"], dict):
        out["toolset"] = toolset_seed["toolset"]
        notes.append("toolset: from config.toolset.toml")

    # features / telemetry / tools from product defaults (only known keys)
    for section in ("features", "telemetry", "tools"):
        if section in defaults_seed and isinstance(defaults_seed[section], dict):
            base = dict(out.get(section) or {}) if isinstance(out.get(section), dict) else {}
            base.update(defaults_seed[section])
            out[section] = base
            notes.append(f"{section}: product defaults applied")

    # models for roles
    notes.extend(ensure_models_for_roles(out, out["roles"]))
    notes.extend(ensure_agent_name_from_roles(out, out["roles"]))

    # ui product defaults
    ui = dict(out.get("ui") or {}) if isinstance(out.get("ui"), dict) else {}
    if ui_product:
        ui["yolo"] = False
        # stock ui permission_mode uses always-approve / ask-style strings
        # product D1b: ask — map to stock string if present
        ui["permission_mode"] = "ask"
        notes.append("ui: yolo=false, permission_mode=ask (product)")
    else:
        # always keep yolo false as soft product floor unless user set true intentionally
        if "yolo" not in ui:
            ui["yolo"] = False
            notes.append("ui: yolo=false (default fill)")
    if ui:
        out["ui"] = ui

    return out, notes


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--apply", action="store_true", help="write target config.toml")
    ap.add_argument(
        "--ui-product",
        action="store_true",
        help="force product UI defaults (yolo=false, permission_mode=ask)",
    )
    ap.add_argument(
        "--target",
        type=Path,
        default=None,
        help="config.toml path (default: ~/.config/doit/config.toml)",
    )
    ap.add_argument(
        "--harness",
        type=Path,
        default=None,
        help="do-harness directory (default: parent of this script)",
    )
    args = ap.parse_args()

    harness = args.harness or harness_dir()
    target = args.target or default_user_config()
    roles_path = harness / "config.agents.toml"
    toolset_path = harness / "config.toolset.toml"
    defaults_path = harness / "config.defaults.toml"

    for p in (roles_path, toolset_path, defaults_path):
        if not p.is_file():
            print(f"error: missing {p}", file=sys.stderr)
            return 2

    # refuse to touch anything that looks like a prompts sync target
    if target.name in ("l0-system.md", "SYSTEM.md") or "prompts" in target.parts:
        print("error: refusing to write prompt paths — config only", file=sys.stderr)
        return 2

    user = load_toml(target)
    roles_seed = load_toml(roles_path)
    toolset_seed = load_toml(toolset_path)
    defaults_seed = load_toml(defaults_path)

    try:
        merged, notes = merge_config(
            user, roles_seed, toolset_seed, defaults_seed, ui_product=args.ui_product
        )
    except Exception as exc:  # noqa: BLE001
        print(f"error: merge failed: {exc}", file=sys.stderr)
        return 1

    text = dump_config(merged)

    print(f"target: {target}")
    print(f"harness: {harness}")
    print("notes:")
    for n in notes:
        print(f"  - {n}")
    print(f"prompts: NOT synced (SoT = {harness / 'prompts'})")

    if not args.apply:
        print("\n--- dry-run preview (first 80 lines) ---")
        for i, line in enumerate(text.splitlines()[:80], 1):
            print(f"{i:3}| {line}")
        print("... (run with --apply to write)")
        return 0

    target.parent.mkdir(parents=True, exist_ok=True)
    if target.is_file():
        stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
        backup = target.with_suffix(target.suffix + f".bak.{stamp}")
        shutil.copy2(target, backup)
        print(f"backup: {backup}")

    target.write_text(text, encoding="utf-8")
    # keep secret-ish perms if we can
    try:
        os.chmod(target, 0o600)
    except OSError:
        pass
    print(f"wrote: {target}")

    # Product roles load from prompts/agents + [roles] config — no agents install.
    return 0


if __name__ == "__main__":
    sys.exit(main())
