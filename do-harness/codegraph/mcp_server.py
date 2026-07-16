#!/usr/bin/env python3
"""do CodeGraph MCP server (F-M3-CG / VAL-M3-CG-001).

stdio MCP surface wrapping the forked `code-graph` CLI from
`crates/codegen/xai-codebase-graph`. No greenfield index — productizes the
existing crate binary for explore/impact via stock search_tool / use_tool.

Env:
  DO_CODEGRAPH_BIN   path to code-graph binary (optional)
  DO_CODEGRAPH_CACHE default cache path (optional)
  DO_CODEGRAPH_REPO  default repo root (optional; else cwd)
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any, Optional

try:
    from mcp.server.fastmcp import FastMCP
except ImportError:  # pragma: no cover - fail-open message for operators
    print(
        "CodeGraph MCP: package `mcp` is required (pip install mcp). "
        "Fallback: run code-graph definition/references directly.",
        file=sys.stderr,
    )
    raise

mcp = FastMCP("do-codegraph")

MISSING_BIN = (
    "CodeGraph: `code-graph` binary not found. "
    "Build with: cargo build -p xai-codebase-graph --bin code-graph. "
    "Or set DO_CODEGRAPH_BIN. Fall back to grep/lsp/read_file for now."
)

MISSING_INDEX = (
    "CodeGraph: no usable index answer. "
    "Run: code-graph index <repo> "
    "(optional --cache <path>). Then retry explore/impact. "
    "Fall back to grep/lsp if index cannot be built."
)


def _repo_root_candidates() -> list[Path]:
    here = Path(__file__).resolve()
    # do-harness/codegraph/mcp_server.py -> repo root two levels up
    candidates = [
        Path(os.environ["DO_CODEGRAPH_REPO"]).resolve()
        if os.environ.get("DO_CODEGRAPH_REPO")
        else None,
        Path.cwd().resolve(),
        here.parents[2],  # .../do
    ]
    return [c for c in candidates if c is not None]


def resolve_bin() -> Optional[Path]:
    env = os.environ.get("DO_CODEGRAPH_BIN")
    if env:
        p = Path(env).expanduser()
        if p.is_file() and os.access(p, os.X_OK):
            return p
    which = shutil.which("code-graph")
    if which:
        return Path(which)
    for root in _repo_root_candidates():
        for rel in (
            "target/debug/code-graph",
            "target/release/code-graph",
        ):
            cand = root / rel
            if cand.is_file() and os.access(cand, os.X_OK):
                return cand
    return None


def resolve_repo(repo: Optional[str]) -> Path:
    if repo:
        return Path(repo).expanduser().resolve()
    env = os.environ.get("DO_CODEGRAPH_REPO")
    if env:
        return Path(env).expanduser().resolve()
    return Path.cwd().resolve()


def resolve_cache(repo: Path, cache: Optional[str]) -> Optional[Path]:
    if cache:
        return Path(cache).expanduser().resolve()
    env = os.environ.get("DO_CODEGRAPH_CACHE")
    if env:
        return Path(env).expanduser().resolve()
    default = repo / ".goto_index.bin"
    if default.is_file():
        return default
    return None


def run_code_graph(
    args: list[str],
    *,
    timeout: float = 120.0,
) -> tuple[int, str, str]:
    binary = resolve_bin()
    if binary is None:
        return 127, "", MISSING_BIN
    cmd = [str(binary), *args]
    try:
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )
    except subprocess.TimeoutExpired:
        return 124, "", f"CodeGraph: command timed out: {' '.join(cmd)}"
    except OSError as exc:
        return 126, "", f"CodeGraph: failed to exec {binary}: {exc}"
    return proc.returncode, proc.stdout, proc.stderr


def format_locations(payload: dict[str, Any], limit: int = 40) -> str:
    symbol = payload.get("symbol", "?")
    locations = payload.get("locations") or []
    lines = [f"symbol: {symbol}", f"locations ({len(locations)}):"]
    for loc in locations[:limit]:
        path = loc.get("path", "?")
        line = loc.get("line", "?")
        as_sym = loc.get("symbol")
        if as_sym:
            lines.append(f"  {path}:{line} (as {as_sym})")
        else:
            lines.append(f"  {path}:{line}")
    if len(locations) > limit:
        lines.append(f"  … truncated {len(locations) - limit} more")
    if not locations:
        lines.append("  (none)")
    return "\n".join(lines)


def _query_args(
    repo: Path,
    *,
    symbol: Optional[str],
    file: Optional[str],
    row: Optional[int],
    col: Optional[int],
    cache: Optional[Path],
    include_definition: bool = False,
) -> list[str] | str:
    args: list[str] = [str(repo)]
    if cache is not None:
        args.extend(["--cache", str(cache)])
    if symbol:
        args.extend(["--symbol", symbol])
    elif file and row is not None and col is not None:
        args.extend(["--file", file, "--row", str(row), "--col", str(col)])
    else:
        return "Provide either symbol=… or file=… + row=… + col=… (1-indexed)."
    if include_definition:
        args.append("--include-definition")
    args.append("--json")
    return args


@mcp.tool()
def codegraph_explore(
    symbol: str = "",
    repo: str = "",
    file: str = "",
    row: int = 0,
    col: int = 0,
    cache: str = "",
    max_locations: int = 40,
) -> str:
    """Locate definitions for a symbol (where is X / explore).

    Prefer this over full-repo grep when the project is indexed with code-graph.
    Uses crates/codegen/xai-codebase-graph via the code-graph CLI.
    """
    root = resolve_repo(repo or None)
    cache_path = resolve_cache(root, cache or None)
    q = _query_args(
        root,
        symbol=symbol or None,
        file=file or None,
        row=row or None,
        col=col or None,
        cache=cache_path,
    )
    if isinstance(q, str):
        return f"CodeGraph explore: {q}"
    code, out, err = run_code_graph(["definition", *q])
    if code == 127:
        return err or MISSING_BIN
    if code != 0:
        detail = (err or out or "").strip() or f"exit {code}"
        return f"{MISSING_INDEX}\n({detail})"
    # CLI may print a "Loaded index…" line before JSON
    json_text = out
    brace = out.find("{")
    if brace >= 0:
        json_text = out[brace:]
    try:
        payload = json.loads(json_text)
    except json.JSONDecodeError:
        return f"CodeGraph explore raw output:\n{out.strip() or err}"
    header = (
        f"CodeGraph explore (xai-codebase-graph / code-graph)\n"
        f"repo: {root}\n"
    )
    return header + format_locations(payload, limit=max(1, min(max_locations, 200)))


@mcp.tool()
def codegraph_impact(
    symbol: str = "",
    repo: str = "",
    file: str = "",
    row: int = 0,
    col: int = 0,
    cache: str = "",
    include_definition: bool = False,
    max_locations: int = 60,
) -> str:
    """Find references / callers for a symbol (who uses X / impact).

    Use before risky renames or API changes. Prefer over thrashing grep.
    """
    root = resolve_repo(repo or None)
    cache_path = resolve_cache(root, cache or None)
    q = _query_args(
        root,
        symbol=symbol or None,
        file=file or None,
        row=row or None,
        col=col or None,
        cache=cache_path,
        include_definition=include_definition,
    )
    if isinstance(q, str):
        return f"CodeGraph impact: {q}"
    code, out, err = run_code_graph(["references", *q])
    if code == 127:
        return err or MISSING_BIN
    if code != 0:
        detail = (err or out or "").strip() or f"exit {code}"
        return f"{MISSING_INDEX}\n({detail})"
    json_text = out
    brace = out.find("{")
    if brace >= 0:
        json_text = out[brace:]
    try:
        payload = json.loads(json_text)
    except json.JSONDecodeError:
        return f"CodeGraph impact raw output:\n{out.strip() or err}"
    header = (
        f"CodeGraph impact (references)\n"
        f"repo: {root}\n"
    )
    return header + format_locations(payload, limit=max(1, min(max_locations, 200)))


@mcp.tool()
def codegraph_stats(repo: str = "", cache: str = "") -> str:
    """Show CodeGraph index statistics for a repository."""
    root = resolve_repo(repo or None)
    cache_path = resolve_cache(root, cache or None)
    args = ["stats", str(root)]
    if cache_path is not None:
        args.extend(["--cache", str(cache_path)])
    code, out, err = run_code_graph(args)
    if code == 127:
        return err or MISSING_BIN
    if code != 0:
        return f"{MISSING_INDEX}\n{(err or out).strip()}"
    return f"CodeGraph stats for {root}\n{out.strip()}"


@mcp.tool()
def codegraph_index(
    repo: str = "",
    cache: str = "",
    threads: int = 0,
) -> str:
    """Build or rebuild the CodeGraph index for a repository.

    Operators and agents may call this once per workspace (or after large rewrites).
    """
    root = resolve_repo(repo or None)
    args = ["index", str(root)]
    if cache:
        args.extend(["--cache", str(Path(cache).expanduser().resolve())])
    elif os.environ.get("DO_CODEGRAPH_CACHE"):
        args.extend(["--cache", os.environ["DO_CODEGRAPH_CACHE"]])
    if threads and threads > 0:
        args.extend(["--threads", str(threads)])
    code, out, err = run_code_graph(args, timeout=600.0)
    if code == 127:
        return err or MISSING_BIN
    if code != 0:
        return f"CodeGraph index failed (exit {code}):\n{(err or out).strip()}"
    return f"CodeGraph index ok for {root}\n{out.strip()}"


if __name__ == "__main__":
    mcp.run(transport="stdio")
