#!/usr/bin/env bash
# Detect unused Cargo dependencies via cargo-machete.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
mkdir -p .quality

if ! command -v cargo >/dev/null 2>&1; then
  echo "cargo not found"
  exit 1
fi

if ! command -v cargo-machete >/dev/null 2>&1; then
  echo "Installing cargo-machete..."
  cargo install cargo-machete --locked --version 0.7.0
fi

# Soft by default for local; CI sets MACHETE_SOFT=0 after baseline cleanup.
set +e
cargo machete --with-metadata 2>&1 | tee .quality/unused-deps.txt
status=${PIPESTATUS[0]}
set -e

if (( status != 0 )); then
  echo "cargo-machete reported unused dependencies (exit $status)."
  echo "See .quality/unused-deps.txt — fix or document false positives."
  if [[ "${MACHETE_SOFT:-1}" == "1" ]]; then
    echo "MACHETE_SOFT=1: not failing the build (report still produced)."
    exit 0
  fi
  exit "$status"
fi

echo "Unused dependency check passed."
