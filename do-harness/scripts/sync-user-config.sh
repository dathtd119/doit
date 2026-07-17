#!/usr/bin/env bash
# Sync product config types → ~/.config/doit/config.toml (config only).
# Never copies prompts — SoT is do-harness/prompts/ in the repo.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$ROOT/sync-user-config.py" "$@"
