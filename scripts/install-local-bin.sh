#!/usr/bin/env bash
# Install the product CLI (`doit`) to user-local PATH locations.
# Usage:
#   ./scripts/install-local-bin.sh           # prefer release, fall back to debug
#   ./scripts/install-local-bin.sh --debug   # force debug binary
#   ./scripts/install-local-bin.sh --release # force release binary
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE=""
for arg in "$@"; do
  case "$arg" in
    --debug) PROFILE=debug ;;
    --release) PROFILE=release ;;
    -h|--help)
      sed -n '2,8p' "$0"
      exit 0
      ;;
  esac
done

pick_binary() {
  local release="$ROOT/target/release/doit"
  local debug="$ROOT/target/debug/doit"
  if [[ "$PROFILE" == "debug" ]]; then
    [[ -x "$debug" ]] || { echo "missing $debug — run: cargo build -p doit" >&2; exit 1; }
    echo "$debug"
    return
  fi
  if [[ "$PROFILE" == "release" ]]; then
    [[ -x "$release" ]] || { echo "missing $release — run: cargo build -p doit --release" >&2; exit 1; }
    echo "$release"
    return
  fi
  if [[ -x "$release" ]]; then
    echo "$release"
  elif [[ -x "$debug" ]]; then
    echo "$debug"
  else
    echo "no built binary — run: cargo build -p doit" >&2
    exit 1
  fi
}

SRC="$(pick_binary)"
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/doit/bin" "$HOME/.config/doit"
cp -f "$SRC" "$HOME/.local/bin/doit"
cp -f "$SRC" "$HOME/.local/share/doit/bin/doit"
chmod +x "$HOME/.local/bin/doit" "$HOME/.local/share/doit/bin/doit"
ln -sfn "$HOME/.local/bin/doit" "$HOME/.local/bin/do"
ln -sfn "$HOME/.local/bin/doit" "$HOME/.local/bin/do-it"

ALIASES_SRC="$ROOT/scripts/shell-aliases.sh"
if [[ -f "$ALIASES_SRC" ]]; then
  cp -f "$ALIASES_SRC" "$HOME/.config/doit/shell-aliases.sh"
fi

if ! echo ":$PATH:" | grep -q ":$HOME/.local/bin:"; then
  if [[ -f "$HOME/.bashrc" ]] && ! grep -qF 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
    printf '\n# doit product CLI\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$HOME/.bashrc"
    echo "Appended ~/.local/bin to PATH in ~/.bashrc (open a new shell or: source ~/.bashrc)"
  else
    echo "Note: ~/.local/bin not on PATH in this shell; ensure it is exported."
  fi
fi

echo "Installed from: $SRC"
echo "  $HOME/.local/bin/doit"
echo "  $HOME/.local/bin/do      -> doit"
echo "  $HOME/.local/bin/do-it   -> doit"
echo "  $HOME/.local/share/doit/bin/doit"
echo "Smoke: doit --version"
"$HOME/.local/bin/doit" --version 2>&1 | head -5 || true
