#!/usr/bin/env bash
# Repo git pre-commit entrypoint (works without the Python pre-commit package).
# Also listed in .pre-commit-config.yaml for developers who install pre-commit.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Never wipe ignored local agent state from a hook path.
export GIT_OPTIONAL_LOCKS=0

echo "[pre-commit] product quality gates"
bash scripts/check-large-files.sh
bash scripts/check-exfil-surfaces.sh
bash scripts/check-tech-debt.sh
bash scripts/validate-agents-md.sh

if command -v cargo >/dev/null 2>&1; then
  # Fast fmt on staged Rust only when rustfmt is available.
  if git diff --cached --name-only --diff-filter=ACM | grep -q '\.rs$'; then
    echo "[pre-commit] cargo fmt --check (workspace)"
    cargo fmt --all -- --check
  fi
fi

echo "[pre-commit] ok"
